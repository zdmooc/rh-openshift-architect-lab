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

## Steps (squelette)

1. Créer projet `ex280-lab14-mini-exam-zidane`.
2. Déployer une appli httpd avec :
   - PVC monté sur `/var/www/html`.
   - Probes liveness/readiness.
   - Requests/limits raisonnables.
3. Ajouter ConfigMap + Secret et exposer quelques variables.
4. Créer Service + Route HTTP.
5. Ajouter ResourceQuota + LimitRange.
6. Introduire une erreur (mauvaise image ou mauvais port).
7. Diagnostiquer avec `oc describe`, `oc logs`, `oc get events`.
8. Corriger et valider que tout est `Running`.

## Vérifications
- L’ensemble est réalisable en < 90 minutes.
- Tous les objets clés présents (Deployment, PVC, CM/Secret, SVC, Route, Quota).

## Cleanup (optionnel)
    oc delete project ex280-lab14-mini-exam-zidane --ignore-not-found
