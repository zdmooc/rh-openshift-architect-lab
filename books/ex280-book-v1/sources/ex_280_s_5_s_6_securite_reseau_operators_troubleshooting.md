# EX280 – Semaine 5–6

Sécurité applicative, réseau (Routes/NetPol), RBAC, Operators/OLM, troubleshooting structuré.

---

## 0. Objectifs des semaines 5–6

### Objectif fin S5

Être capable de corriger / ajuster sans tâtonner :

- ServiceAccounts et SCC
- RBAC (Role / RoleBinding)
- NetworkPolicies (deny-all, ouvertures ciblées)
- Routes (HTTP) et tests réseau
- Cas d’incidents courants (NetPol qui bloque, image introuvable…)

### Objectif fin S6

- Comprendre le fonctionnement d’OperatorHub / OLM (objets CSV, Subscription, OperatorGroup…)
- Avoir des réflexes troubleshooting structurés (events → describe → logs → réseau → policies)
- Préparer la suite (Tekton / Pipelines – pont EX288)

---

## 1. ServiceAccounts & SCC

### 1.1. Concepts

- **ServiceAccount (SA)** : identité utilisée par les pods pour appeler l’API Kube, monter des secrets, etc.
  - Par défaut, les pods utilisent `default` dans leur namespace.
  - Bonne pratique : créer une SA dédiée par application.

- **SCC (Security Context Constraints)** (spécifique OpenShift) : règles de sécurité appliquées aux pods.
  - Exemple courant : `restricted-v2` (pods non privilégiés, UID non root, etc.).
  - La SCC appliquée apparaît comme annotation dans le pod : `openshift.io/scc: restricted-v2`.

### 1.2. Commandes essentielles

Lister les ServiceAccounts du projet :

```bash
oc get sa
```

Créer une ServiceAccount dédiée :

```bash
oc create sa httpd-sa
```

Attacher une SA à un déploiement :

```bash
oc set serviceaccount deploy/httpd-ubi-app httpd-sa
```

Vérifier la SA utilisée par un pod :

```bash
oc get pod -l deployment=httpd-ubi-app \
  -o custom-columns=NAME:.metadata.name,SA:.spec.serviceAccountName --no-headers
```

Voir la SCC appliquée à un pod :

```bash
oc describe pod -l deployment=httpd-ubi-app | grep -i "openshift.io/scc" || echo "no scc annotation"
```

### 1.3. Modèle mental EX280

1. **Pod qui ne démarre pas pour raisons de sécurité** → vérifier :
   - La SA utilisée (`.spec.serviceAccountName`).
   - L’annotation `openshift.io/scc`.
   - Les events (`oc get events`) qui mentionnent SCC / `permission denied`.
2. **Adaptation** :
   - Soit changer la SA attachée au déploiement.
   - Soit (si on est admin) modifier les droits de la SA via RBAC/SCC.

---

## 2. RBAC dans un projet (Role / RoleBinding)

### 2.1. Concepts

- **Role** : collection de permissions dans un namespace donné.
- **RoleBinding** : associe un Role à un sujet (user, group, SA…).
- **ClusterRole / ClusterRoleBinding** : mêmes concepts, mais à l’échelle cluster.

### 2.2. Vérifier les droits

Voir les roles / rolebindings du projet courant :

```bash
oc get role,rolebinding
```

Tester les droits de l’utilisateur courant :

```bash
oc auth can-i get pods
oc auth can-i delete pods
oc auth can-i create role
oc auth can-i create rolebinding
```

Tester les droits d’une ServiceAccount :

```bash
oc auth can-i get pods \
  --as=system:serviceaccount:ex280-lab02:httpd-sa

oc auth can-i delete pods \
  --as=system:serviceaccount:ex280-lab02:httpd-sa
```

### 2.3. Exemple complet : Role “pod-reader”

Role YAML :

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: ex280-lab02
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

RoleBinding YAML :

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-httpd-sa
  namespace: ex280-lab02
subjects:
- kind: ServiceAccount
  name: httpd-sa
  namespace: ex280-lab02
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Application :

```bash
oc apply -f role-pod-reader.yaml
oc apply -f rolebinding-pod-reader.yaml
```

Vérifications :

```bash
oc get role,rolebinding

oc auth can-i get pods \
  --as=system:serviceaccount:ex280-lab02:httpd-sa   # yes

oc auth can-i delete pods \
  --as=system:serviceaccount:ex280-lab02:httpd-sa   # no
```

---

## 3. NetworkPolicies

### 3.1. Concepts

- Sans NetworkPolicy dans un namespace → tout le trafic pod↔pod est autorisé.
- Dès qu’au moins une NetworkPolicy **sélectionne un pod**, ce pod devient isolé (pour les directions listées dans `policyTypes`).
- `podSelector: {}` = tous les pods du namespace.
- Deux grandes familles :
  - **Ingress** : ce qui entre dans les pods sélectionnés.
  - **Egress** : ce qui sort des pods sélectionnés.

