# EX280 – Semaine 7 & 8

## Vue d’ensemble

- **S7** : comprendre et manipuler **quotas** et **ressources** (requests/limits) au niveau d’un projet.
- **S8** : savoir **dépanner une application** qui ne marche pas (image, quota, service, route, réseau, pod qui crash).

L’objectif : être capable, en mode examen, de :
- Lire / interpréter un `ResourceQuota` et adapter tes manifests.
- Comprendre pourquoi un pod ne se crée pas (quota, scheduling, CNI, image…).
- Corriger une mise à jour d’image cassée via `rollout`.
- Corriger un Service/Route qui ne pointe pas vers les bons pods.
- Tester le réseau depuis l’intérieur du cluster.

---

## Semaine 7 – Quotas & Ressources

### 1. Concepts clés

#### 1.1. ResourceQuota

Un **ResourceQuota** limite la consommation de ressources dans un **namespace**.
Typiquement :

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: ex280-lab02
spec:
  hard:
    pods: "4"
    requests.cpu: "200m"
    requests.memory: "256Mi"
    limits.cpu: "500m"
    limits.memory: "640Mi"
```

- `hard` = plafond autorisé dans le namespace.
- Les champs `Used` sont mis à jour par le cluster quand tu crées/supprimes des pods.

Commande de base :

```bash
oc describe resourcequota compute-quota
```

Sortie typique :

```text
Resource         Used   Hard
--------         ----   ----
limits.cpu       500m   500m
limits.memory    640Mi  640Mi
pods             3      4
requests.cpu     150m   200m
requests.memory  192Mi  256Mi
```

À lire comme :
- **Used** = somme de tous les pods du projet.
- **Hard** = plafond fixé par l’admin.
- Si `Used == Hard` → tu ne peux plus créer de ressources supplémentaires sur cette métrique.

#### 1.2. Requests vs Limits

Dans un conteneur :

```yaml
resources:
  requests:
    cpu: "50m"
    memory: "64Mi"
  limits:
    cpu: "100m"
    memory: "128Mi"
```

- **requests**
  - Sert au **scheduler** pour placer le pod.
  - Doit entrer dans les quotas `requests.*`.
- **limits**
  - Plafond d’utilisation.
  - Doit entrer dans les quotas `limits.*`.

Important :
- Un pod peut être **refusé** au moment de la création si les **requests/limits** font dépasser le `ResourceQuota`.
- L’erreur se voit dans les **events**.

Exemple d’erreur :

```text
Error creating: pods "..." is forbidden: exceeded quota: compute-quota,
requested: limits.cpu=200m,limits.memory=256Mi,
used: limits.cpu=500m,limits.memory=640Mi,
limited: limits.cpu=500m,limits.memory=640Mi
```

Traduction :
- Tu demandes `200m/256Mi`.
- Le quota est déjà au max (`Used = Hard`).
- Le pod est refusé.

---

### 2. Pod de test avec ressources correctes

Manifeste utilisé :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: s7-test-pod-ok
  namespace: ex280-lab02
spec:
  restartPolicy: Never
  containers:
  - name: httpd
    image: registry.access.redhat.com/ubi8/httpd-24
    resources:
      limits:
        cpu: "100m"
        memory: "128Mi"
      requests:
        cpu: "50m"
        memory: "64Mi"
```

Commandes :

```bash
# Création
oc apply -f s7-test-pod-ok.yaml

# Statut du pod
oc get pod s7-test-pod-ok -o wide

# Vérifier les ressources appliquées
oc describe pod s7-test-pod-ok | sed -n '/Limits:/,/Requests:/p'

# Impact sur le quota
oc describe resourcequota compute-quota
```

---

### 3. Libérer / Consommer le quota

#### 3.1. Voir qui consomme

```bash
oc get pod -o wide
oc describe resourcequota compute-quota
```

Tu identifies les pods “gros” (par exemple un deployment httpd qui consomme 200m/256Mi).

#### 3.2. Libérer du quota

Deux stratégies :

1. **Supprimer des pods** :

```bash
oc delete pod s7-test-pod-ok --ignore-not-found
```

2. **Réduire les replicas d’un deployment** :

```bash
oc scale deploy/httpd-demo --replicas=0
```

Puis vérifier :

```bash
oc describe resourcequota compute-quota
```

---

### 4. Réflexes EX280 – S7

1. Toujours commencer par :
   ```bash
   oc describe resourcequota compute-quota
   ```
2. Si un pod ne se crée pas → aller voir les **events** :
   ```bash
   oc get events --sort-by=.lastTimestamp | tail -n 20
   ```
