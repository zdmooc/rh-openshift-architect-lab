#!/usr/bin/env bash
set -euo pipefail
RELEASE="lab-helm"
NS="lab-helm"

echo "[1/4] Désinstallation Helm"
helm uninstall "${RELEASE}" -n "${NS}" || true

echo "[2/4] Attendre la suppression des ressources"
sleep 5

echo "[3/4] Nettoyage objets résiduels"
oc -n "${NS}" delete pvc --all 2>/dev/null || true
oc -n "${NS}" delete route --all 2>/dev/null || true
oc -n "${NS}" delete sa odm-dev-sa 2>/dev/null || true

echo "[4/4] Conserver le projet ${NS}. Supprimer si besoin:"
echo "  oc delete project ${NS}"
