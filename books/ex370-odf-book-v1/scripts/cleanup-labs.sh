#!/usr/bin/env bash
set -euo pipefail

echo "=== Suppression des projets de labo EX370 (si présents) ==="
for ns in ex370-lab01 ex370-capacity ex370-obc ex370-file-block-test ex370-mock; do
  oc delete project "${ns}" --ignore-not-found
done