3. Adapter les `requests/limits` dans le YAML pour **rentrer dans le quota**.
4. Ne pas oublier de **supprimer** les pods de test une fois l’exercice terminé.

---

## Semaine 8 – Troubleshooting d’une application

### 1. Rollout cassé (image invalide)

#### 1.1. Situation

Tu as un deployment `httpd-demo` qui fonctionne, puis tu casses volontairement l’image :

```bash
oc set image deploy/httpd-demo \
  httpd-24=registry.access.redhat.com/ubi8/httpd-24:notag
```

Symptômes :

- `oc rollout status deploy/httpd-demo` reste bloqué.
- Aucun pod prêt.
- Les events montrent `ErrImagePull` / `ImagePullBackOff` :

```text
Failed to pull image "...:notag": reading manifest notag ... manifest unknown
Error: ImagePullBackOff
```

#### 1.2. Diagnostic

```bash
# Voir l’état du déploiement
oc get deploy httpd-demo -o wide

# Voir les pods
oc get pod -l app=httpd-demo -o wide

# Décrire un pod défaillant
POD=$(oc get pod -l app=httpd-demo -o jsonpath='{.items[0].metadata.name}')
oc describe pod "$POD" | head -n 40
```

#### 1.3. Correction (rollback)

Retour à la révision précédente :

```bash
oc rollout undo deploy/httpd-demo
oc rollout status deploy/httpd-demo
```

Vérification :

```bash
oc get deploy httpd-demo -o wide
oc get pod -l app=httpd-demo -o wide
```

---

### 2. Quota qui bloque un rollout

Cas typique :
- Tu scales `httpd-demo` à 1 replica.
- Le quota `limits.cpu` / `limits.memory` est déjà plein.
- Les nouveaux pods ne se créent pas → `No resources found` pour les pods du deployment.

Diagnostic :

```bash
oc get events --sort-by=.lastTimestamp | tail -n 15
oc describe resourcequota compute-quota
```

Tu vois :

```text
Error creating: pods "httpd-demo-..." is forbidden: exceeded quota: compute-quota, ...
```

Solution :
- Supprimer un pod ou scale down un autre deployment pour **libérer du quota**.
- Rejouer le rollout ou laisser le ReplicaSet recréer un pod.

---

### 3. Service / Route / Endpoints

#### 3.1. Chaîne logique

```text
Route → Service → Endpoints → Pods
```

- La **Route** pointe vers un **Service**.
- Le **Service** sélectionne des pods via `spec.selector`.
- Les **Endpoints** sont dérivés des pods qui matchent le selector.

Si le selector du Service est faux → Endpoints vide → 503 côté Route.

#### 3.2. Casser le Service (pour comprendre)

```bash
oc patch svc/httpd-demo -p '{"spec":{"selector":{"app":"httpd-demo-bad"}}}'
```

Puis :

```bash
# Pod réel
oc get pod -l app=httpd-demo -o wide

# Service + Endpoints
oc get svc httpd-demo -o yaml | sed -n '1,40p'
oc get endpoints httpd-demo -o yaml | sed -n '1,80p'
```

Endpoints typiques :

- **Avant** la casse : `subsets` contient l’IP du pod.
- **Après** la casse : `subsets` vide / absent → aucun backend.

Test HTTP :

```bash
curl -I http://httpd-demo-ex280-lab02.apps-crc.testing || echo "curl KO"
```

#### 3.3. Correction du Service

```bash
oc patch svc/httpd-demo -p '{"spec":{"selector":{"app":"httpd-demo"}}}'

oc get svc httpd-demo -o yaml | sed -n '1,40p'
oc get endpoints httpd-demo -o yaml | sed -n '1,80p'
```

Tu dois voir :

```yaml
subsets:
- addresses:
  - ip: 10.217.0.221
    nodeName: crc
    targetRef:
      kind: Pod
      name: httpd-demo-56c49cbc45-wt7xv
      namespace: ex280-lab02
  ports:
  - port: 8080
    protocol: TCP
```

Test interne depuis un pod :

```bash
POD=$(oc get pod -l app=httpd-demo -o jsonpath='{.items[0].metadata.name}')

oc exec "$POD" -- curl -s -o /dev/null -w "%{http_code}\\n" http://httpd-demo:8080
```

- `200` → OK.
- `403` / autre → regarder la config httpd.

---

### 4. Pods de test réseau

#### 4.1. Pod `net-test` long (utile en exam)

```bash
oc run net-test \
  --image=registry.access.redhat.com/ubi8/ubi \
  --restart=Never --command -- sleep 3600

oc get pod net-test -w
```

Une fois en `Running`, tu peux tester :

