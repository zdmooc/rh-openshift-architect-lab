# OpenShift Image Registry — Schémas et séquences (CRC)

## 1) Repères rapides
- **Operator** : `cluster-image-registry-operator` (gère le cycle de vie du registry).
- **Pod registry** : `image-registry-xxxx` (sert/pousse/retire les images).
- **Node CA** : `node-ca-xxxx` (propage les certs vers les nœuds).
- **Endpoints** :
  - Interne cluster : `image-registry.openshift-image-registry.svc:5000`
  - Route externe : `default-route-openshift-image-registry.apps-crc.testing`
- **Stockage** : PVC/PV ou objet (selon conf). Sur CRC, souvent PV local.
- **Objets liés** : `ImageStream`, `BuildConfig`, `Deployment`, `ServiceAccount` + secrets pull/push.

---

## 2) Diagramme composants (vue logique)
```mermaid
flowchart LR
  subgraph UserPC[Poste client]
    CLI[podman / docker / skopeo]
  end

  subgraph NS[Namespace: openshift-image-registry]
    OP[(cluster-image-registry-operator)]
    REG[(image-registry Pod)]
    SVC[[Service ClusterIP :5000]]
    RT((Route: default-route))
    CA[[node-ca DaemonSet]]
  end

  subgraph Storage[Stockage]
    PV[(PVC / Objet S3 / File)]
  end

  subgraph Projects[Projets applicatifs]
    IS[(ImageStream)]
    BC[(BuildConfig)]
    SA[(ServiceAccount + secrets)]
    DEP[(Deployments/Pods)]
  end

  CLI -- HTTPS + Token --> RT
  RT -- TLS passthrough/reencrypt --> SVC
  SVC --> REG
  REG <---> PV

  OP --> REG
  OP --> RT
  OP --> SVC
  OP -. gère certs .-> CA

  REG <--> IS
  BC --> REG
  DEP --> REG
  SA -. pullSecret .-> DEP
```

---

## 3) Flux réseau et sécurité
- **Depuis l’extérieur** : accès via **Route** (TLS, auth token `oc whoami -t`).
- **Depuis le cluster** : accès via **Service** interne (`svc:5000`).
- **Auth** : token OpenShift ou *robot account* du registry.
- **TLS** : CRC → cert auto-signé côté route; côté cluster, confiance via `node-ca`.

---

## 4) Séquences clés

### 4.1 Push depuis le poste vers la Route
```mermaid
sequenceDiagram
  autonumber
  participant Dev as Dev (poste)
  participant Route as Route Registry
  participant SVC as Service :5000
  participant REG as Pod image-registry
  participant PV as Stockage

  Dev->>Route: login( token kube )
  Dev->>Route: push <ns>/<image>:<tag>
  Route->>SVC: TLS proxy
  SVC->>REG: recevoir blob/layer
  REG->>PV: write layers/manifests
  REG-->>Dev: 201 Created
```

### 4.2 Pull depuis un Pod du cluster
```mermaid
sequenceDiagram
  autonumber
  participant Pod as Pod applicatif
  participant SA as ServiceAccount
  participant SVC as Service :5000
  participant REG as Pod image-registry
  participant PV as Stockage

  SA-->>Pod: pullSecret (auth)
  Pod->>SVC: pull <ns>/<image>:<tag>
  SVC->>REG: requête blobs
  REG->>PV: read layers/manifests
  REG-->>Pod: 200 OK (layers)
```

### 4.3 Importer/mirrorer une image externe vers l’interne
```mermaid
sequenceDiagram
  autonumber
  participant Ext as Registry externe (ex: cp.icr.io)
  participant CLI as oc/skopeo
  participant Route as Route Registry
  participant REG as Pod image-registry
  participant PV as Stockage

  CLI->>Ext: pull source:tag
  CLI->>Route: login(token)
  CLI->>Route: push dest:tag
  Route->>REG: transfert
  REG->>PV: write
```

---

## 5) Objets OpenShift impliqués
- **ImageRegistry (configs.imageregistry/cluster)** : active la `defaultRoute`, backend storage.
- **ImageStream** : méta-catalogue d’images par projet; déclenche imports et triggers.
- **BuildConfig** : S2I/Docker builds qui publient dans le registry.
- **Secrets** : `kubernetes.io/dockerconfigjson` pour pull/push.
- **ServiceAccount** : associe les secrets aux pods.

---

## 6) Décisions d’usage
- **Juste consommer** des images officielles → mirror via `oc image mirror`/`skopeo`.
- **Customiser ODM** (drivers, OIDC, conf) → image dérivée **FROM** l’officielle puis push.
- **Air‑gap** → plan de mirroring périodique + `ImageContentSourcePolicy`.

---

## 7) Endpoints et commandes repère
- Interne cluster :
  - `image-registry.openshift-image-registry.svc:5000/<ns>/<image>:<tag>`
- Externe (CRC) :
  - `default-route-openshift-image-registry.apps-crc.testing/<ns>/<image>:<tag>`

```bash
# Login route externe depuis le poste
TOKEN=$(oc whoami -t)
podman login default-route-openshift-image-registry.apps-crc.testing \
  -u $(oc whoami) -p $TOKEN --tls-verify=false

# Push d’une image taggée
podman push default-route-openshift-image-registry.apps-crc.testing/odm-dev/odm:9.5 --tls-verify=false

# Consommation depuis le cluster (déploiement)
oc -n odm-dev create deploy odm \
  --image=image-registry.openshift-image-registry.svc:5000/odm-dev/odm:9.5
```

