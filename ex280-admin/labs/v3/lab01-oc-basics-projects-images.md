# Lab 01 — Bases OpenShift: projets, requêtes, images (tags/digests), import/export


## Objectifs EX280 couverts
- Créer/supprimer des projets
- Requêter / filtrer / formater des ressources Kubernetes
- Importer / exporter / configurer des ressources
- Localiser et examiner des images (tags vs digests)

## Prérequis
- `oc` connecté en utilisateur ayant le droit de créer un projet.
- Variables utiles :
```bash
export LAB=01
export NS=ex280-lab${LAB}-zidane
```

## Tâches
### 1) Créer un projet et vérifier le contexte
```bash
oc new-project "$NS"
oc project
oc get project "$NS" -o yaml | head
```

### 2) Déployer un pod minimal (test) et inspecter
```bash
oc run lab${LAB}-pod --image=registry.access.redhat.com/ubi9/ubi-minimal --restart=Never -- sleep 3600
oc get pod -o wide
oc describe pod lab${LAB}-pod | sed -n '1,120p'
```

### 3) Requêtes et formats (jsonpath / custom-columns / tri)
- Récupérer le nom + phase + node du pod :
```bash
oc get pod lab${LAB}-pod -o jsonpath='{.metadata.name}{"  "}{.status.phase}{"  "}{.spec.nodeName}{"
"}'
```
- Lister tous les pods avec colonnes custom :
```bash
oc get pods -o custom-columns=NAME:.metadata.name,PHASE:.status.phase,NODE:.spec.nodeName,IMAGE:.spec.containers[0].image
```
- Trier par date de création (tous pods) :
```bash
oc get pods --sort-by=.metadata.creationTimestamp
```

### 4) Images: tags vs digests
- Créer une ImageStream locale (dans ton projet) et importer une image par tag :
```bash
oc create imagestream hello
oc import-image hello:latest --from=quay.io/libpod/hello --confirm
oc get is hello -o yaml | sed -n '1,120p'
```
- Identifier le digest de l’image importée :
```bash
oc get is hello -o jsonpath='{.status.tags[0].items[0].image}{"
"}'
```
- Déployer ensuite en **digest** (immuable) :
```bash
DIGEST=$(oc get is hello -o jsonpath='{.status.tags[0].items[0].image}')
oc new-app --name=hello-digest "$DIGEST"
oc rollout status deploy/hello-digest
oc get deploy/hello-digest -o jsonpath='{.spec.template.spec.containers[0].image}{"
"}'
```

### 5) Export / import d’une ressource (YAML)
- Exporter le Deployment pour le reconstituer plus tard :
```bash
oc get deploy hello-digest -o yaml > /tmp/hello-digest-deploy.yaml
```
- Supprimer puis ré-appliquer :
```bash
oc delete deploy hello-digest
oc apply -f /tmp/hello-digest-deploy.yaml
oc rollout status deploy/hello-digest
```

## Vérifications (attendus)
- `oc get project $NS` retourne OK.
- `hello-digest` est déployé et stable.
- Le champ `.spec.template.spec.containers[0].image` contient un digest (`@sha256:`).

## Nettoyage
```bash
oc delete project "$NS"
```
