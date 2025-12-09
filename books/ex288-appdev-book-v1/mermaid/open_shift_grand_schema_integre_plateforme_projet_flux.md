# OpenShift — Grand Schéma Intégré (Plateforme + Projet + Flux)

But : regrouper en un seul document les couches de la plateforme, les variantes de topologie, l’architecture d’un projet, et les séquences clés (réseau, images, CI/CD, GitOps, sécurité, stockage).

---

## 1) Couches OpenShift (bas → haut)
```mermaid
flowchart TB
  subgraph L1["Infra"]
    HW["HW/Cloud + LB + DNS + NTP"]
  end
  subgraph L2["Control Plane"]
    APIS["API Server"] --> ETCD["etcd x3"]
    CM["Controller Manager"] --> APIS
    SCH["Scheduler"] --> APIS
    CVO["Cluster Version Operator"] --> APIS
    MCO["Machine Config Operator"] --> NCFG["Node config"]
  end
  subgraph L3["Services de cluster"]
    ING["IngressController"]
    DNS["DNS"]
    NET["OVN-K + Multus"]
    OAUTH["OAuth"]
    REG["Image Registry"]
    OLM["OLM / Operators"]
    CON["Console"]
    MON["Monitoring"]
    LOG["Logging"]
  end
  subgraph L4["Projets (namespaces)"]
    GOV["RBAC + SCC + Quotas + LimitRanges + NetworkPolicy"]
    BUILD["BuildConfig + ImageStream"]
    DEP["Deployment/DeploymentConfig + Routes/Ingress"]
    DATA["PVC/PV/StorageClass"]
  end
  subgraph L5["Livraison"]
    GITOPS["Argo CD"]
    PIPE["Tekton Pipelines"]
  end
  subgraph L6["Workloads"]
    APPS["Apps: ODM, Keycloak, Grafana, …"]
  end

  HW --> L2
  L2 --> L3
  L3 --> L4
  GITOPS --> L4
  PIPE --> L4
  L4 --> L6
```

---

## 2) Variantes de topologie
```mermaid
flowchart TB
  A[SNO] -->|1 nœud| SNO[CP+Worker]
  B[Compact] -->|3 nœuds| C1[Node1 CP+W] --- C2[Node2 CP+W] --- C3[Node3 CP+W]
  C[Standard] -->|3 CP + N W| CP1[CP1] --- CP2[CP2] --- CP3[CP3]
  CP3 --> W1[Worker1] --- W2[Worker2] --- Wn[WorkerN]
  D[Hosted Control Planes] --> HCP[Control planes hébergés] --> HCW[Clusters de workers]
```

---

## 3) CRC : 1 nœud tout‑en‑un
```mermaid
flowchart TB
  subgraph CRC["CRC : 1 nœud tout-en-un"]
    direction TB
    Clients[oc / Console] -->|TLS| APIS[API Server]
    ET[etcd] --- APIS
    CM[Controller Manager] --> APIS
    SCH[Scheduler] --> APIS
    APIS --> Kubelet[Kubelet]
    subgraph Node_crc["Node crc"]
      Kubelet -.-> PodsSys[Pods système]
      Kubelet -.-> Router[Ingress / Router]
      Kubelet -.-> DNS[CoreDNS]
      Kubelet -.-> OVN[OVN-Kubernetes CNI]
      Kubelet -.-> Registry[Image Registry]
      Kubelet -.-> OAuth[OAuth / Auth]
      Kubelet -.-> Apps[Pods apps: ODM, Grafana, Keycloak]
    end
  end
```



---

## 5) Architecture d’un projet (namespace)
```mermaid
flowchart TB
  subgraph Project["OpenShift Project (Namespace)"]
    Route[Route] --> Svc[Service]
    Ingress[Ingress] -. optionnel .-> Svc
    Svc --> Pod[Pod]

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

  SCC[SecurityContextConstraints] -. admission .-> SA
  RB[RoleBinding] --> Role[Role]
  RB --> SA

  PVC --> PV[PersistentVolume]
  SC[StorageClass] --> PV

  Registry[Internal Image Registry] --> IS
```

---

## 6) Contexte `oc` et rattachement au projet
```mermaid
flowchart TB
  Context["oc context = {cluster, user, project}"] --> Cluster["Cluster OCP"]
  Context --> ProjectCurrent["Projet courant (namespace)"]

  subgraph Cluster
    API[API Server]:::cp --> ETCD[etcd]:::cp
    API --> Sched[Scheduler]:::cp
    API --> CtlMgr[Controller Manager]:::cp
    API --> Nodes[Workers/Infra]
  end

  subgraph ProjectCurrent["Projet (Namespace)"]
    Policy[RBAC + SCC + Quotas + LimitRanges]
    Net[NetworkPolicy]
    Img[ImageStreams]
    Res[Deployments/StatefulSets/Services/Routes]
    Sec[Secrets/ConfigMaps/SA]
  end

  API --> ProjectCurrent
  Policy --> Res
  Net --> Res
  Img --> Res
  Sec --> Res

  classDef cp fill:#eef,stroke:#336,stroke-width:1px;
```

---

# Séquences clés

