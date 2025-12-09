# Lab 13 — Jobs & CronJobs: one-shot tasks, scheduling, secrets, history, troubleshooting


## Objectifs EX280 couverts
- Déployer des jobs (one-time tasks)
- Configurer des cron jobs Kubernetes
- Utiliser des secrets dans un job

## Prérequis
```bash
export LAB=13
export NS=ex280-lab${LAB}-zidane
oc new-project "$NS"
```

## Tâches
### 1) Secret consommé par un Job
```bash
oc create secret generic job-secret --from-literal=TARGET_URL=https://example.org
```

Créer un Job qui lit le secret et exécute une commande :
```bash
cat <<'YAML' | oc apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: fetch-once
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: fetch
        image: registry.access.redhat.com/ubi9/ubi-minimal
        command: ["/bin/sh","-c"]
        args:
          - |
            echo "URL=$TARGET_URL"
            echo "Done"
        env:
        - name: TARGET_URL
          valueFrom:
            secretKeyRef:
              name: job-secret
              key: TARGET_URL
YAML
```

Suivre l’exécution :
```bash
oc get job fetch-once -w
oc logs -l job-name=fetch-once
oc describe job fetch-once | sed -n '1,220p'
```

### 2) CronJob: toutes les minutes (puis suspend)
```bash
cat <<'YAML' | oc apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello-cron
spec:
  schedule: "*/1 * * * *"
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 2
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: Never
          containers:
          - name: hello
            image: registry.access.redhat.com/ubi9/ubi-minimal
            command: ["/bin/sh","-c"]
            args:
              - |
                date
                echo "cron hello"
YAML
```

Vérifier création de jobs :
```bash
oc get cronjob hello-cron -o wide
oc get jobs --watch
```

Suspendre :
```bash
oc patch cronjob hello-cron -p '{"spec":{"suspend":true}}'
oc get cronjob hello-cron -o jsonpath='{.spec.suspend}{"
"}'
```

### 3) Troubleshooting Job/CronJob
- Voir les events :
```bash
oc get events --sort-by=.metadata.creationTimestamp | tail -n 30
```
- Identifier les pods d’un job :
```bash
oc get pods -l job-name=fetch-once
```

## Vérifications
- Job `fetch-once` termine `Complete`.
- CronJob crée des Jobs, puis s’arrête après `suspend: true`.

## Nettoyage
```bash
oc delete project "$NS"
```
