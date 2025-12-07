# EX280 – Semaine 5 & 6 – Sécurité, Réseau, Operators & Troubleshooting

Contexte général :
- Cluster : CRC local (OpenShift 4.x)
- Projet principal : `ex280-lab02`
- Appli de base : `httpd-demo` (UBI8 httpd-24, port 8080) + éventuellement d’autres démos pour les tests réseau
- Objectif global : être capable de **diagnostiquer et corriger** les problèmes de sécurité/réseau et d’operators **uniquement en CLI**.

---

## Semaine 5 – Sécurité applicative & Réseau

### Objectif fin S5

En ligne de commande uniquement, savoir :
- Utiliser **ServiceAccount** + **SCC** pour corriger un pod bloqué.
- Comprendre et appliquer des **NetworkPolicies** (deny-all, allow ciblé).
- Configurer et diagnostiquer des **Routes** + **TLS**.
- Exposer un service **non HTTP** (ou faux non-HTTP) et comprendre les limitations.

---

## Brique 1 – ServiceAccounts & SCC (sécurité des pods)

**Position plan :** S5 J1–J2

### Concepts

- Un pod utilise une **ServiceAccount** (SA) → identité technique dans le cluster.
- L’SA est mappée à une **SCC** (SecurityContextConstraints) sous OpenShift.
- Une SCC détermine ce qu’un pod a le droit de faire : UID, volumes, hostNetwork, privilèges, etc.

### Commandes de base

```bash
# 1) Lister les SA du projet
oc project ex280-lab02
oc get sa

# 2) Créer une SA dédiée pour httpd
oc create sa httpd-sa
oc get sa httpd-sa -o yaml

# 3) Associer le deployment à cette SA
oc set serviceaccount deployment/httpd-demo httpd-sa
oc describe deploy httpd-demo | sed -n '1,40p'

# 4) Voir la SCC utilisée par les pods
oc get pod -l app=httpd-demo
POD=$(oc get pod -l app=httpd-demo -o jsonpath='{.items[0].metadata.name}')

# Annotation de SCC sur le pod
oc get pod "$POD" -o jsonpath='{.metadata.annotations.openshift\.io/scc}' ; echo

# 5) Lister toutes les SCC
oc get scc
oc describe scc restricted
```

### À retenir EX280

- `oc set serviceaccount` pour lier un déploiement à une SA.
- `oc get pod ... -o jsonpath='{.metadata.annotations.openshift\.io/scc}'` pour voir la SCC effective.
- `oc describe scc` pour comprendre pourquoi un pod est bloqué (volumes interdits, UID, hostPath, etc.).

---

## Brique 2 – Diagnostiquer un pod bloqué (SCC / SA)

**Position plan :** S5 J1–J2 (suite)

### Scénario type

1. Un pod reste en `CrashLoopBackOff` ou `CreateContainerError`.
2. Message d’erreur lié à `permission denied`, `privileged`, `runAsUser`, `hostPath` non autorisé, etc.

### Checklist CLI

```bash
# 1) Voir les événements récents
oc get events --sort-by=.lastTimestamp | tail -n 20

# 2) Inspecter le pod en détail
oc describe pod <POD>

# 3) Voir les logs du conteneur
oc logs <POD>                # premier conteneur
oc logs <POD> -c <container> # si plusieurs conteneurs

# 4) Vérifier la SA et la SCC
oc get pod <POD> -o jsonpath='{.spec.serviceAccountName}' ; echo
oc get pod <POD> -o jsonpath='{.metadata.annotations.openshift\.io/scc}' ; echo

# 5) Si besoin, changer la SA ou ajuster la SCC (via rôles/RBAC ou binding pré-existant)
oc set serviceaccount deployment/<DEPLOY> <SA-NAME>
```

### À retenir EX280

- Réflexe : `events` → `describe pod` → `logs` → `SA`/`SCC`.
- Dans l’examen, il y aura typiquement **un pod bloqué par SCC** à corriger (changer SA, retirer un volume interdit, etc.).

---

## Brique 3 – NetworkPolicies (deny-all + ouvertures ciblées)

**Position plan :** S5 J3–J4

### Concepts

- Sans **NetworkPolicy**, tout parle avec tout dans le cluster (dans le même réseau).
- Dès qu’une **NetPol** de type ingress est présente pour un pod, **tout est bloqué par défaut** sauf ce qui est explicitement autorisé.
- NetPol s’appuie sur des **labels** de pods et de namespaces.

### Préparation

```bash
# Vérifier que le projet a le bon label (souvent automatique)
oc get ns ex280-lab02 --show-labels

# S’assurer d’avoir plusieurs pods pour tester
oc get pods -o wide
```

