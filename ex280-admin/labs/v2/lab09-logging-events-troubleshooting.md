# Lab09 — Logging & Troubleshooting

## Objectif

- Casser volontairement un déploiement.
- Utiliser logs / events / describe pour diagnostiquer.
- Corriger le problème.

## Pré-requis

- kubeadmin.

---

## Steps

### Step 1 — Projet

    oc get project ex280-lab09-trouble-zidane || oc new-project ex280-lab09-trouble-zidane
    oc project ex280-lab09-trouble-zidane

### Step 2 — Déploiement cassé

    oc create deployment bad-image --image=doesnotexist.invalid/foo:latest

    oc get pods
    oc describe pod -l app=bad-image
    oc get events --sort-by=.lastTimestamp | tail -20

### Step 3 — Correction de l’image

    oc set image deployment/bad-image bad-image=registry.access.redhat.com/ubi8/httpd-24

    oc get pods
    oc describe pod -l app=bad-image
    oc logs -l app=bad-image || true

---

## Vérifications

    oc get pods
    oc describe pod -l app=bad-image

Critères :

- Pod d’abord en `ImagePullBackOff` (ou équivalent).
- Après correction, pod en `Running`.

---

## Cleanup (optionnel)

    oc delete project ex280-lab09-trouble-zidane --ignore-not-found

---

## Pièges fréquents

- Ne jamais corriger “à l’aveugle” → toujours regarder `describe` + `events` + `logs`.
