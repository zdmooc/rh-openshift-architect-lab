# Chapitre 1 – Introduction EX370 & stockage OpenShift

## 1.1. Contexte de l'examen EX370

- Examen pratique, durée typiquement 3 h, sur un cluster OpenShift avec ODF installé.
- Tu dois être capable de :
  - Comprendre les briques ODF (Ceph, NooBaa, etc.).
  - Configurer le stockage pour les workloads applicatifs.
  - Gérer la capacité, la sécurité, la résilience (snapshots, clones).
  - Diagnostiquer les principaux problèmes de storage en production.

## 1.2. Rôle d'OpenShift Data Foundation

ODF fournit une couche de **stockage logiciel (software-defined storage)** pour OpenShift :

- Stockage **bloc** (RBD) pour bases de données et workloads exigeants.
- Stockage **fichier** (CephFS) pour workloads partageant des fichiers entre pods.
- Stockage **objet** (NooBaa/S3) pour backups, archives, artefacts, logs.

Le tout est intégré nativement à OpenShift via :

- Des **StorageClass** (dynamic provisioning).
- Des **PersistentVolume (PV)** et **PersistentVolumeClaim (PVC)**.
- Des contrôleurs opérés par l'operator ODF.

## 1.3. Positionnement par rapport à EX280/EX288

- EX280 : focus sur l'administration OpenShift (projets, routes, sécurité, etc.).
- EX288 : focus sur le développement applicatif (templates, Helm, pipelines, GitOps).
- EX370 : focus sur **le stockage** :
  - comment les apps consomment le storage ODF ;
  - comment les services de cluster s'appuient sur ODF ;
  - comment assurer disponibilité et intégrité des données.

## 1.4. Objectifs de ce dépôt

- Te fournir une structure complète de révision.
- Centraliser notes, labs, commandes et YAML fréquents.
- Servir de base pour créer ton propre book/exam blanc.
