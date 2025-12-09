# 10 — TLS & Certificats (Routes • Wildcards • Trust • Rotation • Registry)

## 0) Objectif
Maîtriser TLS sur OpenShift : **terminations** (edge/reencrypt/passthrough), **certificats** par défaut et par route, **wildcards**, **chaîne de confiance** côté cluster et côté client, **rotation**, **registry**.

---

## 1) Terminology
- **Route** : objet OCP qui publie un Service via le routeur (HAProxy).
- **Terminations** :
  - **edge** : TLS client→routeur, HTTP routeur→backend.
  - **reencrypt** : TLS client→routeur **et** TLS routeur→backend.
  - **passthrough** : TLS de bout en bout. Le routeur ne termine pas TLS.
- **Cert par défaut** : présenté par le routeur si aucune route plus spécifique.
- **Wildcard** : `*.apps.example.com`.

---

## 2) Schéma global
```mermaid
flowchart TB
  User[Client HTTPS] --> Route[Route (HAProxy)]
  Route --> SVC[Service]
  SVC --> POD[Pod (Backend)]
```

---

## 3) Terminations — exemples YAML
### 3.1 Edge
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata: { name: web-edge, namespace: app }
spec:
  host: web.apps.example.com
  to: { kind: Service, name: web }
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect   # HTTP→HTTPS
```

### 3.2 Reencrypt
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata: { name: web-re, namespace: app }
spec:
  host: web.apps.example.com
  to: { kind: Service, name: web }
  port: { targetPort: https }
  tls:
    termination: reencrypt
    destinationCACertificate: |
      -----BEGIN CERTIFICATE-----
      <CA qui a signé le cert backend>
      -----END CERTIFICATE-----
```
> Backend doit exposer HTTPS (cert CN/SAN = nom service/host interne).

### 3.3 Passthrough
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata: { name: web-pt, namespace: app }
spec:
  host: web.apps.example.com
  to: { kind: Service, name: web }
  port: { targetPort: 8443 }   # port TLS du backend
  tls:
    termination: passthrough
```
> Le certificat présenté est **celui du pod**. SNI doit correspondre à `spec.host`.

---

## 4) Certificat par défaut du routeur (wildcard)
### 4.1 IngressController → secret TLS
- Secret TLS dans `openshift-ingress` (clé+cert **chaîné**).
- Lier dans l’IngressController `defaultCertificate.name`.

```yaml
# Secret TLS pour wildcard
apiVersion: v1
kind: Secret
metadata: { name: wildcard-cert, namespace: openshift-ingress }
type: kubernetes.io/tls
data:
  tls.crt: <base64(cert + chain)>
  tls.key: <base64(key)>
---
apiVersion: operator.openshift.io/v1
kind: IngressController
metadata:
  name: default
  namespace: openshift-ingress-operator
spec:
  defaultCertificate:
    name: wildcard-cert
```
Effet : toutes les routes **sans** cert spécifique utilisent ce wildcard.

---

## 5) Certificat spécifique à une route
- Secret TLS **dans le namespace de l’app**.
- Référencé par `spec.tls.certificate`/`key` **ou** secret nommé via annotation (`route.openshift.io/tls-certificates` selon version) — plus simple : mettre le PEM directement dans le champ `tls.certificate`.

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata: { name: web-custom, namespace: app }
spec:
  host: api.app.example.com
  to: { kind: Service, name: web }
  tls:
    termination: edge
    certificate: |
      -----BEGIN CERTIFICATE-----
      ...
    key: |
      -----BEGIN PRIVATE KEY-----
      ...
    caCertificate: |
      # optionnel si client mTLS
```

---

## 6) Chaîne de confiance côté **cluster**
### 6.1 Ajouter une CA de confiance pour **pull d’images**
```yaml
apiVersion: config.openshift.io/v1
kind: Image
metadata: { name: cluster }
spec:
  additionalTrustedCA:
    name: registry-ca   # ConfigMap dans openshift-config
---
apiVersion: v1
kind: ConfigMap
metadata: { name: registry-ca, namespace: openshift-config }
data:
  ca-bundle.crt: |
    -----BEGIN CERTIFICATE-----
    <CA du registry>
```
Effet : nœuds/CRI‑O font confiance à la CA pour pulls d’images.

