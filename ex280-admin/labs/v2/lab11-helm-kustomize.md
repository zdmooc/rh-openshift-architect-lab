# Lab11 — Helm & Kustomize

## Objectif

- Installer une release Helm simple.
- Appliquer un overlay Kustomize.
- Vérifier les objets créés.

## Pré-requis

- `helm` et `kustomize` dans le PATH.
- kubeadmin.

---

## Steps

### Step 1 — Projet

    oc get project ex280-lab11-packaging-zidane || oc new-project ex280-lab11-packaging-zidane
    oc project ex280-lab11-packaging-zidane

### Step 2 — Helm (nginx bitnami)

    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update

    helm install my-nginx bitnami/nginx -n ex280-lab11-packaging-zidane
    oc get pods -n ex280-lab11-packaging-zidane

### Step 3 — Kustomize (deployment simple)

    mkdir -p /c/workspaces/openshift2026/kustomize-lab11/base
    cd /c/workspaces/openshift2026/kustomize-lab11/base

    cat > deployment.yaml << 'YAML'
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: kustom-web
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: kustom-web
      template:
        metadata:
          labels:
            app: kustom-web
        spec:
          containers:
          - name: kustom-web
            image: registry.access.redhat.com/ubi8/httpd-24
    YAML

    cat > kustomization.yaml << 'YAML'
    resources:
    - deployment.yaml
    YAML

    kustomize build . | oc apply -f - -n ex280-lab11-packaging-zidane

    oc get all -n ex280-lab11-packaging-zidane

---

## Vérifications

    oc get deployments -n ex280-lab11-packaging-zidane
    oc get pods -n ex280-lab11-packaging-zidane

Critères :

- Release Helm `my-nginx` présente.
- Deployment `kustom-web` présent.

---

## Cleanup (optionnel)

    helm uninstall my-nginx -n ex280-lab11-packaging-zidane || true
    oc delete project ex280-lab11-packaging-zidane --ignore-not-found
