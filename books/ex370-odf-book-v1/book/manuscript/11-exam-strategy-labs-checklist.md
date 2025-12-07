# Chapitre 11 – Stratégie d'examen & labs

## 11.1. Stratégie générale

- Lire rapidement tous les énoncés avant de commencer.
- Identifier les tâches rapides/évidentes (gagner des points rapidement).
- Toujours noter les commandes importantes dans un fichier texte dans ton home.
- Vérifier régulièrement l'état du cluster et de la santé ODF.

## 11.2. Parcours recommandé

1. Valider que l'operator ODF et le StorageCluster sont en bonne santé.
2. Configurer storage pour registry/monitoring/logging si demandé.
3. Gérer les PVC/PV pour les applications (file/block).
4. Traiter snapshots/clones si demandés.
5. Configurer object storage (OBC/S3) si présent dans l'énoncé.
6. Terminer par les optimisations/quota/RBAC si le temps le permet.

## 11.3. Labs du dépôt

- `labs/01-ocp-refresh` : rappels OpenShift.
- `labs/02-install-odf-internal-mode` : installation ODF.
- `labs/03-file-block-nfs` : PVC File/Block.
- `labs/04-registry-monitoring-lokistack` : services de cluster.
- `labs/05-capacity-and-extensions` : quotas, extension de PVC.
- `labs/06-snapshots-and-clones` : snapshots & clones.
- `labs/07-object-storage-obc-s3cmd` : OBC + S3.
- `labs/08-rbac-scc-secrets` : sécurité.
- `labs/09-mock-exam-ex370` : exam blanc 3 h.

Utilise la checklist `00-meta/EXAM_OBJECTIVES_CHECKLIST.md` pour suivre ta progression.
