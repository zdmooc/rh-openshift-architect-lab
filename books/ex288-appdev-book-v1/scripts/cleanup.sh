#!/usr/bin/env bash
set -euo pipefail
NS=${1:-ex288}
oc delete all,cm,secret,pvc -l app=ex288 -n "$NS" --ignore-not-found
oc delete all,cm,secret,route,svc,dc,is,bc,pvc -n "$NS" --ignore-not-found -l app=app2 || true
