# Lab13 — Jobs & CronJobs (avec ServiceAccount)

## Objectif

- Créer un Job simple.
- Créer un CronJob périodique.
- Utiliser une ServiceAccount dédiée pour le CronJob.

## Pré-requis

- kubeadmin.

---

## Steps

### Step 1 — Projet

    oc get project ex280-lab13-batch-zidane || oc new-project ex280-lab13-batch-zidane
    oc project ex280-lab13-batch-zidane

### Step 2 — ServiceAccount pour les batchs

    oc create serviceaccount batch-sa
    oc get sa
    oc describe sa batch-sa

### Step 3 — Job

    cat << 'YAML' | oc apply -f -
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: hello-job
    spec:
      template:
        spec:
          serviceAccountName: batch-sa
          restartPolicy: OnFailure
          containers:
          - name: main
            image: registry.access.redhat.com/ubi8/ubi-minimal
            command: ["bash","-c","echo Hello from Job && sleep 5"]
    YAML

    oc get jobs
    oc get pods
    oc logs -l job-name=hello-job || true

### Step 4 — CronJob

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
              serviceAccountName: batch-sa
              restartPolicy: OnFailure
              containers:
              - name: main
                image: registry.access.redhat.com/ubi8/ubi-minimal
                command: ["bash","-c","echo Hello from CronJob && sleep 5"]
    YAML

    oc get cronjobs
    oc get jobs
    oc get pods

---

## Vérifications

    oc get jobs
    oc get cronjobs
    oc get pods

Critères :

- Job `hello-job` a tourné au moins une fois (pod Completed).
- CronJob `hello-cron` déclenche des Jobs toutes les 5 minutes.
- Les pods des Jobs/CronJobs utilisent la SA `batch-sa`.

---

## Cleanup (optionnel)

    oc delete project ex280-lab13-batch-zidane --ignore-not-found

---

## Pièges fréquents

- `schedule` invalide → CronJob ne se déclenche pas.
- SA non trouvée → vérifier `serviceAccountName` dans le template.
