#!/usr/bin/env bash
set -euo pipefail

echo "=== Labelliser les nœuds de stockage (adapter les noms) ==="
# oc label node <node1> cluster.ocs.openshift.io/openshift-storage=''
# oc label node <node2> cluster.ocs.openshift.io/openshift-storage=''
# oc label node <node3> cluster.ocs.openshift.io/openshift-storage=''

echo "=== Installer la Subscription ODF (si nécessaire) ==="
oc apply -f operator-subscription.yaml

echo "=== Créer le StorageCluster ==="
oc apply -f storagecluster-sample.yaml

echo "=== Vérifications ==="
oc get pods -n openshift-storage
oc get storageclass
