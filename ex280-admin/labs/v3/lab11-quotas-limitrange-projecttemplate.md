# Lab 11 — Self-service dev: ResourceQuotas, LimitRanges, project templates, requests/limits


## Objectifs EX280 couverts
- Configurer quotas cluster/projet
- Configurer requirements (requests/limits)
- Configurer LimitRanges
- Configurer project templates

## Prérequis
- Certains items demandent des droits admin (cluster-level).
```bash
export LAB=11
export NS=ex280-lab${LAB}-zidane
oc new-project "$NS"
```

## Partie A — Quotas & LimitRanges (namespace)
### 1) Créer une ResourceQuota
```bash
cat <<'YAML' | oc apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: rq-small
spec:
  hard:
    pods: "5"
    requests.cpu: "500m"
    requests.memory: 512Mi
    limits.cpu: "1"
    limits.memory: 1Gi
YAML
oc describe quota rq-small
```

### 2) Créer un LimitRange (defaults)
```bash
cat <<'YAML' | oc apply -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: lr-defaults
spec:
  limits:
  - type: Container
    default:
      cpu: "200m"
      memory: "256Mi"
    defaultRequest:
      cpu: "50m"
      memory: "64Mi"
    max:
      cpu: "500m"
      memory: "512Mi"
YAML
oc describe limitrange lr-defaults
```

### 3) Vérifier l’effet des defaults
Déployer un pod sans ressources explicites :
```bash
oc run lr-test --image=registry.access.redhat.com/ubi9/ubi-minimal --restart=Never -- sleep 3600
oc wait --for=condition=Ready pod/lr-test --timeout=120s
oc get pod lr-test -o jsonpath='{.spec.containers[0].resources}{"
"}'
```
Attendu : `requests/limits` injectés par défaut.

### 4) Provoquer un dépassement quota (pédagogique)
Tenter de créer trop de pods :
```bash
for i in $(seq 1 10); do oc run p$i --image=registry.access.redhat.com/ubi9/ubi-minimal --restart=Never -- sleep 3600 || true; done
oc get pods
oc describe quota rq-small | sed -n '1,160p'
```

## Partie B — Project Template (cluster)
> Selon les droits et ton cluster, cette partie peut être “lecture + simulation”. En examen, tu as souvent la permission de configurer des aspects cluster.

### 5) Créer un template de demande de projet
Créer un template (ex: dans `openshift-config` ou un namespace dédié à la config).
Exemple minimal :
```yaml
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: project-request
parameters:
- name: PROJECT_NAME
  required: true
objects:
- apiVersion: project.openshift.io/v1
  kind: Project
  metadata:
    name: ${PROJECT_NAME}
    annotations:
      openshift.io/display-name: "${PROJECT_NAME}"
      openshift.io/description: "Projet créé via template EX280"
- apiVersion: v1
  kind: LimitRange
  metadata:
    name: lr-defaults
    namespace: ${PROJECT_NAME}
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
Objectif : qu’un nouveau projet hérite automatiquement de contraintes (ex: LimitRange).

### 6) Associer le template au cluster
On configure l’objet `Project` de config :
- Ressource: `project.config.openshift.io/cluster`
- Champ: `spec.projectRequestTemplate.name`
- Template référencé par `namespace/name` selon implémentation du cluster.

## Vérifications
- `oc describe quota` montre l’usage et les limites.
- `lr-test` contient des defaults de ressources.
- Les créations au-delà de quota échouent avec message explicite.

## Nettoyage
```bash
oc delete project "$NS"
```
