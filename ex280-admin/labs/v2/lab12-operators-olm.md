# Lab12 — Operators & OLM

## Objectif

- Lister les Operators disponibles (CatalogSources).
- Créer un OperatorGroup.
- Créer une Subscription pour un Operator choisi.
- Vérifier le CSV (ClusterServiceVersion).

## Pré-requis

- kubeadmin.
- Cluster avec OLM actif (cas standard OpenShift).

---

## Steps

### Step 1 — Projet

    oc get project ex280-lab12-operator-zidane || oc new-project ex280-lab12-operator-zidane
    oc project ex280-lab12-operator-zidane

### Step 2 — Lister les Operators disponibles

    oc get packagemanifests -n openshift-marketplace | head

    # (Option) filtrer :
    oc get packagemanifests -n openshift-marketplace | grep -i etcd || true

### Step 3 — Choisir un Operator

1. Noter :
   - `PACKAGE_NAME` (ex: `etcd`)
   - `CHANNEL` (ex: `stable`)
   - `CATALOG_SOURCE` (ex: `redhat-operators`)

2. Ensuite, créer les objets suivants en adaptant ces valeurs.

### Step 4 — OperatorGroup

    cat << 'YAML' | oc apply -f -
    apiVersion: operators.coreos.com/v1
    kind: OperatorGroup
    metadata:
      name: ex280-operatorgroup
      namespace: ex280-lab12-operator-zidane
    spec:
      targetNamespaces:
      - ex280-lab12-operator-zidane
    YAML

    oc get operatorgroup -n ex280-lab12-operator-zidane
    oc describe operatorgroup ex280-operatorgroup -n ex280-lab12-operator-zidane

### Step 5 — Subscription

Adapter `name`, `channel`, `source` :

    cat << 'YAML' | oc apply -f -
    apiVersion: operators.coreos.com/v1alpha1
    kind: Subscription
    metadata:
      name: ex280-operator-sub
      namespace: ex280-lab12-operator-zidane
    spec:
      channel: "<CHANNEL>"
      name: "<PACKAGE_NAME>"
      source: "<CATALOG_SOURCE>"
      sourceNamespace: "openshift-marketplace"
    YAML

    oc get subscription -n ex280-lab12-operator-zidane
    oc describe subscription ex280-operator-sub -n ex280-lab12-operator-zidane

---

## Vérifications

    oc get csv -n ex280-lab12-operator-zidane
    oc get pods -n ex280-lab12-operator-zidane

Critères :

- Un CSV (ClusterServiceVersion) apparaît avec un STATUS `Succeeded`.
- Pods de l’Operator déployés dans le namespace.

---

## Cleanup (optionnel)

    oc delete project ex280-lab12-operator-zidane --ignore-not-found
    # Laisser OLM global en place (pas de suppression au niveau cluster).

---

## Pièges fréquents

- Mauvais `CHANNEL` / `PACKAGE_NAME` → vérifier dans `packagemanifests`.
- OperatorGroup absent → CSV ne sera pas créé.
