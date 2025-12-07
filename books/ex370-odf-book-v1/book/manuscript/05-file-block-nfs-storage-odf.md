# Chapitre 5 – File / Block / NFS Storage avec ODF

## 5.1. StorageClass ODF

Après installation, tu dois voir typiquement :

- `ocs-storagecluster-ceph-rbd` (block, RWO).
- `ocs-storagecluster-cephfs` (file, RWX).

Utilise :

```bash
oc get storageclass
```

pour les lister avec leurs paramètres.

## 5.2. PVC File (CephFS)

- Utilisé pour les workloads qui partagent des fichiers entre pods.

Exemple dans `labs/03-file-block-nfs/pvc-samples.yaml`.

## 5.3. PVC Block (RBD)

- Utilisé pour les bases de données ou workloads à fort I/O.

Exemple dans `labs/03-file-block-nfs/deployment-rbd.yaml`.

## 5.4. StorageClass custom

- Changer `reclaimPolicy` (Retain/Delete).
- Activer `allowVolumeExpansion: true` pour permettre l'extension des PVC.

Exemple : `labs/03-file-block-nfs/storageclass-custom.yaml`.
