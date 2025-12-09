# Lab10 — Templates

## Objectif
- Créer un Template avec Deployment, Service, Route.
- L’instancier avec des paramètres.

## Pré-requis
- kubeadmin.

## Steps

### Step 1 — Projet
    oc get project ex280-lab10-template-zidane || oc new-project ex280-lab10-template-zidane
    oc project ex280-lab10-template-zidane

### Step 2 — Template
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

### Step 3 — Instanciation
    oc process simple-web-template -p APP_NAME=tpl-web | oc apply -f -
    oc get all
    oc get route

## Vérifications
    oc get deployment tpl-web
    oc get svc tpl-web
    oc get route tpl-web

## Cleanup (optionnel)
    oc delete project ex280-lab10-template-zidane --ignore-not-found
