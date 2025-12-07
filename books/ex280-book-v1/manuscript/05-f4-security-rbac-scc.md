# Chapitre 4 - Sécurité : RBAC, ServiceAccount, SCC

## But
Savoir pourquoi un accès est refusé (RBAC) ou pourquoi un pod ne démarre pas (SCC).

## RBAC (qui a le droit de faire quoi)
![Figure 10 - Autorisations RBAC dans un namespace](resources/images/fig-10-rbac.svg)


## ServiceAccount (identité runtime)
![Figure 12 - Identité runtime : ServiceAccount attaché au pod](resources/images/fig-10-rbac.svg)


## SCC (admission)
![Figure 13 - Pourquoi un pod est refusé : SCC et contraintes](resources/images/fig-13-scc.svg)


## Commandes “exam”
```bash
oc auth can-i get pods -n <ns>
oc get rolebinding,clusterrolebinding -n <ns>
oc get pod <pod> -o yaml | sed -n '1,120p'
oc describe pod <pod> | sed -n '1,120p'
```






