# EX280 – Semaine 3 – Canvas complet (Rollout, Rollback, ImageStreams)

## 1. Contexte de travail

- Cluster : OpenShift local **CRC**.
- Projet de labo : **`ex280-lab02`**.
- Terminal : Git Bash sur Windows 11.
- Application de base : **`httpd-demo`** (Deployment + Service + Route).

Objectif global de la semaine 3 :
- Savoir gérer le **cycle de vie d’un Deployment** (rollout / pause / resume / rollback).
- Comprendre la création et l’usage d’un **ImageStream** local.
- Déployer une nouvelle appli à partir d’un **ImageStream** et l’exposer via Route.
- Savoir **diagnostiquer** les situations `Pending`, erreurs réseau et erreurs HTTP (403).

---

## 2. Vérifications de base sur le projet et le déploiement

### 2.1. Vérifier le projet courant

```bash
oc whoami
oc project
oc projects
```

Tu dois voir :
- `ex280-lab02` comme projet courant.

### 2.2. Vérifier les nodes et les ressources

```bash
oc get nodes
oc get all
```

Objectif :
- Vérifier que le node `crc` est `Ready`.
- Voir les Deployments, Services et Pods existants (dont `httpd-demo`).

---

## 3. Rollout / pause / resume / rollback sur `httpd-demo`

### 3.1. Pause du déploiement

Commande exécutée :

```bash
oc rollout pause deployment/httpd-demo
```

Puis vérification :

```bash
oc get deploy httpd-demo -o jsonpath='{.spec.paused}{"\n"}'
```

Résultat observé :

```text
deployment.apps/httpd-demo paused
true
```

Lecture :
- Le Deployment **`httpd-demo`** est maintenant en **état `paused`**.
- Tant qu’il est pausé, les changements sur le template de Pod ne déclenchent pas de nouveau rollout.

### 3.2. Patch du template pendant le pause

Objectif :
- Modifier le template de Pod (ajouter une annotation) **sans lancer immédiatement un nouveau rollout**.

Commande exécutée :

```bash
oc patch deployment/httpd-demo \
  -p '{"spec":{"template":{"metadata":{"annotations":{"demo-change":"paused-test"}}}}}'
```

Vérifier les ReplicaSets associés :

```bash
oc get rs -l app=httpd-demo
```

et les Pods :

```bash
oc get pod -l app=httpd-demo -o wide
```

Constat :
- Plusieurs ReplicaSets `httpd-demo-xxxxx` existent avec DESIRED=0.
- Un seul ReplicaSet actif (ex. `httpd-demo-7df4fbf985`) avec **1 Pod Running**.

Idée clé :
- Le patch modifie le **template** mais comme le Deployment est **pausé**, le nouveau ReplicaSet n’est pas encore utilisé.

### 3.3. Reprendre le déploiement

Commande exécutée :

```bash
oc rollout resume deployment/httpd-demo
oc rollout status deployment/httpd-demo
```

Message vu :

```text
Waiting for deployment "httpd-demo" rollout to finish: 1 old replicas are pending termination...
error: deployment "httpd-demo" exceeded its progress deadline
```

Puis inspection des ReplicaSets et Pods :

```bash
oc get rs -l app=httpd-demo
oc get pod -l app=httpd-demo -o wide
```

On voit :
- Ancien Pod Running (par ex. `httpd-demo-7df4fbf985-g4rpx`).
- Nouveau Pod en `Pending` (par ex. `httpd-demo-68fdd9fd7d-kvwrz`).

### 3.4. Diagnostic du Pod `Pending` (Insufficient cpu)

Commande :

```bash
oc describe pod httpd-demo-68fdd9fd7d-kvwrz
```

Événements importants :

```text
Warning  FailedScheduling  ...  0/1 nodes are available: 1 Insufficient cpu.
```

Conclusion :
- Le nouveau Pod ne peut pas être planifié car le node a **CPU insuffisant**.
- C’est un cas typique d’examen : **comprendre pourquoi un Pod reste en Pending**.

### 3.5. Historique et rollback du Deployment

Visualiser l’historique :

```bash
oc rollout history deployment/httpd-demo
```

On obtient une liste de révisions (6,7,8… 17). La révision 14 n’existe pas, d’où l’erreur :

```bash
oc rollout undo deployment/httpd-demo --to-revision=14
# → error: unable to find specified revision 14 in history
```

Rollback vers la révision précédente (la dernière bonne) :

```bash
oc rollout undo deployment/httpd-demo
```

Puis vérification :

```bash
oc get rs -l app=httpd-demo
oc get pod -l app=httpd-demo -o wide
```

Résultat :
- Le ReplicaSet `httpd-demo-7df4fbf985` redevient actif.
- Un Pod Running (`1/1` Ready) reste pour `httpd-demo`.

### 3.6. Vérifier les images utilisées

Image déclarée dans le template :

