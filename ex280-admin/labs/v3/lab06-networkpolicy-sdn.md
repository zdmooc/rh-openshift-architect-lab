# Lab 06 — NetworkPolicy & sécurité réseau: contrôle ingress/egress + tests


## Objectifs EX280 couverts
- Configurer des politiques réseau applicatives (NetworkPolicy)
- Contrôler l’ingress réseau du cluster
- Troubleshoot SDN (via tests + describe/events)

## Prérequis
```bash
export LAB=06
export NS=ex280-lab${LAB}-zidane
oc new-project "$NS"
```

## Scénario
- `frontend` doit pouvoir appeler `backend`.
- Tout autre pod ne doit **pas** pouvoir accéder à `backend`.

## Tâches
### 1) Déployer backend (service) + frontend (client)
```bash
oc new-app --name=backend --image=registry.access.redhat.com/ubi9/httpd-24
oc rollout status deploy/backend
oc expose svc/backend --port=8080 --target-port=8080 --name=backend

oc run frontend --image=registry.access.redhat.com/ubi9/ubi-minimal --restart=Never -- sleep 3600
oc run intruder --image=registry.access.redhat.com/ubi9/ubi-minimal --restart=Never -- sleep 3600
oc wait --for=condition=Ready pod/frontend --timeout=120s
oc wait --for=condition=Ready pod/intruder --timeout=120s
```

### 2) Vérifier l’accès initial (avant NetworkPolicy)
```bash
oc exec frontend -- sh -c "curl -sS -m 2 http://backend:8080/ >/dev/null && echo OK || echo FAIL"
oc exec intruder -- sh -c "curl -sS -m 2 http://backend:8080/ >/dev/null && echo OK || echo FAIL"
```
Attendu : **OK** pour les deux (par défaut, pas d’isolement).

### 3) Appliquer une NetworkPolicy “default deny” sur backend
```bash
cat <<'YAML' | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-deny-all
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
YAML
```

Re-tester :
```bash
oc exec frontend -- sh -c "curl -sS -m 2 http://backend:8080/ >/dev/null && echo OK || echo FAIL"
oc exec intruder -- sh -c "curl -sS -m 2 http://backend:8080/ >/dev/null && echo OK || echo FAIL"
```
Attendu : **FAIL** pour les deux.

### 4) Autoriser uniquement `frontend` vers `backend`
Labeler `frontend` :
```bash
oc label pod frontend role=frontend
```
Autoriser ingress depuis `role=frontend` :
```bash
cat <<'YAML' | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-allow-frontend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
YAML
```
Re-tester :
```bash
oc exec frontend -- sh -c "curl -sS -m 2 http://backend:8080/ >/dev/null && echo OK || echo FAIL"
oc exec intruder -- sh -c "curl -sS -m 2 http://backend:8080/ >/dev/null && echo OK || echo FAIL"
```
Attendu : `frontend` OK, `intruder` FAIL.

### 5) Troubleshooting rapide (méthode examen)
```bash
oc get networkpolicy
oc describe networkpolicy backend-allow-frontend | sed -n '1,200p'
oc get pod backend-xxxxx --show-labels   # remplace par le nom réel du pod backend
oc get events --sort-by=.metadata.creationTimestamp | tail -n 30
```

## Nettoyage
```bash
oc delete project "$NS"
```
