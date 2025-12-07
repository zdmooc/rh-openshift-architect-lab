# Chapitre 3 - Ressources : requests/limits, LimitRange, ResourceQuota

## But
Comprendre les échecs “Pending/quota exceeded/OOMKilled” sans perdre de temps.

![Figure 7 - Requests et placement ; limits et contraintes d’exécution](resources/images/fig-07-requests-limits.svg)


## LimitRange vs ResourceQuota
![Figure 9 - LimitRange (défauts) vs ResourceQuota (budget)](resources/images/fig-09-lr-vs-rq.svg)


## Commandes utiles
```bash
oc get limitrange,resourcequota
oc describe resourcequota <name>
oc describe pod <pod>
```



