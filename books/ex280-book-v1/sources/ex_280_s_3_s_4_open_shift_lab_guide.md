# EX280 – Guide Semaine 3 et 4 (mode « cerveau d’admin »)

Ce document complète le guide S1–S2. Il est pensé comme un poly EX280/EX288 :
- **Semaine 3** : updates / rollbacks, ImageStreams, triggers, Kustomize, templates.
- **Semaine 4** : identité, multi‑tenancy (RBAC/quotas) et Helm côté dev.

---

## Semaine 3 – Updates / rollbacks / ImageStreams / Kustomize / Templates

### Objectif S3
Être capable, uniquement en CLI :
- De gérer les **mises à jour** d’une appli (rollout / rollback).
- De connecter un **ImageStream** à un Deployment.
- De configurer des **triggers** (imageChange, configChange).
- D’utiliser **Kustomize** pour séparer dev / stage.
- De déployer depuis un **template OpenShift** (oc process).

> Projet de travail : `ex280-lab02`, appli de base `httpd-demo` (ou équivalent).

---

### 3.1 Brique 1 – Rollout / rollback d’un Deployment

**Concepts**
- `oc rollout` pilote l’historique des déploiements.
- Un `deployment` garde plusieurs révisions (revisions).
- **Rollback** = revenir à la révision précédente (ou une révision donnée).

**Commandes de base**

Lister les déploiements et voir l’historique :
```bash
oc get deploy
oc rollout history deployment/httpd-demo
```

Voir le détail d’une révision précise :
```bash
oc rollout history deployment/httpd-demo --revision=1
```

Déployer une nouvelle version (exemple : changer d’image) :
```bash
oc set image deployment/httpd-demo \
  httpd-24=registry.access.redhat.com/ubi8/httpd-24:1.1

oc rollout status deployment/httpd-demo
```

En cas de problème, revenir à la version précédente :
```bash
oc rollout undo deployment/httpd-demo
# ou vers une révision précise
oc rollout undo deployment/httpd-demo --to-revision=1
```

**À retenir EX280**
- `oc rollout history`, `oc rollout status`, `oc rollout undo`.
- Savoir **faire un rollback rapide** si la nouvelle image casse l’appli.

---

### 3.2 Brique 2 – ImageStreams (pont EX288)

**Concepts**
- Un **ImageStream** suit des images (tags) dans un registre.
- Permet de **décorréler** le nom logique (imagestream:tag) de l’URL de registre.
- Base pour les **triggers** d’update automatique.

**Créer un ImageStream simple**

Import d’une image externe dans un ImageStream :
```bash
oc import-image httpd-ubi \
  --from=registry.access.redhat.com/ubi8/httpd-24 \
  --confirm

oc get is
oc describe is httpd-ubi
```

Tag interne (latest → stable) :
```bash
oc tag httpd-ubi:latest httpd-ubi:stable
oc get istag
```

**Lier un Deployment à un ImageStream**

Modifier le Deployment pour utiliser l’ImageStream local :
```bash
oc set image deployment/httpd-demo \
  httpd-24=image-registry.openshift-image-registry.svc:5000/ex280-lab02/httpd-ubi:stable

oc rollout status deployment/httpd-demo
```

**À retenir EX280/EX288**
- `oc import-image`, `oc tag`.
- ImageStream = abstraction logique + point d’ancrage pour triggers.

---

### 3.3 Brique 3 – Triggers sur Deployment

**Concepts**
- **configChange** : relance un rollout dès qu’on modifie le Deployment.
- **imageChange** : relance un rollout dès qu’un tag d’ImageStream change.

**Voir les triggers actuels**
```bash
oc set triggers deployment/httpd-demo
```

**Activer un trigger imageChange**

Exemple : le container `httpd-24` doit réagir au tag `httpd-ubi:stable` :
```bash
oc set triggers deployment/httpd-demo \
  --from-image=ex280-lab02/httpd-ubi:stable \
  -c httpd-24 \
  --auto

oc set triggers deployment/httpd-demo
```

