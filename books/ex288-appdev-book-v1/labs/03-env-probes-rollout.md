# Lab 03 — Env, probes, rollouts

## Modifier variable
oc set env dc/ex288 MSG=updated -n ex288 --overwrite
oc rollout status dc/ex288 -n ex288

## Probes (si besoin)
oc set probes dc/ex288 --liveness --get-url=http://:8080/ --initial-delay-seconds=10 -n ex288
oc set probes dc/ex288 --readiness --get-url=http://:8080/ --initial-delay-seconds=5 -n ex288

## Rollback
ochg=$(oc rollout history dc/ex288 -n ex288 | awk 'NR==2{print $1}')
# Pour annuler au précédent: oc rollout undo dc/ex288 -n ex288
