```mermaid
flowchart LR
  BC[BuildConfig]
  TR[Triggers]
  SRC[Source Git ou binaire]
  STRAT[Strategie de build]
  B[Build]
  BP[Pod de build]
  SA[ServiceAccount]
  IMG[Image registre interne]
  IST[ImageStreamTag]
  IS[ImageStream]
  DEP[Deployment ou DeploymentConfig]

  BC --> TR
  BC --> B
  B --> SRC
  B --> STRAT
  B --> SA
  B --> BP
  BP --> IMG
  IMG --> IST
  IST --> IS
  IST --> DEP

