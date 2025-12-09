# Lab 10 — Sécurité applicative: SCC, exécution privilégiée, SA + SCC binding


## Objectifs EX280 couverts
- Exécuter des applis privilégiées
- Gérer/appliquer des permissions via Security Context Constraints (SCC)
- Gérer des service accounts

## Prérequis
- Cluster OpenShift (SCC actifs). Droits admin recommandés.
```bash
export LAB=10
export NS=ex280-lab${LAB}-zidane
oc new-project "$NS"
```

## Scénario
- Déployer un pod qui nécessite des privilèges (ex: `privileged`, ou `anyuid` selon le besoin).
- Lier une SCC à une ServiceAccount dédiée.
- Vérifier que sans SCC le pod échoue, puis qu’il démarre après binding.

## Tâches
### 1) Créer une ServiceAccount dédiée
```bash
oc create sa privileged-sa
```

### 2) Créer un pod qui demande `privileged: true` (va échouer sans droits)
```bash
cat <<'YAML' | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: privileged-test
spec:
  serviceAccountName: privileged-sa
  containers:
  - name: privileged-test
    image: registry.access.redhat.com/ubi9/ubi-minimal
    securityContext:
      privileged: true
    command: ["/bin/sh","-c"]
    args:
      - |
        echo "Running privileged test"
        id
        sleep 3600
YAML
oc get pod privileged-test -w
```
Si `CrashLoopBackOff` / `CreateContainerConfigError`, inspecte :
```bash
oc describe pod privileged-test | sed -n '1,220p'
oc get events --sort-by=.metadata.creationTimestamp | tail -n 30
```

### 3) Appliquer SCC “privileged” à la SA
```bash
oc adm policy add-scc-to-user privileged -z privileged-sa -n "$NS"
oc get pod privileged-test -w
```

### 4) Vérifier le démarrage et l’identité
```bash
oc exec privileged-test -- id
```

## Vérifications
- Avant binding SCC : pod ne démarre pas (erreur SCC).
- Après binding SCC : pod `Running`.

## Nettoyage
```bash
oc delete project "$NS"
```
