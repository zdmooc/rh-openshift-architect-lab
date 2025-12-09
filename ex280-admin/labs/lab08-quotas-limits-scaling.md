# Lab08 — Quotas, Limits, Scaling & Autoscale

## Objectif

- Créer un ResourceQuota et un LimitRange.
- Vérifier leur impact sur les pods.
- Scaler un Deployment.
- Configurer un HorizontalPodAutoscaler (HPA).

## Pré-requis

- kubeadmin.
- Labs 00→03 OK.

---

## Steps

### Step 1 — Projet

    oc get project ex280-lab08-quota-zidane || oc new-project ex280-lab08-quota-zidane
    oc project ex280-lab08-quota-zidane

### Step 2 — ResourceQuota + LimitRange

    cat << 'YAML' | oc apply -f -
    apiVersion: v1
    kind: ResourceQuota
    metadata:
      name: rq-small
    spec:
      hard:
        requests.cpu: "1"
        requests.memory: 1Gi
        limits.cpu: "2"
        limits.memory: 2Gi
    ---
    apiVersion: v1
    kind: LimitRange
    metadata:
      name: lr-small
    spec:
      limits:
      - type: Container
        default:
          cpu: "200m"
          memory: 256Mi
        defaultRequest:
          cpu: "100m"
          memory: 128Mi
    YAML

    oc get resourcequota
    oc describe resourcequota rq-small
    oc get limitrange
    oc describe limitrange lr-small

### Step 3 — Deployment + scaling manuel

    oc create deployment quota-web --image=registry.access.redhat.com/ubi8/httpd-24
    oc get pods

    # Scaling manuel
    oc scale deployment quota-web --replicas=3
    oc get pods
    oc describe deployment quota-web

### Step 4 — Autoscale (HPA)

    # Créer un HPA basé sur l'utilisation CPU
    oc autoscale deployment quota-web \
      --min=1 --max=5 --cpu-percent=50

    oc get hpa
    oc describe hpa quota-web

    # (Optionnel) générer un peu de charge plus tard pour voir bouger les replicas

---

## Vérifications (fin de lab)

    oc get resourcequota
    oc describe resourcequota rq-small

    oc get limitrange
    oc describe limitrange lr-small

    oc get deployment quota-web
    oc get pods

    oc get hpa
    oc describe hpa quota-web

Critères de réussite :

- `ResourceQuota` `rq-small` présent, limites cohérentes.
- `LimitRange` `lr-small` appliqué sur le namespace.
- Deployment `quota-web` avec plusieurs replicas après scaling manuel.
- HPA `quota-web` présent, avec `minReplicas` / `maxReplicas` corrects et une cible CPU.

---

## Cleanup (optionnel)

    oc delete project ex280-lab08-quota-zidane --ignore-not-found

---

## Pièges fréquents + diagnostic rapide

- Pods en `Pending` après scale :
  - `oc describe pod <nom>` pour voir si le quota est dépassé.
  - `oc describe resourcequota rq-small` pour voir les usages.
- HPA non créé :
  - Vérifier que les metrics-server/monitoring sont disponibles.
  - Vérifier la syntaxe de `oc autoscale`.