### 3.1. Politique deny-all (ingress)

Fichier `netpol-deny-all.yaml` :

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: ex280-lab02
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

Application et vérification :

```bash
oc apply -f netpol-deny-all.yaml
oc get networkpolicy
oc describe networkpolicy deny-all-ingress
```

Effet : aucun pod du namespace ne reçoit plus de trafic entrant (sauf trafic autorisé par d’autres NetPols plus spécifiques).

### 3.2. Autoriser seulement le trafic vers httpd-demo depuis le même namespace

Fichier `netpol-allow-httpd-namespace.yaml` :

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-httpd-same-namespace
  namespace: ex280-lab02
spec:
  podSelector:
    matchLabels:
      app: httpd-demo
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector: {}
      ports:
        - protocol: TCP
          port: 8080
```

Application :

```bash
oc apply -f netpol-allow-httpd-namespace.yaml

# Tester depuis un autre pod "test" dans le même namespace
oc run netpol-tester --image=registry.access.redhat.com/ubi8/ubi -it --restart=Never -- bash

# Dans le shell du pod
curl -sS http://httpd-demo:8080 || echo "KO"
```

### À retenir EX280

- `podSelector: {}` avec `policyTypes: [Ingress]` → deny-all.
- Ajouter ensuite des NetPol de type `allow` très ciblées.
- Tester **en CLI** depuis un pod `oc run ...` avec `curl`.

---

## Brique 4 – NetworkPolicies avancées (ingress + egress)

**Position plan :** S5 J3–J4 (suite)

### Exemple : autoriser httpd-demo à sortir vers un service externe (DNS + HTTPS)

Fichier `netpol-egress-httpd.yaml` :

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: httpd-allow-egress
  namespace: ex280-lab02
spec:
  podSelector:
    matchLabels:
      app: httpd-demo
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector: {}
      ports:
        - protocol: TCP
          port: 53
        - protocol: UDP
          port: 53
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
      ports:
        - protocol: TCP
          port: 443
```

Application :

```bash
oc apply -f netpol-egress-httpd.yaml
```

### À retenir EX280

- `policyTypes` peut contenir `Ingress`, `Egress` ou les deux.
- `ipBlock` permet de restreindre par CIDR (attention à l’examen, rester simple).

---

## Brique 5 – Routes + TLS

**Position plan :** S5 J5

### Concepts

- **Route** = exposition HTTP/HTTPS via le routeur OpenShift.
- Terminaisons classiques :
  - `edge` : TLS au niveau routeur, backend en HTTP.
  - `passthrough` : TLS de bout en bout, routeur ne déchiffre pas.
  - `reencrypt` : TLS client→routeur + routeur→backend, certificat différent.

### 5.1. Route HTTP simple (déjà vue S1)

```bash
oc get route httpd-demo
oc describe route httpd-demo
```

### 5.2. Route TLS en edge termination

```bash
# Modifier la route pour activer TLS "edge"
oc annotate route httpd-demo \
  kubernetes.io/tls-acme="true" --overwrite  # si IngressController configuré pour ACME

# ou éditer la route en YAML
oc edit route httpd-demo
```

Exemple de spec TLS minimale :

```yaml
spec:
  to:
    kind: Service
    name: httpd-demo
  port:
    targetPort: 8080
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

Vérification :

```bash
oc get route httpd-demo -o wide
# Tester dans le navigateur ou via curl
curl -k https://httpd-demo-ex280-lab02.apps-crc.testing
```

### 5.3. Points à vérifier en cas de problème TLS

```bash
# 1) Nom de la route
oc get route httpd-demo

# 2) Service & endpoints
oc get svc httpd-demo
oc describe svc httpd-demo
oc get endpoints httpd-demo

