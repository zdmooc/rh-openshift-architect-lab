# Structure GitOps

Objectif : définir une structure simple de dépôt Git pour piloter tes déploiements
en mode GitOps, quelle que soit la certification travaillée.

Exemple de structure pour un produit applicatif :

```text
product-x/
  base/
    kustomization.yaml
    namespace.yaml
    rbac.yaml
    deployment.yaml
    service.yaml
    route.yaml
  overlays/
    dev/
      kustomization.yaml
      values-dev.yaml (si Helm)
    rec/
      kustomization.yaml
      values-rec.yaml
    prod/
      kustomization.yaml
      values-prod.yaml
```

Tu peux réutiliser cette structure dans :
- `ex288-appdev/` pour les applications,
- `ex380-automation-integration/` pour les pipelines et opérateurs,
- `ex370-odf/` pour les composants storage,
- `ex480-multicluster/` pour les déploiements multi‑cluster,
- `ex482-kafka/` pour la stack Kafka et les microservices event‑driven.
