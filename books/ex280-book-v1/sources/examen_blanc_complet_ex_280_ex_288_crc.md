# Examen blanc complet EX280 / Ponts EX288 (sur CRC local)

Durée indicative : **3 h**  
Cluster : **CRC local** (single node)  
Contexte : tu disposes d’un accès `kubeadmin` et d’un utilisateur développeur (`developer` ou équivalent).

> Conseil : traite les sections **dans l’ordre**. Chaque section est un bloc de compétences EX280, avec quelques ponts EX288 (build/imagestream/registry).

---

## 0. Énoncé global

Tu joues le rôle d’admin OpenShift pour une équipe qui veut héberger une petite application `catalog` composée de :

- Un **frontend HTTP** stateless (Apache httpd) exposé en HTTPS.
- Un **service batch** (Job/CronJob) qui lance un traitement de nettoyage.
- Une base de données simulée par un **volume persistant**.

Tu dois :

1. Préparer les **projets**, quotas et garde-fous.  
2. Déployer l’app, exposer les routes, configurer les ressources.  
3. Mettre en place le **stockage persistant** et le batch.  
4. Gérer l’**identité** (users/groups/RBAC/SA/SCC).  
5. Mettre en place **labels/NetPol** pour filtrer le trafic.  
6. Gérer un **update** applicatif et un **rollback**.  
7. (Pont EX288) Préparer une **BuildConfig + ImageStream** pour produire une nouvelle version de l’image.

À la fin, tu remplis la **checklist finale**.

---

## 1. Préparation des projets et contexte

### 1.1. Projets à créer

Crée les projets suivants :

- `ex280-catalog-dev`
- `ex280-catalog-tools`

Contraintes :

- Toutes les ressources applicatives seront dans `ex280-catalog-dev`.
- Les outils de build (BuildConfig, ImageStream, éventuellement pipelines) seront dans `ex280-catalog-tools`.

### 1.2. Vérifications demandées

Pour chaque projet :

1. Affiche les **labels** du namespace.  
2. Ajoute un label `owner=zidane` sur les 2 projets.  
3. Ajoute un label `env=dev` sur `ex280-catalog-dev`.

Note dans ton brouillon :

- Les commandes utilisées pour créer les projets.
- Les commandes pour ajouter / vérifier les labels.

---

## 2. Garde-fous : LimitRange & ResourceQuota (EX280 cœur)

### 2.1. LimitRange

Dans le projet `ex280-catalog-dev`, crée un **LimitRange** `basic-limits` tel que :

- Pour les **containers** :
  - `defaultRequest.cpu = 50m`
  - `defaultRequest.memory = 64Mi`
  - `default.cpu = 200m`
  - `default.memory = 256Mi`

Exigences :

- Utiliser un fichier YAML `limitrange-basic.yaml`.  
- Appliquer le manifest uniquement avec `oc apply -f`.

### 2.2. ResourceQuota

Dans `ex280-catalog-dev`, crée un **ResourceQuota** `compute-quota` :

- `requests.cpu` max : **400m**
- `requests.memory` max : **512Mi**
- `limits.cpu` max : **800m**
- `limits.memory` max : **1Gi**
- `pods` max : **5**

Exigences :

- Fichier YAML `resourcequota-compute.yaml`.
- Vérifier le tableau `Used` / `Hard` après déploiement de l’app (section 3).

### 2.3. Test de dépassement

Une fois l’app `catalog` déployée (plus loin), tente de créer un pod de test `quota-test` et provoque un **dépassement de quota**:

- Utilise `oc run quota-test --image=registry.access.redhat.com/ubi8/httpd-24 --restart=Never`.
- Observe et note le message d’erreur `exceeded quota`.

Consigne : copie le message exact dans ta feuille de réponses.

---

## 3. Déploiement frontend `catalog-frontend`

### 3.1. Deployment + Service + Route HTTP

Dans `ex280-catalog-dev` :

1. Crée un **Deployment** `catalog-frontend` basé sur l’image :  
   `registry.access.redhat.com/ubi8/httpd-24`  
   Port conteneur : `8080`.

2. Ajoute les labels :
   - `app=catalog-frontend`
   - `tier=frontend`
   - `env=dev`

3. Crée un **Service** `catalog-frontend` (ClusterIP) exposant le port `8080`.

4. Crée une **Route HTTP** `catalog-frontend` permettant l’accès depuis ton navigateur.

Demandé :

- Tester l’accès via `curl` depuis ton poste (ou navigateur) et noter le **code HTTP** (200, 403, etc.).

### 3.2. ConfigMap + Secret

1. Crée une **ConfigMap** `catalog-config` avec les clés :
   - `APP_ENV=dev`
   - `APP_OWNER=zidane`

2. Crée un **Secret** `catalog-secret` avec :
   - `APP_PASSWORD=S3cr3t-Catalog`

3. Injecte ces valeurs dans `catalog-frontend` via variables d’environnement.

4. Vérifie dans le pod (`oc exec`) que `env | grep APP_` montre bien les 3 valeurs.

