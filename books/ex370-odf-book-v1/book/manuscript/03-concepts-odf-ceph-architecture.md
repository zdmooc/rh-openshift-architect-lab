# Chapitre 3 – Concepts ODF & architecture Ceph

## 3.1. Modes de déploiement ODF

- **Internal Mode** : ODF gère directement les disques des nœuds OpenShift.
- **External Mode** : ODF s'appuie sur un cluster Ceph déjà existant.

Pour l'examen, on part en général sur **Internal Mode**.

## 3.2. Composants principaux

- **Ceph Monitors (MON)** : maintiennent la carte du cluster.
- **Ceph OSD** : stockent les données sur les disques.
- **Ceph MGR** : services de gestion/monitoring.
- **CephFS** : filesystem distribué (RWX).
- **RBD (RADOS Block Device)** : volumes block (RWO).
- **RGW (Rados Gateway)** : accès objet S3 compatible.
- **NooBaa** : couche d'abstraction objet/multi-cloud.

## 3.3. Intégration OpenShift

ODF expose du stockage via :

- Des **StorageClass** (par ex. `ocs-storagecluster-ceph-rbd`, `cephfs`).
- Des drivers CSI pour provisionner dynamiquement PV/PVC.

Les workloads n'ont pas besoin de connaître Ceph : ils consomment des PVC.

## 3.4. Diagramme d'architecture

Le fichier `images/odf-architecture-internal-mode.drawio` contient un diagramme
d'exemple à ouvrir avec Draw.io :

- Nœuds de stockage OpenShift.
- Pods ODF (rook-ceph, noobaa, etc.).
- Pools Ceph et StorageClass associés.
- Workloads applicatifs et services de cluster (registry, monitoring, logging).