# 3) Logs du routeur (si autorisé)
oc get pods -n openshift-ingress
```

### À retenir EX280

- Savoir lire la spec TLS d’une route.
- Edge termination basique est suffisante pour l’examen.
- Toujours vérifier Service + Endpoints quand la route ne répond pas.

---

## Brique 6 – Exposition non-HTTP (vue d’ensemble)

**Position plan :** S5 J5

### Concepts

- OpenShift privilégie l’expo **HTTP/HTTPS via Route**.
- Pour du non-HTTP (TCP brut, DB, etc.), on utilisera :
  - `Service` de type ClusterIP (interne),
  - ou selon l’infra, `NodePort` / `LoadBalancer` (moins fréquent sur CRC).

### Exemple rapide (mode théorie/pratique si activé)

```bash
# Service TCP simple
oc expose deploy httpd-demo --name=httpd-demo-tcp --port=8443 --target-port=8443 --type=ClusterIP
oc describe svc httpd-demo-tcp
```

À l’examen, il peut être demandé d’exposer un service non HTTP **à l’intérieur du cluster** (autre pod qui s’y connecte), pas forcément vers l’extérieur.

---

## Synthèse Semaine 5

Réflexes à mémoriser :

- **SCC/SA**
  - `oc get pod <POD> -o jsonpath='{.spec.serviceAccountName}'`
  - `oc get pod <POD> -o jsonpath='{.metadata.annotations.openshift\.io/scc}'`
  - `oc set serviceaccount deployment/<DEPLOY> <SA>`

- **NetworkPolicies**
  - `oc get networkpolicy`
  - Deny-all = `podSelector: {}` + `policyTypes: [Ingress]`.
  - Tester avec `oc run ... --image=ubi` + `curl`.

- **Routes/TLS**
  - `oc get route`, `oc describe route`.
  - Termination `edge` + `insecureEdgeTerminationPolicy`.
  - Vérifier Service + Endpoints systématiquement.

---

## Semaine 6 – Operators, Troubleshooting structuré & Tekton (pont EX288)

### Objectif fin S6

Savoir :
- Installer / supprimer un **Operator** via OLM (au moins via YAML Subscription/OperatorGroup).
- Créer une **ressource personnalisée (CR)** simple fournie par cet Operator.
- Appliquer un **playbook de troubleshooting** commun (image, quota, SCC, NetPol, route, etc.).
- Utiliser **Tekton (OpenShift Pipelines)** pour exécuter une Task/Pipeline simple (pont EX288).

---

## Brique 7 – OLM / OperatorHub : installation d’un Operator

**Position plan :** S6 J1

### Concepts

- OLM (Operator Lifecycle Manager) gère l’installation/MAJ des Operators.
- Un Operator est installé via :
  - un **OperatorGroup**
  - une **Subscription**
- L’Operator crée ensuite des **ClusterServiceVersions (CSV)** et des CRD.

### Exemple : vérifier les Operators déjà présents

```bash
# Operators installés dans tous les namespaces
oc get csv -A

# Operators visibles dans un namespace donné
oc get csv -n openshift-operators
```

### Exemple d’installation (modèle générique)

Namespace cible pour un operator applicatif :

```bash
oc new-project ex280-operators || oc project ex280-operators
```

`operatorgroup-generic.yaml` :

```yaml
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: ex280-operators-og
  namespace: ex280-operators
spec:
  targetNamespaces:
    - ex280-operators
```

`subscription-generic.yaml` (modèle, le nom de package/channel dépend de l’operator choisi) :

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: my-operator-sub
  namespace: ex280-operators
spec:
  channel: stable
  name: my-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
```

Application :

```bash
oc apply -f operatorgroup-generic.yaml
oc apply -f subscription-generic.yaml

# Suivre l’état
oc get subscription -n ex280-operators
oc get csv -n ex280-operators
```

### À retenir EX280

- Pattern YAML : **OperatorGroup + Subscription**.
- `oc get csv -n <ns>` pour vérifier que l’operator est bien installé (CSV en `Succeeded`).

---

## Brique 8 – CRD / CR : utiliser l’Operator

**Position plan :** S6 J2

### Concepts

- Un Operator expose des **CRD** → types de ressources custom (par ex. `Task`, `Pipeline`, `Database`, etc.).
- Tu crées une **CR** (Custom Resource) de ce type, l’Operator observe et déploie le nécessaire.

### Vérifier les CRD

```bash
# Toutes les CRD
oc get crd | head

# Filtrer par mot clé
oc get crd | grep pipeline || true
oc get crd | grep database || true
```

### Exemple avec OpenShift Pipelines (Tekton) – si déjà présent

```bash
oc get crd | grep tekton
oc api-resources | grep -i tekton
```

Si tu as la CRD `tasks.tekton.dev` :

```bash
oc get tasks.tekton.dev -A
```

### À retenir EX280/EX288

- Un Operator n’est pas une simple image : il gère un **cycle de vie complet** via des CR.
- L’examen peut demander de **créer une CR** basique fournie par un Operator.

---

## Brique 9 – Troubleshooting structuré (Playbook)

**Position plan :** S6 J3–J4

### 9.1. Problème image (ImagePullBackOff)

```bash
# Symptôme
oc get pods

# Détails
oc describe pod <POD> | sed -n '/Events:/,$p'

# Si erreur image
# - image not found
# - unauthorized

# Vérifs
oc get secret -n <ns>
# vérifier imagePullSecret si besoin

# Correction
oc set image deployment/<DEPLOY> <CONTAINER>=<image-correcte>
# ou
oc patch deployment/<DEPLOY> -p '{"spec":{"template":{"spec":{"imagePullSecrets":[{"name":"<secret>"}]}}}}'
```

