# Lab14 — Mini Exam Scenario (90 min)

## Objectif

Rejouer un mini-examen EX280 en une passe :
- Projet unique.
- Déploiement HTTP.
- PVC + probes.
- ConfigMap + Secret.
- Service + Route.
- Quotas/limits.
- Petit troubleshooting final.

## Pré-requis

- Labs 00→13 déjà pratiqués.

---

## Steps (squelette)

1. Créer le projet :
   
       oc new-project ex280-lab14-mini-exam-zidane
       oc project ex280-lab14-mini-exam-zidane

2. Créer un `ResourceQuota` + `LimitRange` (inspiré du Lab08).

3. Créer un PVC `web-pvc` (Lab03) et éventuellement un PV manuel si tu veux pousser.

4. Créer un Deployment `exam-web` :
   - Image httpd ubi8.
   - Probes liveness/readiness sur `/` port 8080.
   - Requests/limits raisonnables.

5. Monter le PVC sur `/var/www/html`.

6. Créer un ConfigMap + Secret avec quelques valeurs, les injecter dans le container.

7. Exposer l’app :
   - Service `exam-web-svc`.
   - Route `exam-web-route`.

8. Introduire une erreur :
   - Par exemple, changer l’image en un nom invalide, ou casser la probe (mauvais path).

9. Diagnostiquer :
   
       oc get pods
       oc describe pod -l app=exam-web
       oc get events --sort-by=.lastTimestamp | tail -20
       oc logs -l app=exam-web || true

10. Corriger l’erreur (image/probe), vérifier que tout repasse en `Running`.

---

## Vérifications

- L’ensemble est réalisable en < 90 minutes.
- Tous les objets clés présents dans `ex280-lab14-mini-exam-zidane` :
  - `ResourceQuota`, `LimitRange`
  - PVC (et éventuellement PV)
  - Deployment `exam-web`
  - ConfigMap + Secret
  - Service + Route

---

## Cleanup (optionnel)

    oc delete project ex280-lab14-mini-exam-zidane --ignore-not-found
