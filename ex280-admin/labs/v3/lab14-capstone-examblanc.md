# Lab 14 — Capstone: examen blanc (scénarios multi-objectifs) + checklist de validation


## Objectif
Simuler une session EX280 en “tâches indépendantes”, avec une checklist de validation.  
Tu peux te donner 90–120 minutes et traiter les items dans l’ordre que tu veux.

## Préparation
```bash
export NS=ex280-capstone-zidane
oc new-project "$NS"
```

## Scénario A — Déploiement et exposition
1. Déployer une appli `web` depuis une image (au choix) avec 2 replicas.
2. Créer un Service qui pointe sur les pods de `web`.
3. Créer une Route HTTPS (edge) avec redirection HTTP→HTTPS.
4. Prouver l’accès depuis un pod `curl` interne ET depuis l’extérieur (si possible).

Checklist :
- `oc get deploy web` = AVAILABLE
- `oc get svc web` existe + selectors corrects
- `oc get route web` en TLS edge + Redirect
- Tests curl OK

## Scénario B — ConfigMaps/Secrets + déclaratif
1. Créer une ConfigMap `app-config` (2 clés) + un Secret `app-secret` (2 clés).
2. Déployer un pod qui lit les deux via `envFrom`.
3. Exporter le YAML du pod, le modifier localement pour monter la ConfigMap en volume, puis ré-appliquer.

Checklist :
- `oc get cm,secret`
- `oc logs` montre valeurs attendues (sans exposer secrets en clair en prod)
- YAML export/import OK

## Scénario C — RBAC + ServiceAccount API
1. Créer une SA `api-reader`.
2. Créer Role + RoleBinding pour lister/get/watch les pods.
3. Déployer un pod utilisant la SA et appelant l’API Kubernetes.
4. Prouver qu’un DELETE est interdit (403).

Checklist :
- Role/RoleBinding existent
- `curl .../pods` retourne 200
- `curl -X DELETE ...` retourne 403

## Scénario D — Quotas & LimitRanges
1. Appliquer une ResourceQuota qui limite pods + CPU/mem.
2. Appliquer un LimitRange qui injecte des defaults.
3. Prouver qu’un pod sans resources reçoit requests/limits.
4. Provoquer un dépassement quota (et expliquer le message).

Checklist :
- `oc describe quota` montre usage/hard
- `oc get pod -o jsonpath ...resources` montre defaults

## Scénario E — NetworkPolicy
1. Déployer `backend` + `frontend` + `intruder`.
2. Bloquer ingress vers `backend` puis autoriser uniquement `frontend`.
3. Prouver (tests curl) le résultat.

Checklist :
- networkpolicies présentes
- tests OK/FAIL conformes

## Scénario F — Job/CronJob
1. Créer un Job one-shot qui lit un secret et écrit un log.
2. Créer un CronJob toutes les minutes puis le suspendre.
3. Prouver l’historique (jobs créés).

Checklist :
- Job complete
- CronJob suspend true

## Nettoyage
```bash
oc delete project "$NS"
```