```bash
# DNS / API cluster (sans auth)
oc exec net-test -- \
  curl -ks -o /dev/null -w "%{http_code}\\n" https://kubernetes.default.svc
# → souvent 403, normal (pas de token ou pas de droits)

# Avec token de ServiceAccount
oc exec net-test -- sh -c '
  TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  curl -ks -H "Authorization: Bearer $TOKEN" \
       -o /dev/null -w "%{http_code}\\n" \
       https://kubernetes.default.svc/api
'
# → 200 si tout va bien

# Test vers un Service
oc exec net-test -- \
  curl -s -o /dev/null -w "%{http_code}\\n" http://httpd-demo:8080

# Test vers la Route
oc exec net-test -- \
  curl -s -o /dev/null -w "%{http_code}\\n" \
    http://httpd-demo-ex280-lab02.apps-crc.testing
```

Codes possibles :
- `200` → tout va bien.
- `503` → Route atteint le Service mais pas de backend (Endpoints vides ou pod KO).
- `000` + erreur → problème de DNS/TLS/connexion.

---

### 5. Pod qui crash (CrashLoop / scénario S8)

#### 5.1. Déploiement qui sort en erreur

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: s8-crash-demo
  namespace: ex280-lab02
spec:
  replicas: 1
  selector:
    matchLabels:
      app: s8-crash-demo
  template:
    metadata:
      labels:
        app: s8-crash-demo
    spec:
      containers:
      - name: crash
        image: registry.access.redhat.com/ubi8/ubi
        command:
        - /bin/sh
        - -c
        - |
          echo "Starting crash demo"
          sleep 5
          echo "Now exiting with error"
          exit 1
```

Commandes :

```bash
oc apply -f s8-crash-demo.yaml
oc get pod -l app=s8-crash-demo -w
```

Diagnostic :

```bash
POD=$(oc get pod -l app=s8-crash-demo -o jsonpath='{.items[0].metadata.name}')
oc describe pod "$POD" | head -n 40
oc logs "$POD" | tail -n 20
```

Tu vois le conteneur démarrer puis sortir avec un code d’erreur.

#### 5.2. Corriger le crash (patch du Deployment)

```bash
oc patch deploy/s8-crash-demo -p '{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "crash",
            "command": [
              "/bin/sh",
              "-c",
              "echo \"Pod OK, plus de crash\"; sleep 3600"
            ]
          }
        ]
      }
    }
  }
}'

oc rollout status deploy/s8-crash-demo
oc get pod -l app=s8-crash-demo -o wide
```

Une fois le pod en `Running` :

```bash
POD=$(oc get pod -l app=s8-crash-demo -o jsonpath='{.items[0].metadata.name}')
oc logs "$POD" | tail -n 20
```

---

### 6. Réflexes EX280 – S8

1. **Pod ne vient pas** :
   - `oc get pod ...`
   - `oc describe pod ...` → regarder les **Events** (quota, CNI, image, scheduling).
   - `oc get events --sort-by=.lastTimestamp | tail -n 20`.

2. **Rollout bloqué** :
   - `oc rollout status deploy/...`
   - `oc describe rs` / `oc describe pod`.
   - `oc rollout undo` si image cassée.

3. **Route ne répond pas** :
   - `oc get route,svc,endpoints -o wide`.
   - Vérifier le **selector** du Service.
   - Tester depuis un pod (`net-test`) avec `curl`.

4. **Quota plein** :
   - `oc describe resourcequota compute-quota`.
   - Libérer en supprimant des pods ou en scalant des deployments.

5. **Toujours garder un pod de test réseau** (`net-test`) pour :
   - Tester DNS (`httpd-demo`, `kubernetes.default.svc`).
   - Tester HTTP (`curl` vers Service / Route).

---

## Mini check-list S7–S8 (mode examen)

1. `oc project <ns>` et `oc status`.
2. `oc get deploy,po,svc,route -o wide`.
3. Si pods manquants ou en erreur :
   - `oc describe pod ...`
   - `oc logs ...` (si le conteneur démarre).
4. Si message `exceeded quota` :
   - `oc describe resourcequota compute-quota`.
   - Supprimer / scaler des pods.
5. Si `ErrImagePull` / `ImagePullBackOff` :
   - Vérifier l’image.
   - `oc rollout undo deploy/...`.
6. Si Route OK mais erreur 503 :
   - `oc get endpoints <svc> -o yaml`.
   - Vérifier le selector du Service.
7. Garder un pod `net-test` en Running pour tes tests de réseau.

> Tout ce bloc S7–S8 doit devenir un **réflexe de diagnostic rapide** :
> voir l’erreur → savoir immédiatement quelles commandes lancer, et comment corriger.