```bash
oc get deploy httpd-demo \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Image réelle utilisée par le Pod :

```bash
oc get pod -l app=httpd-demo \
  -o jsonpath='{.items[0].status.containerStatuses[0].image}{"\n"}{.items[0].status.containerStatuses[0].imageID}{"\n"}'
```

Ce qui met en évidence :
- **Nom logique** : `registry.access.redhat.com/ubi8/httpd-24:latest`.
- **Digest exact** : `@sha256:...`.

---

## 4. ImageStream `httpd-ubi` et nouvelle application

### 4.1. Création et import de l’ImageStream

1. Vérifier s’il existe déjà des ImageStreams :

```bash
oc get is
```

2. Créer un ImageStream vide :

```bash
oc create imagestream httpd-ubi
```

3. Importer l’image UBI httpd-24 dans l’ImageStream :

```bash
oc import-image httpd-ubi \
  --from=registry.access.redhat.com/ubi8/httpd-24:latest \
  --confirm
```

4. Vérifier le résultat :

```bash
oc describe is httpd-ubi
```

Points clés observés :
- `Image Repository: default-route-openshift-image-registry.apps-crc.testing/ex280-lab02/httpd-ubi`
- Tag `latest` pointant sur le digest Red Hat.
- Liste de labels, metadata, variables d’environnement…

Notion clé :
- **ImageStream** = abstraction locale au projet qui suit des tags d’images.

### 4.2. Créer une application à partir de l’ImageStream

Commande utilisée :

```bash
oc new-app --image-stream=httpd-ubi:latest --name=httpd-ubi-app
```

Erreur initiale :

```text
error: deployments.apps "httpd-ubi-app" already exists
error: services "httpd-ubi-app" already exists
```

Mais les objets existent bien :

```bash
oc get deploy,svc,pod
```

Résultat typique :

```text
deployment.apps/httpd-ubi-app   0/1   1   0   15m
service/httpd-ubi-app           ClusterIP ... 8080/TCP,8443/TCP
pod/httpd-ubi-app-8456fd6d9c-vwd4r   0/1   Pending ...
```

### 4.3. Diagnostic du Pod `httpd-ubi-app` en Pending

Inspection :

```bash
oc describe pod httpd-ubi-app-8456fd6d9c-vwd4r
```

Événements :

```text
Warning  FailedScheduling  ...  0/1 nodes are available: 1 Insufficient cpu.
```

Ce qui montre encore :
- Problème d’**Insufficient cpu** sur le node `crc`.

### 4.4. Libérer les ressources CPU (scale de `httpd-demo`)

Objectif :
- Libérer de la CPU en arrêtant l’appli `httpd-demo` pour laisser la place à `httpd-ubi-app`.

Commande :

```bash
oc scale deployment/httpd-demo --replicas=0
```

Puis :

```bash
oc get pod -l deployment=httpd-ubi-app -o wide
oc get pod -l app=httpd-demo
```

Résultat :
- `httpd-demo` n’a plus de Pod.
- `httpd-ubi-app-8456fd6d9c-vwd4r` passe en `ContainerCreating` puis en `Running`.

Vérification détaillée :

```bash
oc describe pod httpd-ubi-app-8456fd6d9c-vwd4r
```

À la fin :

```text
Status:           Running
Ready:            True
```

---

## 5. Service, Route et test HTTP sur `httpd-ubi-app`

### 5.1. Vérifier le service et la route

Commandes :

```bash
oc get svc httpd-ubi-app
oc get route httpd-ubi-app || echo "pas de route"
```

Création de la route si nécessaire :

```bash
oc expose service/httpd-ubi-app
oc get route httpd-ubi-app
```

Exemple de sortie :

```text
NAME            HOST/PORT                                    SERVICES        PORT
httpd-ubi-app   httpd-ubi-app-ex280-lab02.apps-crc.testing   httpd-ubi-app   8080-tcp
```

### 5.2. Premier test HTTP (403 Forbidden)

Depuis la machine locale :

```bash
curl -I http://httpd-ubi-app-ex280-lab02.apps-crc.testing
```

Réponse :

```text
HTTP/1.1 403 Forbidden
server: Apache/2.4.37 (Red Hat Enterprise Linux)
...
content-length: 4927
content-type: text/html; charset=UTF-8
```

Analyse :
- L’application répond, mais avec une **page 403 par défaut** fournie par l’image `rhel8/httpd-24`.
- On n’a pas encore fourni de contenu applicatif (`index.html`).

---

## 6. Contenu applicatif dans le container httpd

### 6.1. Première tentative d’écriture dans le container (Permission denied)

Connexion dans le Pod :

```bash
oc rsh deploy/httpd-ubi-app
```

Puis :

```bash
pwd
ls -l
```

Tu as constaté :
- `pwd` → `/opt/app-root/src`
- `ls -l` → répertoire vide.

Tentative d’écrire un `index.html` :

```bash
echo 'Hello from httpd-ubi-app on OpenShift EX280' > index.html
# → Permission denied
```

Même chose dans `/var/www/html` :

```bash
cd /var/www/html
ls -l
# total 0

