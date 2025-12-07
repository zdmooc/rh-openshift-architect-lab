# EX370 – Checklist des objectifs d'examen

Coche chaque ligne lorsque tu te sens capable d'exécuter la tâche **en moins de 10 minutes** sans aide.

## 1. Gestion de base OpenShift

- [ ] Lister/afficher les nœuds, projets, pods, events, logs.
- [ ] Créer/supprimer un projet avec `oc new-project` / `oc delete project`.
- [ ] Créer un Deployment + Service + Route à partir d'une image existante.
- [ ] Modifier un objet via YAML (`oc edit`, `oc apply -f`).
- [ ] Utiliser `oc explain` pour comprendre un champ.

## 2. Installation et validation d'ODF

- [ ] Identifier les nœuds éligibles pour ODF et les labelliser.
- [ ] Installer ODF via OperatorHub ou YAML de Subscription.
- [ ] Créer un `StorageCluster` en Internal Mode.
- [ ] Vérifier la santé du cluster ODF (pods, StorageClass, dashboard).
- [ ] Lister et reconnaître les StorageClass ODF (CephFS, RBD, Object).

## 3. File / Block / NFS

- [ ] Créer un PVC File et l'utiliser dans une application.
- [ ] Créer un PVC Block et l'utiliser dans une application.
- [ ] Choisir la bonne StorageClass selon le besoin (RWX vs RWO).
- [ ] Créer un StorageClass custom (reclaimPolicy, allowVolumeExpansion).

## 4. Registry / Monitoring / Loki

- [ ] Configurer la registry interne pour utiliser ODF.
- [ ] Configurer le monitoring pour stocker les données sur ODF.
- [ ] Déployer LokiStack avec stockage sur ODF.
- [ ] Vérifier consommation de stockage de ces composants.

## 5. Capacité, quotas, extensions

- [ ] Définir des ResourceQuota pour limiter la consommation de PV/PVC.
- [ ] Définir des LimitRange pour fixer les tailles minimales/maximales.
- [ ] Étendre la taille d'un PVC existant (et vérifier dans la VM/pod).
- [ ] Ajouter des disques à un nœud de stockage et les intégrer dans ODF.

## 6. Snapshots, clones, backup/restore

- [ ] Créer une `VolumeSnapshotClass` ODF.
- [ ] Créer une `VolumeSnapshot` pour un PVC donné.
- [ ] Créer un clone de PVC à partir d'un snapshot ou d'un PVC.
- [ ] Construire un scénario de corruption + rollback avec snapshot/clone.

## 7. Object Storage

- [ ] Créer une `ObjectBucketClaim` (OBC).
- [ ] Récupérer endpoint + credentials depuis les Secrets/ConfigMap OBC.
- [ ] Configurer `s3cmd` ou équivalent pour écrire/lire dans le bucket.
- [ ] Contrôler les accès au bucket via RBAC.

## 8. Sécurité et RBAC

- [ ] Créer un Role et RoleBinding limitant l'accès aux PVC/PV/StorageClass.
- [ ] Créer une ServiceAccount dédiée à une application qui monte des volumes.
- [ ] Associer une SCC adaptée à la ServiceAccount (fichiers montés en RW).
- [ ] Stocker les credentials S3 dans un Secret monté dans le pod.

## 9. Troubleshooting

- [ ] Diagnostiquer un pod en Pending lié au storage (events, describe).
- [ ] Diagnostiquer un PV/PVC en état `Lost` ou `Failed`.
- [ ] Diagnostiquer une erreur de montage (permissions, path, quota).
- [ ] Utiliser le dashboard ODF pour identifier un problème de capacité.
