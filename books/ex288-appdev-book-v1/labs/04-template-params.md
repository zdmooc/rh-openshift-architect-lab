# Lab 04 — Template paramétré

oc process -n ex288 -f manifests/template-ex288.yaml -p APP_NAME=app2 -p MSG=from-template | oc apply -f -

## Vérif
oc get all -n ex288 | grep app2
