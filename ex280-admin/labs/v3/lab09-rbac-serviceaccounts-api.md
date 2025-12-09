# Lab 09 — RBAC & ServiceAccounts: tokens, accès API Kubernetes, permissions minimales


## Objectifs EX280 couverts
- Configurer et gérer des service accounts
- Configurer l’accès applicatif aux APIs Kubernetes
- Modifier permissions (RBAC) user/group/serviceaccount

## Prérequis
```bash
export LAB=09
export NS=ex280-lab${LAB}-zidane
oc new-project "$NS"
```

## Scénario
- Un pod “client” doit appeler l’API Kubernetes **en lecture seule** (liste de pods dans son namespace).

## Tâches
### 1) Créer une ServiceAccount + Role + RoleBinding (least privilege)
```bash
oc create sa api-reader

cat <<'YAML' | oc apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","list","watch"]
YAML

oc create rolebinding api-reader-binding --role=pod-reader --serviceaccount="$NS":api-reader
oc get rolebinding api-reader-binding -o yaml | sed -n '1,200p'
```

### 2) Déployer un pod qui utilise la SA et appelle l’API
Créer un pod `api-client` :
```bash
cat <<'YAML' | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: api-client
spec:
  serviceAccountName: api-reader
  containers:
  - name: api-client
    image: registry.access.redhat.com/ubi9/ubi-minimal
    command: ["/bin/sh","-c"]
    args:
      - |
        TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
        CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
        echo "Namespace=$NS"
        # Liste des pods dans le namespace (API Core)
        curl -sS --cacert "$CACERT" -H "Authorization: Bearer $TOKEN"           "https://kubernetes.default.svc/api/v1/namespaces/$NS/pods"           | head -c 400
        echo
        sleep 3600
YAML
oc wait --for=condition=Ready pod/api-client --timeout=120s
oc logs api-client | head -n 30
```

### 3) Vérifier qu’une action non autorisée échoue
Tester la suppression de pod (doit échouer) :
```bash
oc exec api-client -- sh -c '
  TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
  curl -sS -o /dev/null -w "%{http_code}
" --cacert "$CACERT" -H "Authorization: Bearer $TOKEN"     -X DELETE "https://kubernetes.default.svc/api/v1/namespaces/$NS/pods/somepod"
'
```
Attendu : `403`.

## Vérifications
- Le pod peut lister les pods (`200`) mais ne peut pas supprimer (`403`).

## Nettoyage
```bash
oc delete project "$NS"
```
