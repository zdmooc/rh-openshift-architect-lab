# Lab06 — Routes & TLS

## Objectif
- Créer une route HTTP simple.
- Générer un certificat self-signed.
- Créer une route TLS (edge).

## Pré-requis
- openssl disponible dans Git Bash.

## Steps

### Step 1 — Projet + app
    oc get project ex280-lab06-route-zidane || oc new-project ex280-lab06-route-zidane
    oc project ex280-lab06-route-zidane
    oc create deployment tls-web --image=registry.access.redhat.com/ubi8/httpd-24 --port=8080
    oc expose deployment/tls-web --name=tls-web-svc

### Step 2 — Route HTTP simple
    oc expose svc/tls-web-svc
    oc get route

### Step 3 — Certificat self-signed
    mkdir -p /c/workspaces/openshift2026/certs
    cd /c/workspaces/openshift2026/certs
    openssl req -x509 -newkey rsa:2048 -keyout tls.key -out tls.crt -days 365 -nodes \
      -subj "/CN=tls-web.apps-crc.testing"

    oc project ex280-lab06-route-zidane
    oc create secret tls tls-web-secret --cert=tls.crt --key=tls.key

### Step 4 — Route edge TLS
    oc create route edge tls-web-tls \
      --service=tls-web-svc \
      --cert=tls.crt --key=tls.key

## Vérifications
    oc get route
    ROUTE_HTTP="http://$(oc get route tls-web-svc -o jsonpath='{.spec.host}')"
    ROUTE_HTTPS="https://$(oc get route tls-web-tls -o jsonpath='{.spec.host}')"
    curl -k "$ROUTE_HTTP"  || true
    curl -k "$ROUTE_HTTPS" || true

## Cleanup (optionnel)
    oc delete project ex280-lab06-route-zidane --ignore-not-found

## Pièges fréquents
- CN ≠ host de route → regénérer le certificat avec le bon CN
