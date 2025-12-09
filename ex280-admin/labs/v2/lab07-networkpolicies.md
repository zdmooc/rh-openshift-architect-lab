# Lab07 — NetworkPolicies

## Objectif

- Créer deux apps (server/client).
- Autoriser uniquement le client à joindre le server via NetworkPolicy.

## Pré-requis

- SDN avec support NetworkPolicy (OK sur CRC par défaut).

---

## Steps

### Step 1 — Projet

    oc get project ex280-lab07-netpol-zidane || oc new-project ex280-lab07-netpol-zidane
    oc project ex280-lab07-netpol-zidane

### Step 2 — Pods server + client

    oc create deployment server --image=nginxinc/nginx-unprivileged
    oc expose deployment/server --port=8080 --name=server-svc

    oc create deployment client --image=registry.access.redhat.com/ubi8/ubi-minimal \
      -- sleep 3600

    oc get pods -o wide

### Step 3 — NetworkPolicy

    cat << 'YAML' | oc apply -f -
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-client
    spec:
      podSelector:
        matchLabels:
          app: server
      ingress:
      - from:
        - podSelector:
            matchLabels:
              app: client
        ports:
        - protocol: TCP
          port: 8080
    YAML

    oc get networkpolicy
    oc describe networkpolicy allow-client

---

## Vérifications

    CLIENT_POD=$(oc get pod -l app=client -o jsonpath='{.items[0].metadata.name}')
    SERVER_IP=$(oc get pod -l app=server -o jsonpath='{.items[0].status.podIP}')

    oc exec "$CLIENT_POD" -- curl -sS "http://$SERVER_IP:8080" || true

Critère :

- Le client peut joindre le server sur 8080 (réponse HTTP).

---

## Cleanup (optionnel)

    oc delete project ex280-lab07-netpol-zidane --ignore-not-found

---

## Pièges fréquents

- Labels qui ne matchent pas → `oc get pods --show-labels`
- Policy mal ciblée → `oc describe networkpolicy allow-client`
