# Lab 00 — Setup projet

## Création
oc new-project ex288 || oc project ex288

## Vérif
oc whoami; oc project; oc get all -n ex288



# Vue complète utile
oc get deploy,dc,rs,rc,po,svc,route,cm,secret -n ex288 -o wide

# Chaîne d’images (si tu utilises BuildConfig/ImageStream)
oc get bc,is,istag -n ex288
oc describe bc -n ex288
oc describe is -n ex288

# Événements récents
oc get events -n ex288 --sort-by=.lastTimestamp

# Détails d’un workload
oc describe dc/<name> -n ex288   # si DeploymentConfig
oc describe deploy/<name> -n ex288

