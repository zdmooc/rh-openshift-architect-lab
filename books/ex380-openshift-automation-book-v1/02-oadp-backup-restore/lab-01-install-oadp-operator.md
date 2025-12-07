# LAB-02-01 – Installer OADP et préparer un backend S3

- **Bloc** : OADP Backup/Restore
- **Durée cible** : 60 min

## 1. Objectifs

- Installer l’Operator **OpenShift API for Data Protection (OADP)**.
- Configurer un backend S3 (MinIO ou autre).
- Créer une ressource `DataProtectionApplication` minimale.

## 2. Pré-requis

- Cluster OCP 4.14+ avec accès cluster-admin.
- Namespace pour OADP : `openshift-adp` (par défaut).
- Un endpoint S3 (MinIO dans un namespace `minio` par exemple).

## 3. Énoncé

1. Installe l’Operator OADP dans le namespace `openshift-adp`.
2. Crée un Secret avec les credentials S3.
3. Crée une ressource `DataProtectionApplication` (DPA) simple pointant sur ton S3.

## 4. Installation OADP Operator

```bash
oc new-project openshift-adp || true

cat <<'EOF' | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-adp
  namespace: openshift-adp
spec:
  targetNamespaces:
  - openshift-adp
EOF
```

Subscription :

```bash
cat <<'EOF' | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: redhat-oadp-operator
  namespace: openshift-adp
spec:
  channel: stable-1.4
  name: redhat-oadp-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

Vérifier :

```bash
oc get csv -n openshift-adp
```

## 5. Secret S3

```bash
oc create secret generic cloud-credentials -n openshift-adp   --from-literal=aws_access_key_id=MINIO_ACCESS_KEY   --from-literal=aws_secret_access_key=MINIO_SECRET_KEY
```

## 6. DataProtectionApplication

```bash
cat <<'EOF' | oc apply -f -
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: oadp-s3
  namespace: openshift-adp
spec:
  backupLocations:
  - velero:
      provider: aws
      default: true
      objectStorage:
        bucket: ex380-backups
        prefix: cluster1
      config:
        region: minio
        s3Url: http://minio.minio.svc:9000
        s3ForcePathStyle: "true"
      credential:
        name: cloud-credentials
        key: cloud
  configuration:
    velero:
      defaultPlugins:
      - openshift
      - aws
      - csi
EOF
```

Vérifier :

```bash
oc get dpa -n openshift-adp
oc describe dpa oadp-s3 -n openshift-adp
```

## 7. Points clés

- OADP s’installe via Operator + ressource `DataProtectionApplication`.
- Backend S3 déclaré dans `backupLocations`.
- Les credentials S3 sont dans un Secret référencé par la DPA.