### 9.2. Problème quota (exceeded quota)

```bash
# Symptôme : création/scale refuse avec Forbidden exceeded quota

oc describe resourcequota -A
oc describe resourcequota <NOM> -n <NS>

# Vérifier Used vs Hard

# Correction
# - réduire des replicas
# - supprimer des pods inutiles
oc scale deployment <DEPLOY> --replicas=0
```

### 9.3. Problème SCC (CreateContainerError / permission denied)

```bash
oc get events --sort-by=.lastTimestamp | tail -n 20
oc describe pod <POD>

# Vérifier la SA et la SCC
oc get pod <POD> -o jsonpath='{.spec.serviceAccountName}' ; echo
oc get pod <POD> -o jsonpath='{.metadata.annotations.openshift\.io/scc}' ; echo

# Correction fréquente
oc set serviceaccount deployment/<DEPLOY> <SA-AUTORISEE>
```

### 9.4. Problème NetworkPolicy (pod qui ne parle plus)

```bash
# Vérifier NetPol dans le namespace
oc get networkpolicy

# Inspecter la cible
oc describe networkpolicy <NP>

# Tester depuis un pod de test
oc run netpol-debug --image=registry.access.redhat.com/ubi8/ubi -it --restart=Never -- bash
curl -v http://<svc>:<port> || echo "KO"
```

### 9.5. Problème Route / TLS

```bash
oc get route
oc describe route <ROUTE>

# Vérifier le Service + Endpoints
oc describe svc <SVC>
oc get endpoints <SVC>

# Tester depuis un pod interne
oc run route-debug --image=registry.access.redhat.com/ubi8/ubi -it --restart=Never -- bash
curl -vk http://<svc>:<port>
```

### À retenir

Ordre logique pour tout incident :

1. `oc get` (vue globale)
2. `oc describe` (événements, spec/selector)
3. `oc logs` (pour les containers qui démarrent)
4. Cas particuliers : `quota`, `SCC`, `NetPol`, `Route/TLS`, `Operator/CR`.

---

## Brique 10 – Tekton / OpenShift Pipelines (pont EX288)

**Position plan :** S6 J5

### Concepts

- Tekton = moteur de **CI/CD cloud-native**.
- Ressources principales :
  - `Task` : suite de `steps` (containers).
  - `TaskRun` : exécution d’une Task.
  - `Pipeline` / `PipelineRun` : enchaînement de Tasks.

### Namespace CI/CD

```bash
oc new-project ex280-cicd || oc project ex280-cicd
```

### Exemple de Task simple

`task-echo.yaml` :

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: echo-task
  namespace: ex280-cicd
spec:
  steps:
    - name: echo
      image: registry.access.redhat.com/ubi8/ubi
      script: |
        #!/usr/bin/env bash
        echo "Task Tekton EX280-EX288 OK"
```

Application :

```bash
oc apply -f task-echo.yaml
oc get tasks -n ex280-cicd
```

### TaskRun pour exécuter la Task

`taskrun-echo.yaml` :

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: echo-taskrun
  namespace: ex280-cicd
spec:
  taskRef:
    name: echo-task
```

Application et vérification :

```bash
oc apply -f taskrun-echo.yaml
oc get taskrun -n ex280-cicd
oc describe taskrun echo-taskrun -n ex280-cicd
oc logs -l tekton.dev/taskRun=echo-taskrun -n ex280-cicd
```

### À retenir EX288

- Pattern minimal : `Task` + `TaskRun`.
- `oc logs -l tekton.dev/taskRun=<name>` pour voir les logs.

---

## Synthèse Semaine 6

Points clés à garder en tête pour l’examen :

- **Operators (OLM)**
  - OperatorGroup + Subscription pour installer.
  - `oc get csv -n <ns>` pour vérifier l’état.
  - Utilisation d’au moins une **CR** basique de l’Operator.

- **Troubleshooting**
  - Toujours passer par une **méthode** : `get` → `describe` → `logs` → cas spéciaux (quota, SCC, NetPol, Route, Operator).
  - Savoir reconnaître les messages d’erreur typiques : `ImagePullBackOff`, `exceeded quota`, `forbidden`, `CreateContainerConfigError`, `CrashLoopBackOff`.

- **Tekton**
  - Comprendre qu’une Task est un objet Kubernetes (CRD), appliqué comme du YAML.
  - Savoir lancer une TaskRun et lire ses logs.

Ces briques complètent les semaines S1–S4 : à S6, tu as tous les réflexes EX280/EX288 pour **corriger un cluster en panne** et **automatiser un minimum de pipeline**.

