# Plan Formation OpenShift EX280 / EX288 – Semaine 1 + TP CRC

## 1. Objectif global de la formation

Objectif sur 8 semaines (vue synthétique) :

- **S1–S3 : Socle Kubernetes / OpenShift** (équivalent DO180 maison)
  - Pods, Deployments, Services, Routes.
  - ConfigMaps, Secrets, Probes, Resources, PVC de base.
- **S4–S6 : Administration OpenShift (prod)** (équivalent DO280 maison)
  - Users / RBAC, quotas, LimitRanges, SecurityContext, NetworkPolicy.
  - Monitoring, logging, opérateurs, sauvegarde/restauration de ressources.
- **S7–S8 : Préparation ciblée EX280 (+ ponts EX288)**
  - Scénarios d’examen, reconstitution d’environnements.
  - Examens blancs chronométrés, check-list de révision.

Ce document se concentre sur **Semaine 1** et les **TP réalisés sur CRC**.

---

## 2. Semaine 1 – Objectif détaillé

**Objectif fin S1** :

Être capable, **en ligne de commande uniquement**, de :

1. Créer un projet (namespace) de travail.
2. Déployer une application stateless avec `Deployment`.
3. Exposer l’application via un `Service` + `Route` et la tester dans le navigateur.
4. Ajuster le nombre de replicas (scaling) et comprendre la relation Deployment → ReplicaSet → Pods → Endpoints.
5. Gérer la configuration applicative avec **ConfigMap** et **Secret**, injectés en variables d’environnement.
6. Configurer des **probes** Readiness / Liveness et des **requests/limits** CPU/Mémoire.
7. Utiliser **logs** et **events** pour diagnostiquer les problèmes.
8. (Preview fin S1) Attacher un **PVC simple** à un pod et vérifier la persistance.

---

## 3. Environnement de lab – CRC

### 3.1. Vérifier l’état de CRC

```bash
crc status
```

Sortie attendue (exemple) :

- `CRC VM:          Running`
- `OpenShift:       Running (v4.x.y)`

### 3.2. Récupérer l’URL API et le mot de passe kubeadmin

```bash
crc console --credentials
```

Exemple de sortie :

```text
To login as a regular user, run 'oc login -u developer -p developer https://api.crc.testing:6443'.
To login as an admin, run 'oc login -u kubeadmin -p <MOT_DE_PASSE> https://api.crc.testing:6443'.
```

### 3.3. Connexion au cluster

```bash
oc login -u kubeadmin -p <MOT_DE_PASSE> https://api.crc.testing:6443

oc whoami        # doit renvoyer kubeadmin
oc get nodes     # au moins 1 nœud Ready
```

---

## 4. Brique 1 – Projet + Deployment + Service + Route

**Position dans le plan** : Semaine 1, jours 1–3.

### 4.1. Création d’un projet de lab

```bash
oc new-project ex280-lab01

oc project       # vérifie le projet courant
oc get all       # doit être vide : "No resources found"
```

Même chose pour un 2ᵉ projet d’examen blanc :

```bash
oc new-project ex280-lab02
oc project
oc get all
```

### 4.2. Création du Deployment

**Pattern à mémoriser** :

> Deployment → Pods → Service → Route → Navigateur

Commande utilisée :

```bash
oc create deployment httpd-demo \
  --image=registry.access.redhat.com/ubi8/httpd-24 \
  --port=8080

oc get pods
```

Points à retenir :

- `oc create deployment` crée un Deployment et le ReplicaSet associé.
- Le **pod** aura un nom du type `httpd-demo-<hash>-<suffixe>`.
- `STATUS` doit passer de `ContainerCreating` à `Running`.

### 4.3. Création du Service (ClusterIP)

Commande :

```bash
oc expose deployment httpd-demo --port=8080

oc get svc
```

Résultat typique :

```text
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
httpd-demo   ClusterIP   10.217.5.167    <none>        8080/TCP   ...
```

