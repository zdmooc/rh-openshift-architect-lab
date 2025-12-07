#!/usr/bin/env bash
set -euo pipefail

NS=${1:-ex370-file-block-test}
echo "=== Création du namespace ${NS} ==="
oc new-project "${NS}" || oc project "${NS}"

echo "=== Application des PVC et Deployments ==="
oc apply -f labs/03-file-block-nfs/pvc-samples.yaml -n "${NS}"
oc apply -f labs/03-file-block-nfs/deployment-cephfs.yaml -n "${NS}"
oc apply -f labs/03-file-block-nfs/deployment-rbd.yaml -n "${NS}"

echo "=== Ressources créées ==="
oc get pvc,pods -n "${NS}"