### 3.2. État de base

Voir les NetworkPolicies du namespace :

```bash
oc get networkpolicy
```

Voir les labels du namespace (utile pour policies par namespace) :

```bash
oc get ns ex280-lab02 --show-labels
```

### 3.3. Deny-all ingress

YAML :

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: ex280-lab02
spec:
  podSelector: {}           # tous les pods du namespace
  policyTypes:
  - Ingress
  ingress: []               # aucune règle autorisée -> tout ingress refusé
```

Application :

```bash
oc apply -f np-deny-all.yaml
oc get networkpolicy
```

### 3.4. Tester une NetworkPolicy depuis un pod client

Créer un pod client éphémère qui exec `curl` vers le Service interne :

```bash
oc run np-test-deny2 \
  --image=registry.access.redhat.com/ubi8/ubi \
  --restart=Never --command -- \
  curl -s -o /dev/null -w "%{http_code}\n" http://httpd-ubi-app:8080

oc logs np-test-deny2 || echo "no logs"
```

- Si la NetPol bloque le trafic → code `000`, Error / timeout.
- Sans NetPol → code HTTP (200 / 403 / autre selon appli).

Nettoyage :

```bash
oc delete pod np-test-deny2
```

### 3.5. Rouvrir le trafic intra-namespace

YAML :

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
  namespace: ex280-lab02
spec:
  podSelector: {}           # tous les pods du namespace
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector: {}       # depuis tous les pods du même namespace
```

Application :

```bash
oc apply -f np-allow-same-namespace.yaml
```

Test depuis un pod client :

```bash
oc run np-test-allow \
  --image=registry.access.redhat.com/ubi8/ubi \
  --restart=Never --command -- \
  curl -s -o /dev/null -w "%{http_code}\n" http://httpd-ubi-app:8080

oc logs np-test-allow
oc delete pod np-test-allow
```

- Ici, un code HTTP (ex. `403`) montre que le trafic est à nouveau autorisé.

### 3.6. Points à compléter plus tard

- NetPol basées sur labels de pods (`app=...`).
- NetPol avec `namespaceSelector` (par ex. autoriser uniquement `openshift-ingress`).
- Tests DNS (`getent hosts`, `dig`) depuis un pod client.

---

## 4. Routes HTTP et tests réseau

### 4.1. Concepts

- **Service** : expose un ensemble de pods sur un ClusterIP (virtuel).
- **Route** (OpenShift) : expose un Service vers l’extérieur via le router (HTTP/HTTPS).
- Modes TLS (à pratiquer plus tard) :
  - `edge`, `passthrough`, `reencrypt`.

### 4.2. Vérifier Service + Route

Lister Services et Routes du projet :

```bash
oc get svc,route
```

Exemple de test d’une Route depuis la machine locale :

```bash
curl -I http://httpd-ubi-app-ex280-lab02.apps-crc.testing

curl -v http://httpd-ubi-app-ex280-lab02.apps-crc.testing 2>&1 | head -n 20
```

- **200** : OK (page servie normalement).
- **403** : refus applicatif (ex. ModSecurity), mais le chemin réseau est bon.
- **5xx** : problème côté appli ou route/backend.
- **Connexion impossible** : regarder d’abord DNS / NetPol / router.

---

## 5. Troubleshooting structuré

### 5.1. Triptyque de base

Pour un pod qui ne démarre pas / ne répond pas :

1. **Events récents** du namespace :

   ```bash
   oc get events --sort-by=.lastTimestamp | tail -n 10
   ```

2. **Describe** du pod :

   ```bash
   oc describe pod <nom> | head -n 40
   ```

3. **Logs** du conteneur principal :

   ```bash
   oc logs <nom> | tail -n 20 || echo "no logs"
   ```

Ce triptyque répond déjà à 70–80 % des questions simples.

### 5.2. Image introuvable / ErrImagePull / ImagePullBackOff

#### Création d’un déploiement cassé

```bash
oc create deployment img-error-demo \
  --image=registry.access.redhat.com/ubi8/does-not-exist:latest

oc get pod -l app=img-error-demo
oc describe pod -l app=img-error-demo | head -n 40
oc get events --sort-by=.lastTimestamp | tail -n 10
```

Typical :
- `ErrImagePull` → image inconnue.
- `ImagePullBackOff` → kube réessaie, puis se met en backoff.

#### Correction de l’image

1. Vérifier le nom du conteneur dans le déploiement :

   ```bash
   oc describe deploy img-error-demo | grep -A3 "Containers:"
   ```

2. Mettre à jour l’image avec le bon nom de conteneur :

   ```bash
   oc set image deploy/img-error-demo \
     does-not-exist=registry.access.redhat.com/ubi8/httpd-24
   ```

