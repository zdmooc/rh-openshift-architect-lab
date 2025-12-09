# Lab 04 — Déploiements: ReplicaSets, labels/selectors, services, rollout/rollback


## Objectifs EX280 couverts
- Gérer des déploiements d’applications
- Travailler avec ReplicaSets
- Labels & selectors
- Configurer des services

## Prérequis
```bash
export LAB=04
export NS=ex280-lab${LAB}-zidane
oc new-project "$NS"
```

## Tâches
### 1) Déployer une application
```bash
oc new-app --name=hello --docker-image=quay.io/libpod/hello
oc rollout status deploy/hello
```
> Si ton `oc` affiche “--docker-image deprecated”, tu peux utiliser :
```bash
oc new-app --name=hello --image=quay.io/libpod/hello
```

### 2) Inspecter ReplicaSet, labels, selectors
```bash
oc get deploy hello -o yaml | sed -n '1,160p'
oc get rs -l app=hello
oc get pod -l app=hello --show-labels
oc get deploy hello -o jsonpath='{.spec.selector.matchLabels}{"
"}'
```

### 3) Service + test interne
```bash
oc expose deploy/hello --port=8080 --target-port=8080 --name=hello-svc
oc get svc hello-svc -o wide
oc run curl --image=registry.access.redhat.com/ubi9/ubi-minimal --restart=Never --command -- sleep 3600
oc wait --for=condition=Ready pod/curl --timeout=120s
oc exec curl -- sh -c "curl -sS http://hello-svc:8080/ || true"
```

### 4) Scale + stratégie de rollout
```bash
oc scale deploy/hello --replicas=3
oc rollout status deploy/hello
oc get pod -l app=hello -o wide
```

### 5) Update image + rollback
```bash
oc set image deploy/hello hello=quay.io/libpod/hello:latest
oc rollout status deploy/hello
oc rollout history deploy/hello
oc rollout undo deploy/hello
oc rollout status deploy/hello
```

## Vérifications
- Service `hello-svc` existe et sélectionne les pods `app=hello`.
- `oc get rs` montre l’historique des ReplicaSets.
- Rollback ramène un état stable.

## Nettoyage
```bash
oc delete project "$NS"
```
