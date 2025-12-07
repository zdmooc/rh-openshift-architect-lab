#!/usr/bin/env bash
set -euo pipefail

echo "=== Storage pods (openshift-storage) ==="
oc get pods -n openshift-storage

echo "=== StorageClass ==="
oc get storageclass

echo "=== CephCluster (si CRD présent) ==="
oc get cephcluster -n openshift-storage 2>/dev/null || echo "Pas de CRD cephcluster"
