# Chapitre 6 - Troubleshooting : la routine unique (mode examen)

## But
Avoir une méthode stable et rapide quel que soit le symptôme.

![Figure 16 - Routine unique de diagnostic](resources/images/fig-16-troubleshooting-routine.svg)


## Routine (scriptable mentalement)
1) Confirmer contexte/projet  
2) Lire events + describe  
3) Logs (et `--previous`)  
4) Réseau : svc/route/endpoints/DNS/NetPol  
5) Corriger minimalement  
6) Re-tester + re-check  

## Commandes noyau
```bash
oc project
oc get pods -o wide
oc get events --sort-by=.lastTimestamp | tail -n 30
oc describe pod <pod>
oc logs <pod> --all-containers --tail=200
oc logs <pod> --previous --all-containers --tail=200
```



