# Lab 07 — Exposer des applis non-HTTP (TCP) : Service LoadBalancer / NodePort / test


## Objectifs EX280 couverts
- Exposer des applications non-HTTP/SNI
- Configurer un service de type LoadBalancer
- Configurer un accès externe à l’application

## Note plateforme
- En environnement “examen / cloud / baremetal équipé”, `type: LoadBalancer` fournit une IP externe.
- En CRC / clusters sans LB, le service peut rester en `pending`. On pratique quand même la ressource et les tests via `port-forward`.

## Prérequis
```bash
export LAB=07
export NS=ex280-lab${LAB}-zidane
oc new-project "$NS"
```

## Scénario
Déployer un serveur TCP simple (echo) puis l’exposer.

## Tâches
### 1) Déployer un echo-server TCP
```bash
cat <<'YAML' | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tcp-echo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tcp-echo
  template:
    metadata:
      labels:
        app: tcp-echo
    spec:
      containers:
      - name: tcp-echo
        image: quay.io/sre_something/echo-server:latest
        ports:
        - containerPort: 8080
YAML
```
> Si l’image n’existe pas dans ton environnement, remplace par une image équivalente “echo” disponible (ou utilise un pod `nc -lk`). Le but exam = service LB/NodePort + exposition.

Attendre :
```bash
oc rollout status deploy/tcp-echo
```

### 2) Créer un Service de type LoadBalancer
```bash
cat <<'YAML' | oc apply -f -
apiVersion: v1
kind: Service
metadata:
  name: tcp-echo-lb
spec:
  type: LoadBalancer
  selector:
    app: tcp-echo
  ports:
  - name: tcp
    port: 9000
    targetPort: 8080
YAML

oc get svc tcp-echo-lb -o wide
oc describe svc tcp-echo-lb | sed -n '1,200p'
```

### 3) Tester l’accès externe (branche A/B)
#### Branche A — si une IP externe existe
```bash
EXTERNAL=$(oc get svc tcp-echo-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}{"
"}{.status.loadBalancer.ingress[0].hostname}{"
"}')
echo "$EXTERNAL"
```
Tester avec `nc`/`curl` selon la nature du serveur.

#### Branche B — si pas de LB (CRC/local)
Tester via `port-forward` :
```bash
oc port-forward svc/tcp-echo-lb 9000:9000
# dans un autre terminal:
nc -vz 127.0.0.1 9000
```

## Vérifications
- Le Service `tcp-echo-lb` existe en `type: LoadBalancer`.
- Le selector pointe sur le pod `tcp-echo`.
- Un test de connectivité fonctionne (LB externe ou port-forward).

## Nettoyage
```bash
oc delete project "$NS"
```
