# Semaine 3 - Updates / rollbacks / ImageStreams / Kustomize / Templates

### Objectif S3
Être capable, uniquement en CLI :
- De gérer les **mises à jour** d’une appli (rollout / rollback).
- De connecter un **ImageStream** à un Deployment.
- De configurer des **triggers** (imageChange, configChange).
- D’utiliser **Kustomize** pour séparer dev / stage.
- De déployer depuis un **template OpenShift** (oc process).

> Projet de travail : `ex280-lab02`, appli de base `httpd-demo` (ou équivalent).

---

### 3.1 Brique 1 - Rollout / rollback d’un Deployment

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

### 3.2 Brique 2 - ImageStreams (pont EX288)

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

### 3.3 Brique 3 - Triggers sur Deployment

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

### 3.4 Brique 4 - Kustomize (overlays dev / stage)

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

### 3.5 Brique 5 - Templates OpenShift

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