Tester : re‑tagger l’image (simulateur d’update CI/CD)
```bash
oc tag httpd-ubi:latest httpd-ubi:stable --reference-policy=local
oc get pods
```

Tu dois voir un **nouveau rollout** démarrer automatiquement.

**À retenir EX280**
- `oc set triggers` pour lister / activer / désactiver.
- imageChange + ImageStream = base de l’update automatisé côté EX288.

---

### 3.4 Brique 4 – Kustomize (overlays dev / stage)

**Concepts**
- Kustomize permet d’appliquer des **patches par environnement** sans dupliquer les YAML.
- On définit un `kustomization.yaml` et on applique avec `oc apply -k`.

**Arborescence type**
```text
kustomize/
  base/
    deployment.yaml
    service.yaml
    kustomization.yaml
  overlays/
    dev/
      kustomization.yaml
      patch-resources.yaml
    stage/
      kustomization.yaml
      patch-resources.yaml
```

**Exemple de base/kustomization.yaml**
```yaml
resources:
  - deployment.yaml
  - service.yaml
```

**Exemple d’overlay dev (overlays/dev/kustomization.yaml)**
```yaml
resources:
  - ../../base

patches:
  - patch-resources.yaml
```

**Patch typique** (`patch-resources.yaml`) :
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpd-demo
spec:
  template:
    spec:
      containers:
        - name: httpd-24
          resources:
            requests:
              cpu: 50m
            limits:
              cpu: 200m
```

**Application avec oc**
```bash
# dev
oc apply -k kustomize/overlays/dev

# stage
oc apply -k kustomize/overlays/stage
```

**À retenir EX280/EX288**
- `oc apply -k` (Kustomize intégré).
- base + overlays = séparation propre par environnement (dev, stage…).

---

### 3.5 Brique 5 – Templates OpenShift

**Concepts**
- Un **Template** regroupe plusieurs objets (Service, Route, Deployment…).
- Paramétrable via **parameters**.
- On utilise `oc process` puis `oc apply` ou `oc create`.

**Exemple de template (httpd-template.yaml)**
```yaml
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: httpd-template
objects:
  - apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ${APP_NAME}
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: ${APP_NAME}
      template:
        metadata:
          labels:
            app: ${APP_NAME}
        spec:
          containers:
          - name: httpd-24
            image: registry.access.redhat.com/ubi8/httpd-24
            ports:
            - containerPort: 8080
  - apiVersion: v1
    kind: Service
    metadata:
      name: ${APP_NAME}
    spec:
      selector:
        app: ${APP_NAME}
      ports:
      - port: 8080
        targetPort: 8080
parameters:
  - name: APP_NAME
    description: Nom de l’application
    required: true
```

**Traitement et déploiement**
```bash
# Voir le résultat en YAML
oc process -f httpd-template.yaml -p APP_NAME=httpd-tmpl | less

# Créer les objets directement
oc process -f httpd-template.yaml -p APP_NAME=httpd-tmpl | oc apply -f -

oc get all -l app=httpd-tmpl
```

**À retenir EX280**
- `oc process -f tmpl.yaml -p KEY=VALUE | oc apply -f -`.
- Template = paquet paramétrable réutilisable (base pour EX288 build/deploy).

---

## Semaine 4 – Identité, multi‑tenancy & Helm

### Objectif S4
Être capable, uniquement en CLI :
- De gérer **IdP htpasswd**, utilisateurs et groupes.
- D’assigner des **rôles** (RBAC) à des utilisateurs / groupes.
- De configurer **LimitRange / ResourceQuota / ClusterResourceQuota** par projet.
- De définir un **project template** “clé en main”.
- De manipuler **Helm** (install, upgrade, rollback) côté dev.

---

### 4.1 Brique 6 – IdP htpasswd (vue admin cluster)

> À faire uniquement avec un compte cluster‑admin (`kubeadmin` sur CRC).

**Concepts**
- `htpasswd` = fichier local d’utilisateurs / mots de passe.
- Secret `htpasswd-secret` dans `openshift-config`.
- CR `OAuth/cluster` référence ce secret.

**Étapes type (sur ta machine locale)**

1. Créer le fichier htpasswd :
```bash
htpasswd -c -B -b users.htpasswd zidane 'MotDePasseFort!'
# ajouter d’autres users (sans -c pour ne pas écraser)
htpasswd -B -b users.htpasswd dev1 'Passw0rd!'
```

2. Créer le secret dans `openshift-config` :
```bash
oc create secret generic htpasswd-secret \
  --from-file=htpasswd=users.htpasswd \
  -n openshift-config