echo 'Hello...' > index.html
# → Permission denied
```

Conclusion :
- Le processus httpd tourne avec un user non root (exigence de sécurité), et les répertoires montés ne sont pas forcément modifiables depuis le shell tel qu’on l’a lancé.

### 6.2. Stratégie correcte : préparer le fichier localement, puis `oc cp`

1. Sur ta machine locale (Git Bash), créer un fichier `index.html` :

```bash
cd /c/workspaces/openshift2026/1/ex280-lab02
cat > index.html << 'EOF'
Hello from httpd-ubi-app on OpenShift EX280
EOF
```

2. Récupérer le nom du Pod :

```bash
oc get pod -l deployment=httpd-ubi-app
# ex: httpd-ubi-app-8456fd6d9c-vwd4r
```

3. Copier le fichier dans le container :

```bash
oc cp index.html \
  httpd-ubi-app-8456fd6d9c-vwd4r:/opt/app-root/src/index.html
```

4. Vérifier dans le Pod :

```bash
oc rsh deploy/httpd-ubi-app
cd /opt/app-root/src
ls -l
cat index.html
exit
```

### 6.3. Test HTTP après déploiement du contenu

Nouvelle requête :

```bash
curl -I http://httpd-ubi-app-ex280-lab02.apps-crc.testing
```

Réponse obtenue :

```text
HTTP/1.1 200 OK
last-modified: Thu, 04 Dec 2025 09:52:43 GMT
content-length: 44
content-type: text/html; charset=UTF-8
cache-control: private
```

Cette fois :
- **Code 200** = succès.
- Le serveur httpd sert bien ton `index.html` personnalisé.

---

## 7. Synthèse – Compétences Semaine 3 validées

1. **Rollout / rollback d’un Deployment**
   - Pauser un déploiement :
     ```bash
     oc rollout pause deployment/httpd-demo
     ```
   - Modifier le template sans déclencher de rollout.
   - Reprendre le déploiement :
     ```bash
     oc rollout resume deployment/httpd-demo
     oc rollout status deployment/httpd-demo
     ```
   - Voir l’historique et faire un rollback :
     ```bash
     oc rollout history deployment/httpd-demo
     oc rollout undo deployment/httpd-demo
     ```

2. **Diagnostic de Pods `Pending`**
   - Utiliser :
     ```bash
     oc describe pod <nom-pod>
     ```
   - Repérer les messages `Insufficient cpu`.
   - Corriger en ajustant les replicas ou les quotas (ici : `oc scale deployment/httpd-demo --replicas=0`).

3. **ImageStreams**
   - Créer et importer une image :
     ```bash
     oc create imagestream httpd-ubi
     oc import-image httpd-ubi --from=registry.access.redhat.com/ubi8/httpd-24:latest --confirm
     oc describe is httpd-ubi
     ```
   - Comprendre que l’ImageStream est un **nom logique** dans le projet qui pointe vers un digest.

4. **Création d’une application depuis un ImageStream**
   - Commande clé :
     ```bash
     oc new-app --image-stream=httpd-ubi:latest --name=httpd-ubi-app
     ```
   - Vérifier :
     ```bash
     oc get deploy,svc,pod
     ```

5. **Exposition via Service + Route et test HTTP**
   - Vérifier/Créer le Service et la Route :
     ```bash
     oc get svc httpd-ubi-app
     oc get route httpd-ubi-app || oc expose service/httpd-ubi-app
     ```
   - Tester depuis l’extérieur :
     ```bash
     curl -I http://httpd-ubi-app-ex280-lab02.apps-crc.testing
     ```

6. **Gestion du contenu applicatif dans le container**
   - Comprendre les limitations de permissions (`Permission denied`).
   - Préparer un fichier localement puis utiliser `oc cp` pour le pousser dans le Pod.
   - Vérifier le résultat via `curl`.

---

## 8. Mini check-list mentale S3 (EX280)

- Savoir utiliser :
  - `oc rollout pause/resume/status/history/undo`.
  - `oc describe pod` pour analyser `Pending` (notamment `Insufficient cpu`).
  - `oc create imagestream`, `oc import-image`, `oc describe is`.
  - `oc new-app --image-stream=...`.
  - `oc expose service/...` et `oc get route`.
  - `oc cp` pour pousser un fichier dans un Pod.
- Savoir lire les événements dans `describe` (FailedScheduling, FailedCreatePodSandBox…).
- Savoir conclure rapidement :
  - CPU saturée → adapter les replicas / quotas.
  - Route OK + HTTP 200 → appli fonctionnelle.

> À partir de ce canvas, la Semaine 3 est considérée comme **validée** sur la partie pratique (rollout, rollback, ImageStream, déploiement et exposition d’une appli httpd). La suite (Semaine 4) se concentre sur identité, multi‑tenancy (RBAC/quotas) et Helm.

