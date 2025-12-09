```mermaid
sequenceDiagram
  autonumber
  participant Dev
  participant Git
  participant API
  participant BC
  participant Build
  participant Pod as BuildPod
  participant Reg as Registry
  participant IS as ImageStreamTag
  participant Dep as Deployment

  Dev->>Git: push
  Git->>API: webhook
  API->>BC: matcher le hook
  BC->>API: démarrer un build
  API->>Build: créer l’objet Build
  Build->>Pod: lancer BuildPod
  Pod->>Reg: push image tag
  Reg->>IS: mise à jour du tag
  IS-->>Dep: trigger ImageChange
  Dep->>Dep: rollout