### 6.2 Ajouter CA pour **egress TLS** applicatif
```yaml
apiVersion: config.openshift.io/v1
kind: Proxy
metadata: { name: cluster }
spec:
  trustedCA:
    name: user-ca-bundle  # ConfigMap openshift-config
---
apiVersion: v1
kind: ConfigMap
metadata: { name: user-ca-bundle, namespace: openshift-config }
data:
  ca-bundle.crt: |
    <CAs privées à faire connaître aux pods>
```
Les CAs sont injectées dans `/etc/pki/ca-trust` des pods via injection globale.

---

## 7) Chaîne de confiance côté **client** (poste)
- Exporter le cert de la **Route** et l’ajouter au trust du poste/Podman.
- Exemple Podman :
```bash
# Dump cert route
echo | openssl s_client -servername registry.apps.example.com -connect registry.apps.example.com:443 2>/dev/null | openssl x509 > registry.crt
# Trust local (Fedora/RHEL)
sudo cp registry.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
podman login registry.apps.example.com -u user -p token
```

---

## 8) Registry interne via Route
- Route par défaut : `default-route-openshift-image-registry...`
- Deux options :
  - Ajouter la CA de la route au poste (cf. §7).
  - Ou utiliser `--tls-verify=false` en DEV seulement.

Push depuis poste :
```bash
TOKEN=$(oc whoami -t)
podman login $REGISTRY -u $(oc whoami) -p $TOKEN --tls-verify=false
podman push $REGISTRY/app/img:1.0 --tls-verify=false
```

Dans le cluster, utiliser **endpoint interne** :
```
image-registry.openshift-image-registry.svc:5000/ns/img:tag
```

---

## 9) Rotation & renouvellement
- **Wildcards** : surveiller expiration. Remplacer le secret puis vérifier.
- **Routes custom** : renouveler secrets par namespace.
- **CAs de confiance** : mettre à jour ConfigMaps `registry-ca`/`user-ca-bundle`.
- **Automatisation** : cert-manager/ACME pour renouvellement automatique.

Séquence remplacement wildcard :
```mermaid
sequenceDiagram
  autonumber
  participant Admin
  participant IC as IngressController
  Admin->>IC: new secret tls (wildcard-cert)
  IC-->>Admin: router reload
  Admin-->>Client: vérif chaîne et CN/SAN
```

---

## 10) mTLS et backend
- **Reencrypt + client cert** : possible via annotations HAProxy pour passer le cert client au backend ou côté mesh.
- **Passthrough** : mTLS géré **exclusivement** par l’app/backend.

---

## 11) Dépannage TLS
```bash
# Voir routes et leurs TLS
oc get route -A -o wide | grep -E "edge|reencrypt|passthrough"

# Tester handshake et chaîne
openssl s_client -connect web.apps.example.com:443 -servername web.apps.example.com -showcerts

# Vérifier correspondance clé/cert
openssl x509 -noout -modulus -in tls.crt | openssl md5
openssl rsa  -noout -modulus -in tls.key | openssl md5

# Logs routeur
oc -n openshift-ingress logs deploy/router -c router
```
Erreurs courantes :
- **CN/SAN** ne correspond pas à `spec.host`.
- **Chaîne incomplète** (intermediate manquant) → fournir full chain.
- **Backend non TLS** avec `reencrypt` → 503/handshake fail.
- **SNI** absent en passthrough.

---

## 12) Checklist
- Choix termination adapté : edge (simple), reencrypt (TLS bout‑en‑bout), passthrough (TLS app).
- Wildcard valide chargé sur l’IngressController par défaut.
- Routes custom avec secrets propres si besoin.
- CAs internes distribuées : `additionalTrustedCA` (images) et `trustedCA` (pods).
- Registry : trust côté poste ou `--tls-verify=false` en DEV, endpoint interne in‑cluster.
- Surveillance et rotation des certs planifiées.

