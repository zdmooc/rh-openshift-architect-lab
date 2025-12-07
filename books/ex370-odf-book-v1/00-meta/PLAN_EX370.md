# Plan de préparation EX370 – OpenShift Data Foundation

## Hypothèses

- Niveau Linux équivalent RHCSA (EX200).
- Niveau OpenShift équivalent EX280 (admin cluster, CLI).
- Accès à un cluster OpenShift 4.x avec ressources suffisantes pour ODF (3 nœuds de stockage).

## Vue globale

- **Semaine 1** : Révision OpenShift ciblée + installation ODF (Internal Mode).
- **Semaine 2** : Storage (File / Block / NFS) + Registry + Monitoring + Loki + capacité.
- **Semaine 3** : Object Storage (OBC) + RBAC/Sécurité + Exam blanc.

Chaque semaine est organisée en :

- Bloc A (2 h) : labs pratiques "build/deploy" (résultat visible).
- Bloc B (2 h) : administration / troubleshooting / capacité.
- Bloc C (2 h) : drills chronométrés + notes dans le dépôt.

## Détail par semaine

### Semaine 1 – OCP Refresh + Installation ODF

- Révisions CLI OpenShift (oc get/describe, events, logs, exec).
- Rappels sur projets/namespaces, quotas, LimitRange.
- Concepts ODF : Internal/External Mode, Ceph, NooBaa, CephFS/RBD/RGW.
- Installation de l'operator ODF via OperatorHub.
- Création du StorageCluster en Internal Mode.
- Vérification de la santé du cluster ODF (pods, StorageClass, dashboard).

Labs associés :
- `labs/01-ocp-refresh`
- `labs/02-install-odf-internal-mode`

### Semaine 2 – File/Block/NFS + services de cluster + capacité

- Identification et usage des StorageClass ODF (CephFS/RBD).
- Déploiement d'applications utilisant PVC File et Block.
- Configuration de la registry interne sur ODF.
- Configuration du monitoring (Prometheus/Alertmanager/Thanos) sur ODF.
- Déploiement de LokiStack (logging) avec stockage ODF.
- Gestion de la capacité : quotas, LimitRange, extension de PVC, ajout de disques.
- Snapshots, clones de PVC, scénarios de corruption/rollback.

Labs associés :
- `labs/03-file-block-nfs`
- `labs/04-registry-monitoring-lokistack`
- `labs/05-capacity-and-extensions`
- `labs/06-snapshots-and-clones`

### Semaine 3 – Object Storage + Sécurité + Exam blanc

- Concepts Object Storage ODF (NooBaa, MCG, bucket class).
- Création et utilisation de ObjectBucketClaim (OBC).
- Configuration d'un client S3 (s3cmd) avec OBC.
- RBAC sur les ressources de stockage (Roles/RoleBindings).
- SCC et ServiceAccounts pour workloads utilisant des volumes.
- Sécurité des credentials S3 (Secrets).
- Troubleshooting avancé.
- Exam blanc 3 h (lab 09).

Labs associés :
- `labs/07-object-storage-obc-s3cmd`
- `labs/08-rbac-scc-secrets`
- `labs/09-mock-exam-ex370`
