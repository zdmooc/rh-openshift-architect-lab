# Chapitre 10 – RBAC, SCC et sécurité autour du storage

## 10.1. RBAC sur le storage

- Limiter qui peut créer/modifier/supprimer des PVC/PV/StorageClass.
- Utiliser Role/RoleBinding sur les ressources de storage.

Exemple : `labs/08-rbac-scc-secrets/role-storage-admin.yaml`.

## 10.2. ServiceAccounts et SCC

- Les pods qui montent des volumes peuvent nécessiter une SCC spécifique.
- Attacher la SCC à une ServiceAccount dédiée.

## 10.3. Secrets de credentials

- Pour l'object storage (OBC/S3), les creds sont dans un Secret.
- Monte ce Secret dans un pod (envVars ou volume) pour le client S3.

Exemple : `labs/08-rbac-scc-secrets/s3-credentials-secret.yaml`.
