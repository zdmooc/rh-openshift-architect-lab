# Lab06 — Routes & TLS

## Objectif

- Créer une route HTTP simple.
- Générer un certificat auto-signé.
- Créer une route TLS (edge) utilisant ce certificat.

## Pré-requis

- openssl disponible dans l’environnement.

---

## Steps

### Step 1 — Projet + app

    oc get project ex280-lab06-route-zidane || oc new-project ex280-lab06-route-zidane
    oc project ex280-lab06-route-zidane

    oc create deployment tls-web \
      --image=registry.access.redhat.com/ubi8/httpd-24 \
      --port=8080

    oc expose deployment/tls-web --name=tls-web-svc
    oc get svc tls-web-svc

### Step 2 — Route HTTP simple

    oc expose svc/tls-web-svc
    oc get route

    ROUTE_HTTP="http://$(oc get route tls-web-svc -o jsonpath='{.spec.host}')"
    curl -k "$ROUTE_HTTP" || true

### Step 3 — Certificat auto-signé

    mkdir -p /c/workspaces/openshift2026/certs
    cd /c/workspaces/openshift2026/certs

    openssl req -x509 -newkey rsa:2048 -keyout tls.key -out tls.crt -days 365 -nodes \
      -subj "/CN=tls-web.apps-crc.testing"

    oc project ex280-lab06-route-zidane

    oc create secret tls tls-web-secret --cert=tls.crt --key=tls.key
    oc get secret tls-web-secret

### Step 4 — Route edge TLS

    oc create route edge tls-web-tls \
      --service=tls-web-svc \
      --cert=tls.crt \
      --key=tls.key

    oc get route

    ROUTE_HTTPS="https://$(oc get route tls-web-tls -o jsonpath='{.spec.host}')"
    curl -k "$ROUTE_HTTPS" || true

---

## Vérifications

    oc get route
    echo "$ROUTE_HTTP"
    echo "$ROUTE_HTTPS"
    curl -k "$ROUTE_HTTP"  || true
    curl -k "$ROUTE_HTTPS" || true

Critères :

- Route HTTP et route HTTPS présentes.
- curl sur la route HTTPS retourne une page (même avec warning cert).

---

## Cleanup (optionnel)

    oc delete project ex280-lab06-route-zidane --ignore-not-found

---

## Pièges fréquents

- CN ≠ host de la route → regénérer le certificat avec le bon CN.
- Service non accessible → vérifier `oc describe route`, `oc get pods -o wide`.
