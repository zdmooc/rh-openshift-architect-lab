# Lab01 — Projects & Access

## Objectif

- Créer et lister des projets.
- Manipuler le contexte `oc` (cluster / user / namespace).
- Lancer un pod de test dans le bon projet.

## Pré-requis

- Lab00 OK (CRC + login kubeadmin).

---

## Steps

### Step 1 — Créer les projets de labo

    oc get project ex280-lab01-main-zidane  || oc new-project ex280-lab01-main-zidane
    oc get project ex280-lab01-extra-zidane || oc new-project ex280-lab01-extra-zidane

    oc get projects | grep ex280-lab01 || echo "Aucun projet ex280-lab01"

### Step 2 — Contexte / projet courant

    oc project ex280-lab01-main-zidane
    oc project
    oc config get-contexts

### Step 3 — Vue rapide du cluster

    oc whoami
    oc get nodes -o wide
    oc get pods -A | head -20
    oc get events -A --sort-by=.lastTimestamp | head -20

### Step 4 — Pod de test

    oc run lab01-test --image=registry.access.redhat.com/ubi8/ubi-minimal \
      --restart=Never --command -- sleep 300

    oc get pods -o wide
    oc describe pod lab01-test

---

## Vérifications

    oc project
    oc get projects | grep ex280-lab01 || echo "Aucun projet ex280-lab01"
    oc get pods -o wide

Critères :
- Projet courant = `ex280-lab01-main-zidane`
- Projets `ex280-lab01-main-zidane` et `ex280-lab01-extra-zidane` existent
- Pod `lab01-test` en `Running` ou `Completed`

---

## Cleanup (optionnel)

    oc delete pod lab01-test --ignore-not-found -n ex280-lab01-main-zidane
    oc delete project ex280-lab01-main-zidane  --ignore-not-found
    oc delete project ex280-lab01-extra-zidane --ignore-not-found

---

## Pièges fréquents

- Mauvais namespace → vérifier `oc project`
- Ressource introuvable → `oc get pods -A | grep lab01-test`
