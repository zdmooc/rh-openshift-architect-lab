# Chapitre 6 – Registry, Monitoring et Logging (Loki) sur ODF

## 6.1. Registry interne

L'objectif est de faire pointer la registry interne sur une StorageClass ODF.

- Modifier la config `configs.imageregistry.operator.openshift.io/cluster`.
- Basculer sur un PVC utilisant la StorageClass ODF.

YAML d'exemple : `labs/04-registry-monitoring-lokistack/registry-config-patch.yaml`.

## 6.2. Monitoring

Le monitoring OpenShift (Prometheus, Alertmanager, Thanos) peut utiliser ODF.

- Modifier la configuration pour utiliser un PVC ODF.
- Vérifier la consommation de storage.

Exemple : `labs/04-registry-monitoring-lokistack/monitoring-storage-patch.yaml`.

## 6.3. Logging avec LokiStack

- Déployer LokiStack via Operator ou Helm.
- Configurer les `LokiStack` CR pour utiliser une StorageClass ODF.

Exemple de valeurs : `labs/04-registry-monitoring-lokistack/lokistack-values-example.yaml`.
