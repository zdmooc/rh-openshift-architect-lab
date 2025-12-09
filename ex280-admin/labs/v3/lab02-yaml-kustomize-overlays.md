# Lab 02 — Gestion déclarative: YAML, apply/patch, rollout, Kustomize + overlays


## Objectifs EX280 couverts
- Déployer depuis des manifests YAML
- Mettre à jour des déploiements
- Déployer avec Kustomize + overlays
- Import/export de ressources

## Prérequis
```bash
export LAB=02
export NS=ex280-lab${LAB}-zidane
oc new-project "$NS"
```

## Partie A — Déploiement 100% YAML
### 1) Créer un Deployment + Service (fichier local)
Crée un fichier `deployment.yaml` (dans ton poste) avec le contenu suivant :
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: registry.access.redhat.com/ubi9/httpd-24
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: "50m"
            memory: "64Mi"
          limits:
            cpu: "250m"
            memory: "256Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
  - name: http
    port: 8080
    targetPort: 8080
```
Appliquer :
```bash
oc apply -f deployment.yaml
oc rollout status deploy/web
oc get pods -l app=web -o wide
oc get svc web -o yaml | sed -n '1,120p'
```

### 2) Update contrôlé: patch + rollout + rollback
- Patch de `replicas` à 3 :
```bash
oc patch deploy/web -p '{"spec":{"replicas":3}}'
oc rollout status deploy/web
oc get rs -l app=web
```
- Introduire volontairement une mauvaise image puis rollback :
```bash
oc set image deploy/web web=registry.access.redhat.com/ubi9/httpd-24:does-not-exist
oc rollout status deploy/web || true
oc rollout history deploy/web
oc rollout undo deploy/web
oc rollout status deploy/web
```

## Partie B — Kustomize (base + overlays)
> Ici on pratique **`oc apply -k`** et les overlays, objectif explicitement listé EX280.

### 3) Base Kustomize
Arborescence suggérée :
```
kustomize/
  base/
    kustomization.yaml
    deploy.yaml
    svc.yaml
  overlays/
    dev/
      kustomization.yaml
    prod/
      kustomization.yaml
```

**base/deploy.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: quay.io/libpod/hello
        args: ["-l"]
        ports:
        - containerPort: 8080
```

**base/svc.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api
spec:
  selector:
    app: api
  ports:
  - name: http
    port: 8080
    targetPort: 8080
```

**base/kustomization.yaml**
```yaml
resources:
  - deploy.yaml
  - svc.yaml
```

Appliquer la base :
```bash
oc apply -k kustomize/base
oc rollout status deploy/api
```

### 4) Overlay DEV: replicas + namePrefix
**overlays/dev/kustomization.yaml**
```yaml
resources:
  - ../../base
namePrefix: dev-
patches:
  - target:
      kind: Deployment
      name: api
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 1
```
Appliquer :
```bash
oc apply -k kustomize/overlays/dev
oc get deploy | egrep 'dev-api|api'
```

### 5) Overlay PROD: plus de réplicas + ressources
**overlays/prod/kustomization.yaml**
```yaml
resources:
  - ../../base
namePrefix: prod-
patches:
  - target:
      kind: Deployment
      name: api
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 3
      - op: add
        path: /spec/template/spec/containers/0/resources
        value:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
```
Appliquer :
```bash
oc apply -k kustomize/overlays/prod
oc rollout status deploy/prod-api
oc get deploy prod-api -o jsonpath='{.spec.replicas}{"
"}'
```

## Vérifications
- `oc get deploy` montre `web`, `dev-api`, `prod-api`.
- Les overlays changent bien `replicas` et le préfixe de nom.

## Nettoyage
```bash
oc delete project "$NS"
```
