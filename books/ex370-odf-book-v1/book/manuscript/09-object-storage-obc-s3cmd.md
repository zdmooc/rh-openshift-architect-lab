# Chapitre 9 – Object Storage : OBC & s3cmd

## 9.1. Concepts

- ODF expose un stockage objet compatible S3 via NooBaa/RGW.
- L'accès se fait via des Object Bucket Claims (OBC).

## 9.2. ObjectBucketClaim

- Création d'un OBC → création d'un bucket + credentials associés.
- Les credentials sont stockés dans un Secret + ConfigMap.

Exemple : `labs/07-object-storage-obc-s3cmd/obc-sample.yaml`.

## 9.3. Client S3 (s3cmd)

- Installer `s3cmd` dans un pod ou sur une machine d'admin.
- Configurer `~/.s3cfg` à partir des creds OBC.

Exemple de config : `labs/07-object-storage-obc-s3cmd/s3cmd-example.conf`.

## 9.4. Scénario type examen

- Créer un OBC pour un projet donné.
- Configurer un client S3 pour écrire des fichiers dans le bucket.
- Vérifier que les données sont effectivement présentes.
