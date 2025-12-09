# Lab 02 — Déployer DC + SVC + Route + CM

oc apply -n ex288 -f manifests/cm-secret-pvc.yaml
oc apply -n ex288 -f manifests/dc-svc-route.yaml

## Attendre
oc rollout status dc/ex288 -n ex288

## Vérif
oc get dc,svc,route,pod -n ex288
curl -k https://$(oc get route ex288 -n ex288 -o jsonpath='{.spec.host}')