3. Si le rollout dépasse son délai, forcer un restart propre :

   ```bash
   oc get deploy img-error-demo \
     -o jsonpath='{.spec.template.spec.containers[0].name}{" "}{.spec.template.spec.containers[0].image}{"\n"}'

   oc scale deploy/img-error-demo --replicas=0
   oc get pod -l app=img-error-demo

   oc scale deploy/img-error-demo --replicas=1
   oc rollout status deploy/img-error-demo
   oc get pod -l app=img-error-demo -o wide
   ```

4. Vérifier le pod final :

   ```bash
   oc describe pod -l app=img-error-demo | head -n 25
   ```

→ Objectif : voir au moins un pod `Running` avec l’image corrigée (`registry.access.redhat.com/ubi8/httpd-24`).

### 5.3. Cas traités et cas à traiter

Déjà pratiqués :
- Image introuvable (ImagePullBackOff) → correction d’image.
- NetworkPolicy qui bloque → deny-all + allow-same-namespace.
- Route OK mais appli renvoie 403 → problème applicatif, pas réseau.

À pratiquer plus tard :
- Quota dépassé (ResourceQuota / LimitRange).
- SCC trop restrictive (capabilities, runAsUser, volumes).
- Route/TLS mal configurée (certificat, host, service backend).

---

## 6. Operators / OLM (vue d’ensemble)

### 6.1. Concepts clés

OLM (Operator Lifecycle Manager) gère :

- **CatalogSource** : d’où viennent les Operators (catalogues).
- **Subscription** : ce que tu souhaites installer / tenir à jour.
- **OperatorGroup** : scoped des Operators sur un ou plusieurs namespaces.
- **ClusterServiceVersion (CSV)** : version installée d’un Operator.
- **InstallPlan** : ce que OLM va appliquer pour installer/mettre à jour.
- **Custom Resources (CR)** : objets apportés par l’Operator (ex. base de données, instance d’app).

### 6.2. Ressources à connaître

Lister les ressources liées à OLM :

```bash
oc api-resources | grep -i operators.coreos.com
```

Tu dois reconnaître (entre autres) :

- `clusterserviceversions` (`csv`)
- `subscriptions` (`sub`)
- `operatorgroups` (`og`)
- `catalogsources` (`catsrc`)
- `installplans` (`ip`)
- `packagemanifests`

### 6.3. Limites sur CRC

- Sur CRC avec un user non cluster-admin, beaucoup de commandes `oc get csv -A` ou `oc get subscription -A` renvoient `Forbidden`.
- Pour la pratique complète (install / delete d’un Operator, création de CR), il faudra un cluster où tu as des droits d’admin.

---

## 7. Récapitulatif “réflexes EX280” S5–S6

### 7.1. Pod qui ne démarre pas / reste en Pending

1. `oc get events --sort-by=.lastTimestamp | tail -n 10`
2. `oc describe pod <nom> | head -n 40`
3. Regarder : image, SCC, SA, conditions, messages.

### 7.2. Appli qui ne répond pas via la Route

1. `oc get svc,route`
2. `curl -I http://<route>`
3. Si route OK mais erreur HTTP (403, 5xx) → problème applicatif.
4. Si connexion impossible → vérifier DNS, NetPol, état du Service/pods.

### 7.3. Soupçon de NetworkPolicy

1. `oc get networkpolicy`
2. Vérifier `podSelector` / `policyTypes` / règles `ingress` / `egress`.
3. Tester depuis un pod client dans le même namespace avec `curl`.

### 7.4. Soupçon de problème de droits (RBAC)

1. `oc get role,rolebinding`
2. `oc auth can-i <verbe> <ressource> [--as=...]`
3. Ajuster Role / RoleBinding si nécessaire.

### 7.5. Soupçon de problème d’image / registry

1. `oc describe pod <nom>` → section `Containers` (Image, Reason `ErrImagePull`).
2. `oc get events --sort-by=.lastTimestamp | tail -n 10` → message détaillé.
3. Corriger l’image via `oc set image`.
4. Si nécessaire, `oc scale` à 0 puis 1 pour relancer proprement.

---

## 8. Prochaines étapes pour compléter S5–S6

1. Routes/TLS avancées :
   - Créer une route edge/passthrough/reencrypt.
   - Tester avec `curl` en HTTP/HTTPS.

2. NetPol plus fines :
   - Par labels de pods.
   - Par `namespaceSelector`.

3. Scénarios “incident day” :
   - Quota dépassé (ResourceQuota / LimitRange).
   - SCC trop restrictive.
   - Route mal configurée.

4. Operators/CR en pratique :
   - Sur un cluster où tu as les droits pour créer `Subscription` / `OperatorGroup`.

5. Tekton (pont EX288) :
   - Créer une `Task` simple.
   - Lancer un `TaskRun` / `PipelineRun`.
   - Lire les logs et l’état des ressources.

