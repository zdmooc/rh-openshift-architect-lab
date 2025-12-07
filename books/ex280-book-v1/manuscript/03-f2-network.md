# Chapitre 2 - Réseau : du Pod à Internet

## But
Maîtriser les chemins réseau les plus probables à l’examen.

## Chemin standard
![Figure 4 - Chemin réseau standard en OpenShift (Pod → Service → Route)](resources/images/fig-04-pod-svc-route.svg)


## TLS sur Route
![Figure 5 - Terminaison TLS selon le type de Route](resources/images/fig-04-pod-svc-route.svg)


## Commandes utiles
```bash
oc get svc,route,endpoints,endpointslices
oc describe route <name>
oc rsh <pod> -- curl -sS http://<svc>:<port>/
```

## À retenir
- Si l’externe ne répond pas : vérifier **Route → Service → Endpoints → Pod**.






