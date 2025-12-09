# Lab00 — Env & Repos (Bootstrap CRC + oc + Git)

## Objectif
Point de départ propre :
- CRC (OpenShift Local 4.19.3) démarré.
- `oc` connecté en `kubeadmin`.
- Repo `rh-openshift-architect-lab` accessible.
- Projet de test + pod de test OK.

## Pré-requis
- Windows 11, Git Bash.
- CRC 4.19.3 installé.
- Repo cloné sous `C:\workspaces\openshift2026`.

## Steps

### Step 1 — Vérifier / démarrer CRC
    crc status
    # Si OpenShift n'est pas "Running" :
    crc start
    crc status

### Step 2 — Login `oc` en kubeadmin
    crc console --credentials
    oc login -u kubeadmin -p '<KUBEADMIN_PWD>' https://api.crc.testing:6443

### Step 3 — Vérifier le cluster
    oc whoami
    oc whoami --show-context
    oc get nodes -o wide
    oc get co

### Step 4 — Vérifier le workspace Git
    cd /c/workspaces/openshift2026
    ls
    cd rh-openshift-architect-lab
    pwd
    git status
    ls ex280-admin
    ls books/ex280-book-v1

### Step 5 — Créer projet de test + pod
    oc get project ex280-lab00-bootstrap-zidane || oc new-project ex280-lab00-bootstrap-zidane
    oc project ex280-lab00-bootstrap-zidane
    oc delete pod lab00-test --ignore-not-found
    oc run lab00-test --image=registry.access.redhat.com/ubi8/ubi-minimal \
      --restart=Never --command -- sleep 300
    oc get pods -o wide

## Vérifications
    oc whoami
    oc get co
    oc get nodes -o wide
    oc project
    oc get pods -o wide

Critères :
- `oc whoami` = `kubeadmin`
- Tous les `ClusterOperator` OK
- Projet courant = `ex280-lab00-bootstrap-zidane`
- Pod `lab00-test` en `Running` ou `Completed`

## Cleanup (optionnel)
    oc delete pod lab00-test --ignore-not-found
    oc delete project ex280-lab00-bootstrap-zidane --ignore-not-found

## Pièges fréquents
- CRC arrêté → `crc start`
- Mauvaise URL/pass sur `oc login` → `crc console --credentials`
- Pod en erreur → `oc describe pod ...`, `oc get events --sort-by=.lastTimestamp | head -20`
