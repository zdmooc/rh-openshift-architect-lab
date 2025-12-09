# Architecture OpenShift — Niveau Projet : Schéma central + explications et séquences

## 0) Objectif
Comprendre toutes les briques d’un **projet OpenShift** et leurs interactions autour d’un schéma central. Inclut trafic entrant, build/images, sécurité, stockage, autoscaling et GitOps.

---

## 1) Schéma central du projet
```mermaid
flowchart TB
  subgraph Project["Projet OpenShift"]
    Route --> Svc[Service]
    Ingress -.-> Svc
    Svc --> Pod

    Pod --> CM[ConfigMap]
    Pod --> Sec[Secret]
    Pod --> SA[ServiceAccount]
    Pod --> PVC[PersistentVolumeClaim]

    Dep[Deployment] --> RS[ReplicaSet]
    RS --> Pod
    HPA[HPA] --> Dep

    DC[DeploymentConfig] --> Pod

    IS[ImageStream] --> Dep
    IS --> DC
    BC[BuildConfig] --> IS

    NP[NetworkPolicy] --> Pod

    RQ[ResourceQuota] --> Dep
    LR[LimitRange] --> Dep
  end

  SCC[SecurityContextConstraints] -.-> SA
  RB[RoleBinding] --> Role[Role]
  RB --> SA

  PVC --> PV[PersistentVolume]
  SC[StorageClass] --> PV

  Registry[Internal Image Registry] --> IS
  ExtReg[External Registry] -. mirror .-> Registry
```

**Lecture rapide**
- **Trafic**: Route/Ingress -> Service -> Pod
- **Images**: BuildConfig -> ImageStream -> Deployment/DeploymentConfig -> Pods
- **Sécurité**: RBAC (Role/RoleBinding -> ServiceAccount), **SCC** (niveau exécution), **NetworkPolicy** (réseau)
- **Ressources**: ResourceQuota/LimitRange
- **Stockage**: PVC -> PV (via StorageClass)
- **Registry**: Interne, option miroir depuis un registre externe

---

## 2) Trafic entrant: Route/Ingress -> Service -> Pod
```mermaid
sequenceDiagram
  autonumber
  participant U as User (navigateur / client)
  participant Route as Route
  participant Ingress as Ingress Controller
  participant SVC as Service (ClusterIP)
  participant POD as Pod

  U->>Route: HTTPS request
  Route->>Ingress: handoff TLS/HTTP
  Ingress->>SVC: routage vers service
  SVC->>POD: proxy vers endpoints
  POD-->>U: response
```
**Notes**
- Route expose un FQDN externe. Ingress Controller implémente le dataplane.
- Le Service (ClusterIP) distribue vers les Pods via Endpoints.

---

## 3) Build et images: de la source au déploiement
```mermaid
sequenceDiagram
  autonumber
  participant Dev as Dev (git push)
  participant BC as BuildConfig
  participant REG as Internal Registry
  participant IS as ImageStream
  participant DEP as Deployment
  participant RS as ReplicaSet
  participant POD as Pod

  Dev->>BC: trigger build (webhook/manuel)
  BC->>REG: push image:tag
  REG->>IS: update tag (ImageStream)
  IS-->>DEP: trigger rollout (image change)
  DEP->>RS: new ReplicaSet
  RS->>POD: create Pods
```
**Variantes**
- **Mirroring**: `skopeo/oc image mirror` depuis un registre externe vers le registre interne, puis IS importe la référence.
- **Dockerfile/Tekton**: build dérivé (drivers, certs, conf) puis push dans le registre interne.

---

## 4) Sécurité d’exécution et d’accès
```mermaid
flowchart LR
  SA[ServiceAccount] -->|monté dans| Pod
  Role[Role] -->|autorisations| SA
  RB[RoleBinding] --> Role
  SCC[SecurityContextConstraints] -. policies .-> Pod
  NP[NetworkPolicy] -. filtre trafic .-> Pod
```
**Principes**
- **RBAC**: Role/RoleBinding donnent au ServiceAccount les droits API.
- **SCC**: cadre d’exécution (uid, capabilities, privileged). Par défaut `restricted`.
- **NetworkPolicy**: autorise/limite les flux L3/L4 entre namespaces/pods.

---

## 5) Stockage: claims, volumes, classes
```mermaid
flowchart TB
  Pod --> PVC[PersistentVolumeClaim]
  PVC --> PV[PersistentVolume]
  SC[StorageClass] --> PV
```
**Règles**
- **RWO/RWX** selon le driver de stockage.
- `StorageClass` provisionne dynamiquement les PV utilisés par les PVC.

---

## 6) Autoscaling: HPA
```mermaid
sequenceDiagram
  autonumber
  participant Metrics as Metrics Server/Prometheus
  participant HPA as HPA
  participant DEP as Deployment

  Metrics-->>HPA: CPU/Memory/Custom metrics
  HPA->>DEP: scale replicas up/down
```
**Bonnes pratiques**
- Définir **requests/limits** sur Pods. HPA scale sur métriques cibles.

---

## 7) GitOps: Argo CD déploie l’état Git
```mermaid
sequenceDiagram
  autonumber
  participant Dev as Dev (PR/commit)
  participant Git as Git repo (manifests/Helm)
  participant Argo as Argo CD
  participant API as API Server
  participant DEP as Deployment

  Dev->>Git: push
  Argo->>Git: poll/notify
  Argo->>API: apply manifests
  API->>DEP: create/update
  Argo-->>Dev: health/sync status
```
**Idées**
- Git = source de vérité. Pas d’`oc apply` manuel en prod.
- Promotion par PR/merge entre branches (dev -> preprod -> prod).

---

## 8) CI et pipeline (Tekton ou autre) -> Registry -> Déploiement
```mermaid
sequenceDiagram
  autonumber
  participant CI as Pipeline (Tekton/Jenkins)
  participant REG as Internal Registry
  participant IS as ImageStream
  participant Argo as Argo CD (auto-sync)

  CI->>REG: build & push image:tag
  REG->>IS: update tag
  IS-->>Argo: drift détecté (via Git tag update ou values)
  Argo->>Cluster: sync rollout
```
**Options**
- Tag immuable par commit (`app:1.2.3+sha`), ou digest SHA.
- Argo CD peut consommer Helm/Kustomize; l’IS peut rester interne au cluster.

---

## 9) Contrôles de plateforme dans le projet
- **Quotas/LimitRange**: encadrent CPU/Mem/objets.
- **Policies**: PodSecurityAdmission/SCC, NetworkPolicy, signatures d’images.
- **Secrets**: pull secrets vers registries privés.

---

## 10) Check-list rapide (CRC)
- Route/Ingress resolus (FQDN). Service exposé. Probes OK.
- Image présente dans le **registry interne**. IS pointe sur le bon tag.
- RBAC correct pour ServiceAccount. SCC par défaut `restricted`.
- PVC liés si volume requis. Quotas/limits définis.
- HPA actif si charge variable. Argo CD en sync si GitOps.

