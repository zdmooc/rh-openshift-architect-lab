#!/usr/bin/env bash
set -euo pipefail
NS=${1:-ex288}
echo "[NS] $NS";
oc get is,bc,build -n "$NS" || true
oc get dc,svc,route -n "$NS" || true
oc get pods -n "$NS" -o wide || true
if command -v curl >/dev/null 2>&1; then host=$(oc get route ex288 -n "$NS" -o jsonpath='{.spec.host}' 2>/dev/null || true); [ -n "$host" ] && echo "curl https://$host" && curl -ks https://"$host" | head -n1; fi
