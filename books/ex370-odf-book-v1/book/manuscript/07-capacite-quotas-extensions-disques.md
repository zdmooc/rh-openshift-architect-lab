# Chapitre 7 – Capacité, quotas, extension de volumes

## 7.1. Vue capacité ODF

- Dashboard ODF : pools Ceph, utilisation, alertes.
- `oc get cephcluster` / `ceph status` (via toolbox).

## 7.2. Quotas et LimitRange

- `ResourceQuota` : limiter nombre/tailles PVC.
- `LimitRange` : imposer une taille minimale/maximale par PVC.

Exemples : `labs/05-capacity-and-extensions/quota-examples.yaml`.

## 7.3. Extension de PVC

Pré-requis :

- StorageClass avec `allowVolumeExpansion: true`.

Étapes :

1. Modifier `spec.resources.requests.storage` du PVC.
2. Vérifier l'état du PVC.
3. Vérifier la taille dans le pod (ex : `df -h` ou commande équivalente).

Exemple : `labs/05-capacity-and-extensions/pvc-expand-example.yaml`.

## 7.4. Ajout de disques

- Ajouter des disques aux nœuds de stockage.
- Laisser ODF les intégrer automatiquement (selon configuration).

Dans un contexte d'examen, cela peut se limiter à reconnaître une configuration
déjà en place plutôt qu'à manipuler l'infra sous-jacente.
