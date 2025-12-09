# Lab05 — ServiceAccounts, Secrets & SCC

## Objectif
- Créer une ServiceAccount.
- Lier un Secret à la SA.
- Appliquer une SCC spécifique.

## Pré-requis
- kubeadmin.

## Steps

### Step 1 — Projet
    oc get project ex280-lab05-sec-zidane || oc new-project ex280-lab05-sec-zidane
    oc project ex280-lab05-sec-zidane

### Step 2 — SA + Secret
    oc create serviceaccount app-sa
    oc create secret generic app-sa-secret --from-literal=TOKEN="topsecret"
    oc patch serviceaccount app-sa -p '{"secrets":[{"name":"app-sa-secret"}]}'

### Step 3 — Associer une SCC (ex: `nonroot`)
    oc get scc
    oc adm policy add-scc-to-user nonroot -z app-sa -n ex280-lab05-sec-zidane

### Step 4 — Pod utilisant la SA
    cat << 'YAML' | oc apply -f -
    apiVersion: v1
    kind: Pod
    metadata:
      name: sa-pod
    spec:
      serviceAccountName: app-sa
      containers:
      - name: main
        image: registry.access.redhat.com/ubi8/ubi-minimal
        command: ["sleep","300"]
    YAML

## Vérifications
    oc describe sa app-sa
    oc describe pod sa-pod

Critères :
- SA liée au secret
- Pod `sa-pod` en `Running`
- SCC correcte dans l’annotation `openshift.io/scc`

## Cleanup (optionnel)
    oc delete project ex280-lab05-sec-zidane --ignore-not-found

## Pièges fréquents
- SA sans SCC adaptée → erreurs de permission dans `oc describe pod sa-pod`
