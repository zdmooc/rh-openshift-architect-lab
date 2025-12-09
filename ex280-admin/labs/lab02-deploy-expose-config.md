# Lab02 — Deploy, Service, Route & Config

## Objectif
- Déployer une appli HTTP.
- L’exposer via Service + Route.
- Injecter config via ConfigMap + Secret.

## Pré-requis
- Lab01 OK.

## Steps

### Step 1 — Projet
    oc get project ex280-lab02-app-zidane || oc new-project ex280-lab02-app-zidane
    oc project ex280-lab02-app-zidane

### Step 2 — ConfigMap + Secret
    oc create configmap app-config --from-literal=APP_MESSAGE="Hello EX280"
    oc create secret generic app-secret --from-literal=APP_PASSWORD="changeme"

### Step 3 — Deployment
    oc create deployment web --image=registry.access.redhat.com/ubi8/httpd-24 --port=8080

    oc set env deployment/web \
      APP_MESSAGE_FROM_CM="$(oc get cm app-config -o jsonpath='{.data.APP_MESSAGE}')" \
      APP_PASSWORD_FROM_SECRET="$(oc get secret app-secret -o jsonpath='{.data.APP_PASSWORD}' | base64 -d)"

### Step 4 — Service + Route
    oc expose deployment/web --name=web-svc
    oc expose svc/web-svc

### Step 5 — Test HTTP
    oc get all
    oc get route
    ROUTE_URL="http://$(oc get route web-svc -o jsonpath='{.spec.host}')"
    curl -k "$ROUTE_URL" || true

## Vérifications
    oc get deployment web
    oc get svc web-svc
    oc get route web-svc
    curl -k "$ROUTE_URL" || true

Critères :
- Deployment, Service, Route présents
- HTTP 200 ou page servie via la route

## Cleanup (optionnel)
    oc delete project ex280-lab02-app-zidane --ignore-not-found

## Pièges fréquents
- Image non trouvée → `oc describe pod ...`
- Route KO → vérifier `oc get route`, `oc get pods -o wide`, `oc logs -l app=web`
