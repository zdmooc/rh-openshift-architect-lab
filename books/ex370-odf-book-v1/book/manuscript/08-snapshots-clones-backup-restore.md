# Chapitre 8 – Snapshots, clones, backup/restore

## 8.1. VolumeSnapshotClass

- Permet de définir la manière dont les snapshots sont créés pour une StorageClass.

Exemple : `labs/06-snapshots-and-clones/volumesnapshotclass.yaml`.

## 8.2. VolumeSnapshot

- Snapshot ponctuel d'un PVC donné.

Exemple : `labs/06-snapshots-and-clones/volumesnapshot-example.yaml`.

## 8.3. Clones de PVC

- Créer un nouveau PVC à partir d'un snapshot ou d'un PVC existant.

Exemple : `labs/06-snapshots-and-clones/cloned-pvc.yaml`.

## 8.4. Scénario type examen

1. Déployer une app qui écrit des données sur un PVC.
2. Créer un snapshot du PVC.
3. Corrompre volontairement les données.
4. Revenir à un état sain via clone ou restore.
