#!/usr/bin/env bash
set -euo pipefail

echo "=== StorageClass ODF (filtrage simple) ==="
oc get storageclass | egrep 'ocs|ceph|noobaa' || oc get storageclass
