# Lab12 — Operators & OLM

## Objectif
- Parcourir les Operators disponibles.
- Installer un Operator dans un namespace.

## Pré-requis
- kubeadmin.

## Steps

### Step 1 — Projet
    oc get project ex280-lab12-operator-zidane || oc new-project ex280-lab12-operator-zidane
    oc project ex280-lab12-operator-zidane

### Step 2 — Lister les Operators disponibles
    oc get packagemanifests -n openshift-marketplace | head

### Step 3 — (Exemple) choisir un Operator léger
    # Noter le nom d'un packagemanifest (ex: etcd, amq, ... selon ce que CRC propose)
    # Puis créer OperatorGroup + Subscription si besoin.

## Vérifications
    oc get csv -n ex280-lab12-operator-zidane || true

## Cleanup (optionnel)
    oc delete project ex280-lab12-operator-zidane --ignore-not-found