### 4.4. Création de la Route

```bash
oc expose service httpd-demo

oc get route
```

Exemple :

```text
NAME         HOST/PORT                                 PATH   SERVICES     PORT   TERMINATION   WILDCARD
httpd-demo   httpd-demo-ex280-lab01.apps-crc.testing          httpd-demo   8080                 None
```

### 4.5. Test dans le navigateur

URL à tester :

```text
http://httpd-demo-ex280-lab01.apps-crc.testing
```

En cas de problème DNS sous Windows, possibilité d’ajouter une entrée dans `C:\\Windows\\System32\\drivers\\etc\\hosts` pointant vers l’IP de `apps-crc.testing`.

---

## 5. Brique 2 – Scaling & Endpoints

**Position dans le plan** : Semaine 1, jour 3.

### 5.1. Scaling du Deployment

```bash
oc scale deployment httpd-demo --replicas=3
oc get pods -o wide
```

Points à observer :

- 3 pods `httpd-demo-...` en `Running`.
- IP différentes sur le même nœud CRC.

### 5.2. Relation Service ↔ Endpoints ↔ Pods

Afficher les endpoints du Service :

```bash
oc get endpoints httpd-demo
```

Exemple :

```text
NAME         ENDPOINTS                                               AGE
httpd-demo   10.217.1.111:8080,10.217.1.140:8080,10.217.1.141:8080   ...
```

Lire les détails du Service :

```bash
oc describe svc httpd-demo
```

À regarder :

- `Selector: app=httpd-demo` → sélection de pods.
- `Endpoints: <IP1>:8080,<IP2>:8080,...` → pods cibles.

### 5.3. Retour à 1 replica

```bash
oc scale deployment httpd-demo --replicas=1
oc get pods -o wide
oc get endpoints httpd-demo
```

Résultat :

- 1 seul pod.
- 1 seule IP dans les endpoints.

---

## 6. Brique 3 – ConfigMap & Secret → variables d’environnement

**Position dans le plan** : Semaine 1, jours 4–5.

### 6.1. ConfigMap (config non sensible)

Création :

```bash
oc create configmap httpd-config \
  --from-literal=APP_ENV=ex280-lab02 \
  --from-literal=APP_OWNER=zidane

oc get configmap
```

Injection dans le Deployment :

```bash
oc set env deployment/httpd-demo --from=configmap/httpd-config

oc set env deployment/httpd-demo --list
```

Vérification dans le pod :

```bash
oc get pods
oc exec -it <NOM_DU_POD> -- env | grep APP_
```

Exemple attendu :

```text
APP_ENV=ex280-lab02
APP_OWNER=zidane
```

### 6.2. Secret (données sensibles)

Création :

```bash
oc create secret generic httpd-secret \
  --from-literal=APP_PASSWORD=S3cr3t-Ex280

oc get secret
```

Injection dans le Deployment :

```bash
oc set env deployment/httpd-demo --from=secret/httpd-secret

oc set env deployment/httpd-demo --list
```

Vérification dans le pod :

```bash
oc get pods
oc exec -it <NOM_DU_POD> -- env | grep APP_
```

Exemple attendu :

```text
APP_ENV=ex280-lab02
APP_OWNER=zidane
APP_PASSWORD=S3cr3t-Ex280
```

### 6.3. Résumé à mémoriser

- **ConfigMap** : config non sensible → `oc create configmap`, `oc set env ... --from=configmap/...`.
- **Secret** : mots de passe, tokens → `oc create secret generic`, `oc set env ... --from=secret/...`.
- Vérifier toujours avec :
  - `oc set env deployment/... --list`
  - `oc exec ... env | grep <clé>`

---

## 7. Brique 4 – Probes & Resources (requests/limits)

**Position dans le plan** : Semaine 1, jours 5–6.

### 7.1. Readiness / Liveness – notions clés

