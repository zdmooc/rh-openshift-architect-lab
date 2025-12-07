# Chapitre 5 - Operators & OLM : comprendre la mécanique

## But
Installer, lire et dépanner un Operator (Subscription/CSV/CRD/CR).

![Figure 15 - Cycle de vie Operator : de l’abonnement à la ressource](resources/images/fig-15-olm-lifecycle.svg)


## Commandes clés
```bash
oc get operatorgroups,subscriptions,csv -n <ns>
oc get crd | head
oc describe csv <name> -n <ns>
```



