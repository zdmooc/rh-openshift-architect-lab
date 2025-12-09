# Lab10 — Templates & (option) Project Request Template

## Objectif

- Créer un Template applicatif (Deployment + Service + Route).
- L’instancier avec des paramètres.
- (Option CRC) Créer un Template de projet par défaut pour le self-service.

## Pré-requis

- kubeadmin.

---

## Partie A — Template applicatif

### Step A1 — Projet

    oc get project ex280-lab10-template-zidane || oc new-project ex280-lab10-template-zidane
    oc project ex280-lab10-template-zidane

### Step A2 — Template

    cat << 'YAML' | oc apply -f -
    apiVersion: template.openshift.io/v1
    kind: Template
    metadata:
      name: simple-web-template
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
            - name: ${APP_NAME}
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
    - apiVersion: route.openshift.io/v1
      kind: Route
      metadata:
        name: ${APP_NAME}
      spec:
        to:
          kind: Service
          name: ${APP_NAME}
    parameters:
    - name: APP_NAME
      required: true
    YAML

    oc get template

### Step A3 — Instanciation

    oc process simple-web-template -p APP_NAME=tpl-web | oc apply -f -
    oc get all
    oc get route

    ROUTE_URL="http://$(oc get route tpl-web -o jsonpath='{.spec.host}')"
    curl -k "$ROUTE_URL" || true

---

## Partie B — (Option CRC) Project Request Template avec LimitRange

> Modifie la config globale de création de projet. Pour CRC uniquement.

### Step B1 — Créer Template de projet dans `openshift-config`

    oc project openshift-config

    cat << 'YAML' | oc apply -f -
    apiVersion: template.openshift.io/v1
    kind: Template
    metadata:
      name: ex280-project-request-template
      namespace: openshift-config
    objects:
    - apiVersion: v1
      kind: LimitRange
      metadata:
        name: default-limits
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

    oc get template -n openshift-config ex280-project-request-template

### Step B2 — Sauvegarder / patcher `project.config.openshift.io/cluster`

    oc get project.config.openshift.io cluster -o yaml > /c/workspaces/openshift2026/auth/project-config-backup.yaml

    oc patch project.config.openshift.io/cluster --type=merge -p '{
      "spec": {
        "projectRequestTemplate": {
          "name": "ex280-project-request-template"
        }
      }
    }'

    oc get project.config.openshift.io cluster -o yaml | grep -A3 projectRequestTemplate

### Step B3 — Tester la création de projet

    oc new-project ex280-lab10-selfservice-zidane
    oc describe limitrange default-limits -n ex280-lab10-selfservice-zidane || echo "LimitRange non trouvé"

---

## Vérifications

- Partie A :
  - `oc get deployment tpl-web`
  - `oc get svc tpl-web`
  - `oc get route tpl-web`

- Partie B (option) :
  - `projectRequestTemplate.name = ex280-project-request-template` dans `project.config.openshift.io/cluster`.
  - Nouveau projet avec LimitRange `default-limits`.

---

## Cleanup (optionnel)

    oc delete project ex280-lab10-template-zidane --ignore-not-found
    oc delete project ex280-lab10-selfservice-zidane --ignore-not-found
    # Pour remettre la config projet d’origine :
    # oc replace -f /c/workspaces/openshift2026/auth/project-config-backup.yaml

---

## Pièges fréquents

- Template sans paramètres → `oc process` impossible à personnaliser.
- `projectRequestTemplate` sans namespace → doit être dans `openshift-config`.