### 3.3. Probes + resources sur frontend

1. Ajoute sur le Deployment :

   - **Readiness probe** TCP sur port `8080`  
     `initialDelaySeconds=5`, `timeoutSeconds=2`.

   - **Liveness probe** TCP sur port `8080`  
     `initialDelaySeconds=10`, `timeoutSeconds=2`.

2. Ajoute des ressources :

   - `requests.cpu=50m`, `requests.memory=64Mi`
   - `limits.cpu=200m`, `limits.memory=256Mi`

3. Confirme via `oc describe deployment` et `oc describe pod` que ces valeurs sont bien prises en compte.

4. Observe l’impact sur le **ResourceQuota** (`Used` qui augmente).

---

## 4. Stockage persistant + Job/CronJob (batch)

### 4.1. PVC pour les données "catalog"

Dans `ex280-catalog-dev` :

1. Crée un **PersistentVolumeClaim** `pvc-catalog-data` :
   - `storageClassName = crc-csi-hostpath-provisioner`
   - `accessModes = ReadWriteOnce`
   - `requests.storage = 1Gi`

2. Attache ce PVC au Deployment `catalog-frontend` :
   - Nom du volume : `catalog-data`
   - Chemin monté dans le conteneur : `/var/www/html/data`

3. Redéploie si nécessaire et vérifie que le volume est monté.

### 4.2. Test de persistance avec suppression de pod

1. Dans un pod `catalog-frontend` en **Running** :

   - Écris un fichier `test.txt` dans `/var/www/html/data` avec un contenu explicite (ex: `DATA CATALOG PVC`).
   - Vérifie que le fichier existe.

2. Supprime le pod (pas le Deployment) et attends le nouveau pod.

3. Dans le nouveau pod, vérifie que `test.txt` est toujours présent avec le même contenu.


### 4.3. Job batch "cleanup" sur le volume

1. Crée un **Job** `catalog-cleanup` dans `ex280-catalog-dev` qui :

   - Utilise l’image `registry.access.redhat.com/ubi8/httpd-24` ou `ubi8/ubi`.  
   - Monte le même PVC `pvc-catalog-data` sur `/mnt/data`.
   - Exécute une commande qui **liste** le contenu de `/mnt/data` puis **supprime** le fichier `test.txt`.

2. Vérifie :

   - Le Job atteint l’état `Complete`.
   - Le pod du Job montre dans les logs le contenu du répertoire puis la suppression.

3. Confirme que le fichier `test.txt` n’existe plus côté `catalog-frontend`.

### 4.4. CronJob (optionnel, mais recommandé)

Transforme le Job en **CronJob** `catalog-cleanup-cron` qui ferait ce nettoyage toutes les heures.  
Vérifie qu’un premier **Job** est créé à partir du CronJob.

---

## 5. Identité & RBAC (users, groups, Role/RoleBinding, SA)

> Cette partie est à adapter selon ce que tu peux faire sur CRC (htpasswd IdP déjà configuré ou non).  
> Si tu ne peux pas créer de nouveaux users, simule avec ServiceAccounts.

### 5.1. Utilisateur développeur et groupe

1. Crée ou identifie un utilisateur applicatif, par exemple `dev-catalog` (ou utilise `developer`).

2. Crée un **group** `catalog-developers` et ajoute `dev-catalog` dedans.

3. Donne à ce groupe les droits nécessaires sur `ex280-catalog-dev` :
   - Il doit pouvoir **créer/mettre à jour** Deployments, Services, Routes, ConfigMaps, Secrets, Jobs, CronJobs.

   Utilise un **Role** personnalisé `catalog-dev-role` + **RoleBinding**.

4. Vérifie avec `oc auth can-i` (en te connectant en `dev-catalog` ou en simulant) que :
   - `can-i create deployment` dans `ex280-catalog-dev` → **yes**
   - `can-i get nodes` → **no**

### 5.2. ServiceAccount + SCC

1. Crée une **ServiceAccount** `sa-catalog-frontend` dans `ex280-catalog-dev`.

2. Modifie le Deployment `catalog-frontend` pour utiliser cette SA.

3. Assure-toi que la SA dispose des droits nécessaires pour monter le PVC et démarrer le conteneur (SCC par défaut devrait suffire sur CRC).  
   Si ce n’est pas le cas, adapte le Role/RoleBinding ou la SCC de manière **minimale**.

4. Vérifie que le pod est bien en `Running` avec la bonne SA (`oc describe pod ... | grep Service Account`).

---

## 6. NetworkPolicies + labels

### 6.1. Préparation

1. Ajoute les labels suivants sur `catalog-frontend` (Deployment) :
   - `role=web`

2. Crée un **second pod de test** `netpol-tester` dans le même namespace :
   - Image : `registry.access.redhat.com/ubi8/ubi`
   - Commande par défaut interactive (sleep infini) ou similaire.

### 6.2. Politiques réseau

1. Crée une **NetworkPolicy** `deny-all` qui :
   - S’applique à tous les pods du namespace.
   - Interdit tout trafic entrant (ingress).