```

3. Patcher l’`OAuth` :
```bash
oc edit oauth cluster
```

Exemple d’IdP à ajouter dans `spec.identityProviders` :
```yaml
- name: local-htpasswd
  mappingMethod: claim
  type: HTPasswd
  htpasswd:
    fileData:
      name: htpasswd-secret
```

4. Se reconnecter via la console/CLI avec un user htpasswd.

**À retenir EX280**
- `htpasswd` → secret openshift-config → `oauth/cluster`.
- Savoir retrouver cette conf pour troubleshooting.

---

### 4.2 Brique 7 – Users, groups, RBAC projet

**Concepts**
- Un utilisateur apparaît quand il se connecte, ou via `oc create user` (selon version).
- Un **group** rassemble plusieurs users.
- On assigne des **roles** à un user ou group dans un projet.

**Groups**
```bash
# Créer un groupe\ noc adm groups new dev-team zidane dev1 dev2

# Lister / voir\ noc get groups
oc describe group dev-team
```

**RBAC projet** (ex : donner admin sur `ex280-lab02` au groupe) :
```bash
oc adm policy add-role-to-group admin dev-team -n ex280-lab02

# Vérifier pour un user précis
oc auth can-i create deployment -n ex280-lab02 --as=dev1
```

**Donner un rôle à un user directement**
```bash
oc adm policy add-role-to-user view zidane -n ex280-lab02
oc adm policy add-role-to-user edit dev1 -n ex280-lab02
```

**À retenir EX280**
- `oc adm groups new`, `oc adm policy add-role-to-{user,group}`.
- `oc auth can-i` = réflexe de vérification.

---

### 4.3 Brique 8 – ClusterResourceQuota vs ResourceQuota

**Concepts**
- `ResourceQuota` = quota par **namespace**.
- `ClusterResourceQuota` = quota **trans‑namespaces** (pattern multi‑projets).

**Exemple ResourceQuota (rappel)**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
spec:
  hard:
    requests.cpu: "200m"
    requests.memory: "256Mi"
    limits.cpu: "500m"
    limits.memory: "640Mi"
    pods: "4"
```
```bash
oc apply -f resourcequota-basic.yaml -n ex280-lab02
oc describe resourcequota compute-quota -n ex280-lab02
```

**Exemple ClusterResourceQuota** (nommage type EX280) :
```yaml
apiVersion: quota.openshift.io/v1
kind: ClusterResourceQuota
metadata:
  name: crq-ex280-sandbox
spec:
  quota:
    hard:
      requests.cpu: "2"
      requests.memory: "4Gi"
      limits.cpu: "4"
      limits.memory: "8Gi"
  selector:
    labels:
      matchLabels:
        env: sandbox
```

Appliquer :
```bash
oc apply -f clusterresourcequota-ex280.yaml
oc get clusterresourcequota
oc describe clusterresourcequota crq-ex280-sandbox
```

**À retenir EX280**
- `ClusterResourceQuota` → API `quota.openshift.io/v1`.
- Sélection des namespaces via labels (ex : `env=sandbox`).

---

### 4.4 Brique 9 – Project template