## 7) Trafic entrant : Route/Ingress → Service → Pod
```mermaid
sequenceDiagram
  autonumber
  participant U as User
  participant Route as Route
  participant Ingress as Ingress Controller
  participant SVC as Service (ClusterIP)
  participant POD as Pod
  U->>Route: HTTPS
  Route->>Ingress: handoff
  Ingress->>SVC: routage
  SVC->>POD: proxy vers endpoint
  POD-->>U: 200 OK
```

## 8) Build → Registry → Déploiement (ImageStream trigger)
```mermaid
sequenceDiagram
  autonumber
  participant Dev as Dev
  participant BC as BuildConfig
  participant REG as Internal Registry
  participant IS as ImageStream
  participant DEP as Deployment
  participant RS as ReplicaSet
  participant POD as Pod
  Dev->>BC: trigger build (webhook/manuel)
  BC->>REG: push image:tag
  REG->>IS: update tag
  IS-->>DEP: imageChange trigger
  DEP->>RS: new ReplicaSet
  RS->>POD: create Pods
```

## 9) Mirroring d’une image externe vers le registry interne
```mermaid
sequenceDiagram
  autonumber
  participant EXT as Registry externe
  participant CLI as skopeo/oc/podman
  participant ROUTE as Route registry
  participant REG as Pod registry
  participant PV as Stockage
  CLI->>EXT: pull source:tag
  CLI->>ROUTE: login (token)
  CLI->>ROUTE: push dest:tag
  ROUTE->>REG: transfert
  REG->>PV: write layers/manifests
```

## 10) GitOps : Argo CD applique l’état Git
```mermaid
sequenceDiagram
  autonumber
  participant Dev as Dev (PR/commit)
  participant Git as Repo manifests/Helm
  participant Argo as Argo CD
  participant API as API Server
  participant K8s as Objects (Deploy/Service…)
  Dev->>Git: push
  Argo->>Git: watch
  Argo->>API: apply
  API->>K8s: create / update
  Argo-->>Dev: Health / Sync
```

## 11) CI externe (Tekton/Jenkins) → Registry → GitOps
```mermaid
sequenceDiagram
  autonumber
  participant CI as Pipeline
  participant REG as Registry
  participant Git as Git repo
  participant Argo as Argo CD
  CI->>REG: build & push image:tag/digest
  CI->>Git: bump tag/values.yaml
  Argo->>Git: detect change
  Argo->>Cluster: sync rollout
```

## 12) OAuth : login et token
```mermaid
sequenceDiagram
  autonumber
  participant User as oc/Console
  participant OAuth as OAuth Server
  participant API as API Server
  User->>OAuth: login (IDP)
  OAuth-->>User: token
  User->>API: bearer token
  API-->>User: accès autorisé (RBAC)
```

## 13) OLM : installation d’un Operator
```mermaid
sequenceDiagram
  autonumber
  participant Admin as Admin
  participant Cat as CatalogSource
  participant Sub as Subscription
  participant OLM as OLM
  participant CSV as ClusterServiceVersion
  Admin->>Sub: créer Subscription
  OLM->>Cat: résout bundle
  OLM->>CSV: installe CRDs/Operator
  OLM-->>Admin: Operator Ready
```

## 14) Provisioning dynamique : PVC → PV via StorageClass
```mermaid
sequenceDiagram
  autonumber
  participant Pod as Pod
  participant PVC as PVC
  participant SC as StorageClass
  participant Prov as CSI provisioner
  participant PV as PV
  Pod->>PVC: mount claim
  PVC->>SC: demande provisionnement
  SC->>Prov: provision
  Prov->>PV: crée volume
  PV-->>PVC: bound
  PVC-->>Pod: volume prêt
```

## 15) HPA : autoscaling horizontal
```mermaid
sequenceDiagram
  autonumber
  participant Metrics as Metrics/Prometheus
  participant HPA as HPA
  participant DEP as Deployment
  Metrics-->>HPA: métriques CPU/RAM/custom
  HPA->>DEP: scale up/down replicas
```

## 16) Admission : RBAC + SCC → création du Pod
```mermaid
sequenceDiagram
  autonumber
  participant User as User
  participant API as API Server
  participant RBAC as RBAC
  participant SCC as SCC Admission
  participant Kubelet as Kubelet
  User->>API: create Pod
  API->>RBAC: vérif permissions
  RBAC-->>API: ok
  API->>SCC: validate security context
  SCC-->>API: ok (ou rejet)
  API-->>Kubelet: schedule/start
```

---

## 17) Rappels pratiques
- En DEV local CRC : registry via **route par défaut** pour push depuis le poste, endpoint **svc:5000** pour pull in‑cluster.
- En PROD : séparer **nœuds infra** (ingress/registry/monitoring) et **workers**.
- GitOps : Git = vérité. Aucune modification manuelle en PROD.
- Sécurité : SCC `restricted` par défaut, RBAC minimal, NetworkPolicy « deny‑all » + allowlist.
- Images : mirror des bases, Dockerfile dérivé pour custom, scan vuln.
- Stockage : choisir les `StorageClass` selon RWO/RWX et performance.

