#!/usr/bin/env bash
set -euo pipefail
NS="lab-helm"

echo "[Pods]"
oc -n "${NS}" get pods -o wide

echo -e "\n[Services]"
oc -n "${NS}" get svc

echo -e "\n[Routes]"
oc -n "${NS}" get route
echo -e "\nTester l’URL dans un navigateur une fois READY."