- **Readiness probe** :
  - Question : *"Est-ce que ce pod est prêt à recevoir du trafic ?"*
  - Si KO : pod retiré des **Endpoints** du Service, mais souvent toujours `Running`.
- **Liveness probe** :
  - Question : *"Est-ce que ce conteneur est encore vivant ?"*
  - Si KO répétée : le conteneur est **redémarré** par le kubelet (`RESTARTS` augmente).

Formule à retenir :

- **Readiness = trafic ON/OFF**.
- **Liveness = reboot ON/OFF**.

### 7.2. Configuration des probes TCP (sur 8080)

Suppression d’anciennes probes (si nécessaire) :

```bash
oc set probe deployment/httpd-demo --readiness --remove
oc set probe deployment/httpd-demo --liveness  --remove
```

Ajout de probes TCP :

```bash
oc set probe deployment/httpd-demo \
  --readiness \
  --open-tcp=8080 \
  --initial-delay-seconds=5 \
  --timeout-seconds=2

oc set probe deployment/httpd-demo \
  --liveness \
  --open-tcp=8080 \
  --initial-delay-seconds=10 \
  --timeout-seconds=2
```

Vérification :

```bash
oc describe deployment httpd-demo | egrep 'Liveness|Readiness'
```

Exemple :

```text
Liveness:   tcp-socket :8080 delay=10s timeout=2s period=10s #success=1 #failure=3
Readiness:  tcp-socket :8080 delay=5s  timeout=2s period=10s #success=1 #failure=3
```

Redémarrage propre :

```bash
oc rollout restart deployment/httpd-demo
oc rollout status deployment/httpd-demo
```

### 7.3. Requests / Limits CPU & mémoire

Ajout sur le Deployment :

```bash
oc set resources deployment/httpd-demo \
  --requests=cpu=50m,memory=64Mi \
  --limits=cpu=200m,memory=256Mi

oc describe deployment httpd-demo | grep -A5 Limits
```

Exemple :

```text
Limits:
  cpu:     200m
  memory:  256Mi
Requests:
  cpu:     50m
  memory:  64Mi
```

Vérification sur le pod :

```bash
oc get pods
oc describe pod <NOM_DU_POD> | grep -A5 Limits
```

Notions à retenir :

- `requests` : ressources minimales demandées pour le scheduling.
- `limits` : plafond que le conteneur ne doit pas dépasser.
- Unité CPU : `m` = milliCPU (ex. `50m` = 0,05 vCPU).
- Mémoire en `Mi` (MiB).

---

## 8. Brique 5 – Logs & Events (diagnostic)

**Position dans le plan** : Semaine 1, fin de semaine (diagnostic de base).

### 8.1. Logs du conteneur

```bash
oc logs <POD>
oc logs <POD> -f   # suivi en temps réel
```

Usage :

- Comprendre ce que fait l’application.
- Voir erreurs applicatives, warnings, stacktraces.

Exemple vu : démarrage Apache (warnings SSL, ServerName) puis "resuming normal operations".

### 8.2. Events du pod

```bash
oc describe pod <POD> | tail -n 20
```

Permet de voir :

- `Scheduled`, `Pulled`, `Created`, `Started`.
- Éventuels `Unhealthy` (probes KO), `BackOff`, etc.

### 8.3. Events du namespace

```bash
oc get events --sort-by=.lastTimestamp | tail -n 10
```

Usage :

- Vue globale des derniers événements dans le projet.
- Très utile pour repérer rapidement des erreurs de scheduling, d’image, de probes, etc.

---

## 9. Preview Brique 6 – PVC simple (à faire en fin de Semaine 1)

Objectif :

- Créer un **PersistentVolumeClaim** simple (ex. 1Gi, `ReadWriteOnce`).
- Monter ce PVC dans le pod `httpd-demo`.
- Écrire un fichier dans le volume.
- Redémarrer le pod et vérifier que le fichier est toujours présent.

Exemple d’