**Concepts**
- OpenShift peut utiliser un **template de projet** pour pré‑créer :
  - quotas, limitranges,
  - rôles de base,
  - ConfigMaps / Secrets standards.

**Étapes type**

1. Créer un template projet :
```yaml
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: project-template-ex280
objects:
  - apiVersion: v1
    kind: ResourceQuota
    metadata:
      name: compute-quota
    spec:
      hard:
        requests.cpu: "200m"
        requests.memory: "256Mi"
        limits.cpu: "500m"
        limits.memory: "640Mi"
        pods: "4"
  - apiVersion: v1
    kind: LimitRange
    metadata:
      name: basic-limits
    spec:
      limits:
      - type: Container
        default:
          cpu: "200m"
          memory: "256Mi"
        defaultRequest:
          cpu: "50m"
          memory: "64Mi"
```

2. Placer le template dans un projet infra (souvent `openshift-config` ou projet dédié) :
```bash
oc apply -f project-template-ex280.yaml -n openshift-config
```

3. Lier ce template au cluster (CR `Project` ou `ProjectRequest` selon version) :
```bash
oc edit project.config.openshift.io/cluster
```

Exemple à ajouter :
```yaml
spec:
  projectRequestTemplate:
    name: project-template-ex280
```

4. Tester la création d’un nouveau projet :
```bash
oc new-project ex280-test-template
oc get resourcequota,limitrange -n ex280-test-template
```

**À retenir EX280**
- Project template = standardisation automatique des nouveaux projets.
- Tout passe par un Template + `project.config.openshift.io/cluster`.

---

### 4.5 Brique 10 – Helm côté dev (pont EX288)

**Concepts**
- Helm = gestionnaire de packages Kubernetes.
- `chart` = paquet (templates + values).
- Cycle de base : install → upgrade → rollback → uninstall.

**Commandes de base**

1. Initialiser / vérifier Helm :
```bash
helm version
```

2. Ajouter un repo public (ex : Bitnami) :
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

3. Chercher un chart :
```bash
helm search repo nginx
```

4. Installer un chart simple :
```bash
helm install my-nginx bitnami/nginx \
  --namespace ex280-lab02 \
  --create-namespace=false

oc get all -n ex280-lab02 -l app.kubernetes.io/instance=my-nginx
```

5. Upgrade (avec override de valeurs) :
```bash
helm upgrade my-nginx bitnami/nginx \
  --namespace ex280-lab02 \
  --set service.type=ClusterIP
```

6. Rollback :
```bash
helm history my-nginx -n ex280-lab02
helm rollback my-nginx 1 -n ex280-lab02
```

7. Uninstall :
```bash
helm uninstall my-nginx -n ex280-lab02
```

**À retenir EX280/EX288**
- `helm install / upgrade / rollback / uninstall`.
- Label `app.kubernetes.io/instance` pour filtrer les ressources d’un release.

---

## Synthèse Semaine 3–4 (checklist mentale)

- **Rollout / rollback** :
  - `oc set image`, `oc rollout status`, `oc rollout history`, `oc rollout undo`.
- **ImageStreams / triggers** :
  - `oc import-image`, `oc tag`, `oc set triggers`.
- **Kustomize** :
  - `oc apply -k base/` ou `overlays/dev`.
- **Templates** :
  - `oc process -f tmpl.yaml -p KEY=VALUE | oc apply -f -`.
- **IdP htpasswd** :
  - fichier `htpasswd` → secret `htpasswd-secret` → `oauth/cluster`.
- **Groups + RBAC** :
  - `oc adm groups new`, `oc adm policy add-role-to-{user,group}`, `oc auth can-i`.
- **Quotas** :
  - `ResourceQuota` (par namespace) vs `ClusterResourceQuota` (multi‑projets).
- **Project template** :
  - Template + `project.config.openshift.io/cluster`.
- **Helm** :
  - `helm install / upgrade / rollback / uninstall`, repo + values.


