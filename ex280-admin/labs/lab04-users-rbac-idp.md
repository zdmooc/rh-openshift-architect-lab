# Lab04 — Users, Groups & RBAC

## Objectif
- Créer un group.
- Assigner un rôle à ce group sur un projet.
- Vérifier les bindings.

## Pré-requis
- kubeadmin (cluster-admin).
- IdP déjà configuré ou users fictifs (noms de login).

## Steps

### Step 1 — Projet
    oc get project ex280-lab04-rbac-zidane || oc new-project ex280-lab04-rbac-zidane
    oc project ex280-lab04-rbac-zidane

### Step 2 — Créer un group
    oc adm groups new ex280-devs zidane-dev1 zidane-dev2 || true
    oc get groups

### Step 3 — RBAC sur le projet
    oc policy add-role-to-group edit ex280-devs -n ex280-lab04-rbac-zidane
    oc get rolebindings -n ex280-lab04-rbac-zidane

## Vérifications
    oc get groups
    oc describe rolebinding -n ex280-lab04-rbac-zidane

Critères :
- Group `ex280-devs` existe
- RoleBinding présent pour `ex280-devs` avec rôle `edit`

## Cleanup (optionnel)
    oc delete project ex280-lab04-rbac-zidane --ignore-not-found

## Pièges fréquents
- Rôle appliqué au mauvais namespace → `oc get rolebindings -A | grep ex280-devs`