2. Vérifie que depuis `netpol-tester`, tu ne peux plus joindre `catalog-frontend` sur le port 8080 (curl échoue).

3. Crée une **NetworkPolicy** `allow-web-same-namespace` qui :
   - Laisse le trafic **ingress** vers les pods avec `role=web`.
   - Provenant de pods dans le **même namespace**.

4. Vérifie à nouveau que `netpol-tester` peut joindre `catalog-frontend`.

Consigne :  
Note dans ta feuille les commandes `curl` utilisées et le comportement **avant / après** application des NetPol.

---

## 7. Routes TLS + mise à jour applicative (rollout/rollback)

### 7.1. Route TLS simple

1. Convertis la Route `catalog-frontend` en **HTTPS** (mode edge TLS).  
   Si besoin, laisse OpenShift générer un certificat par défaut.

2. Vérifie l’accès HTTPS depuis ton navigateur ou via `curl -k https://...`.

3. Note l’URL complète de la route TLS.

### 7.2. Mise à jour de l’image + rollback

1. Modifie le Deployment `catalog-frontend` pour utiliser une **autre image** (par exemple une autre version de httpd ou d’UBI, selon ce qui est disponible) ou change une **variable d’environnement visible** dans la page.

2. Observe le **rollout** :
   - `oc rollout status deployment/catalog-frontend`
   - Vérifie que les nouveaux pods sont en `Running`.

3. Simule un problème :
   - Applique une modification cassante (ex : mauvais port, mauvaise image) pour provoquer un échec de déploiement.

4. Utilise `oc rollout undo deployment/catalog-frontend` pour revenir à la révision précédente.

5. Vérifie que :
   - L’ancienne version fonctionne à nouveau.
   - Le statut du rollout est `successfully rolled out`.

---

## 8. Pont EX288 – BuildConfig + ImageStream

### 8.1. Préparation de l’ImageStream

Dans le projet `ex280-catalog-tools` :

1. Crée une **ImageStream** `catalog-frontend`.

2. Vérifie qu’elle est vide au départ (`oc get is`, `oc describe is`).

### 8.2. BuildConfig depuis Git (théorique ou réel)

1. Crée une **BuildConfig** `catalog-frontend-build` qui :
   - Récupère le code depuis un dépôt Git (réel si tu en as un, sinon un dépôt fictif pour l’exercice).  
   - Utilise une stratégie **Source-to-Image (s2i)** avec une image de base HTTPD ou UBI.
   - Pousse l’image construite dans l’ImageStream `catalog-frontend:latest`.

2. Lance un **build** manuel et observe les logs (même si le build échoue pour de vrai, ce qui compte est ta maîtrise des commandes).  

3. (Optionnel) Modifie le Deployment `catalog-frontend` de `ex280-catalog-dev` pour consommer l’image depuis l’ImageStream de `ex280-catalog-tools` (via `image: image-registry.openshift-image-registry.svc:5000/...`).

4. Ajoute un **trigger d’image** sur le Deployment pour automatiser le redeploy lorsque la nouvelle image est poussée.

---

## 9. Checklist finale (auto-évaluation)

À cocher honnêtement après l’examen blanc.

### Projets & organisation

- [ ] Je sais créer/sélectionner un projet avec `oc new-project` / `oc project`.
- [ ] Je sais labelliser un namespace et vérifier les labels.

### App stateless + exposition

- [ ] Je sais créer un Deployment, un Service, une Route en CLI uniquement.
- [ ] Je sais configurer ConfigMap + Secret + env vars.
- [ ] Je sais ajouter probes Readiness/Liveness (HTTP ou TCP).
- [ ] Je sais définir requests/limits et les vérifier.

### Stockage + batch

- [ ] Je sais créer un PVC, l’attacher à un Deployment et tester la persistance.
- [ ] Je sais écrire/supprimer des fichiers dans le volume depuis un pod.
- [ ] Je sais créer un Job et (optionnellement) un CronJob.

### Sécurité & multi-tenancy

- [ ] Je sais créer Role / RoleBinding et utiliser `oc auth can-i`.
- [ ] Je sais travailler avec ServiceAccounts et SCC de base.

### Réseau

- [ ] Je sais écrire une NetPol `deny-all` puis ouvrir le trafic pour un label précis.
- [ ] Je sais diagnostiquer un problème de réseau avec `curl` et les NetPol.
- [ ] Je sais créer une Route TLS simple et la vérifier.

### Updates, rollbacks, build

- [ ] Je sais faire un `oc rollout status`, `oc rollout undo` et comprendre les révisions.
- [ ] Je sais créer une ImageStream + BuildConfig (même théorique) et lancer un build.
- [ ] Je comprends comment relier un Deployment à une ImageStream avec triggers.

---

Fin de l’examen blanc.

Utilise ce document comme **support d’entraînement** :  
- Chronomètre-toi.  
- Garde une feuille de brouillon avec les commandes réellement exécutées.  
- Reviens ensuite avec tes questions / points bloquants pour travailler les zones faibles.

