# Lab02 — Deploy, Service, Route & Config

## Objectif

- Déployer une application HTTP.
- L’exposer via Service + Route.
- Injecter configuration via ConfigMap + Secret.
- Vérifier l’accès HTTP depuis l’extérieur.

## Pré-requis

- Lab01 OK.

---

## Steps

### Step 1 — Projet

    oc get project ex280-lab02-app-zidane || oc new-project ex280-lab02-app-zidane
    oc project ex280-lab02-app-zidane

### Step 2 — ConfigMap + Secret

    oc create configmap app-config \
      --from-literal=APP_MESSAGE="Hello EX280 from ConfigMap"

    oc create secret generic app-secret \
      --from-literal=APP_PASSWORD="changeme"

    oc get configmap app-config -o yaml
    oc get secret app-secret -o yaml

### Step 3 — Deployment

    oc create deployment web \
      --image=registry.access.redhat.com/ubi8/httpd-24 \
      --port=8080

    oc set env deployment/web --from=configmap/app-config
    oc set env deployment/web --from=secret/app-secret

    oc get deployment web
    oc get pods -o wide

### Step 4 — Service + Route

    oc expose deployment/web --name=web-svc
    oc expose svc/web-svc

    oc get svc web-svc
    oc get route web-svc

### Step 5 — Test HTTP

    ROUTE_URL="http://$(oc get route web-svc -o jsonpath='{.spec.host}')"
    echo "$ROUTE_URL"
    curl -k "$ROUTE_URL" || true

    oc logs -l app=web || true

---

## Vérifications

    oc get deployment web
    oc get svc web-svc
    oc get route web-svc

    ROUTE_URL="http://$(oc get route web-svc -o jsonpath='{.spec.host}')"
    curl -k "$ROUTE_URL" || true

Critères :

- Deployment `web` présent, pods en `Running`.
- Service `web-svc` présent.
- Route `web-svc` présente.
- HTTP 200 ou page servie via la route (curl affiche quelque chose).

---

## Cleanup (optionnel)

    oc delete project ex280-lab02-app-zidane --ignore-not-found

---

## Pièges fréquents

- Image non trouvée → `oc describe pod ...` pour voir `ImagePullBackOff`.
- Route KO → vérifier :
  - `oc get pods -o wide`
  - `oc describe route web-svc`
  - `oc logs -l app=web`
