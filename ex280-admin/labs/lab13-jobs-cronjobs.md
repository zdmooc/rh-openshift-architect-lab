# Lab13 — Jobs & CronJobs

## Objectif
- Créer un Job simple.
- Créer un CronJob périodique.

## Pré-requis
- kubeadmin.

## Steps

### Step 1 — Projet
    oc get project ex280-lab13-batch-zidane || oc new-project ex280-lab13-batch-zidane
    oc project ex280-lab13-batch-zidane

### Step 2 — Job
    cat << 'YAML' | oc apply -f -
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: hello-job
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: main
            image: registry.access.redhat.com/ubi8/ubi-minimal
            command: ["bash","-c","echo Hello from Job && sleep 5"]
    YAML

### Step 3 — CronJob
    cat << 'YAML' | oc apply -f -
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: hello-cron
    spec:
      schedule: "*/5 * * * *"
      jobTemplate:
        spec:
          template:
            spec:
              restartPolicy: OnFailure
              containers:
              - name: main
                image: registry.access.redhat.com/ubi8/ubi-minimal
                command: ["bash","-c","echo Hello from CronJob && sleep 5"]
    YAML

## Vérifications
    oc get jobs
    oc get cronjobs
    oc get pods

## Cleanup (optionnel)
    oc delete project ex280-lab13-batch-zidane --ignore-not-found
