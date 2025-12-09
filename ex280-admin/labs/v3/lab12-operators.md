# Lab 12 — Operators: installer, vérifier, désinstaller proprement (Subscription/CSV/OperatorGroup)


## Objectifs EX280 couverts
- Installer un operator
- Désinstaller / supprimer un operator

## Prérequis
- Droits permettant d’installer un operator (souvent cluster-admin ou rôle dédié).
- Accès OperatorHub activé.
- Un namespace dédié opérateurs conseillé.

```bash
export LAB=12
export NS=ex280-lab${LAB}-zidane
oc new-project "$NS"
```

## Tâches (méthode “exam”)
### 1) Rechercher un operator et choisir une cible
Depuis la console : OperatorHub → rechercher (ex: **Kubernetes Metrics Server**, **Local Storage Operator**, **OpenShift Pipelines**, etc.).  
Le choix dépend de ce qui est disponible dans ton environnement d’entraînement.

### 2) Installer via manifests (Subscription)
> Le YAML exact dépend de l’operator choisi.
Workflow attendu :
- Créer `OperatorGroup` (si requis)
- Créer `Subscription`
- Attendre `ClusterServiceVersion (CSV)` en `Succeeded`

Commandes génériques de vérification :
```bash
oc get operatorgroup -n "$NS"
oc get subscription -n "$NS"
oc get csv -n "$NS"
oc describe subscription -n "$NS" | sed -n '1,200p'
oc describe csv -n "$NS" | sed -n '1,200p'
```

### 3) Créer une ressource Custom Resource (CR) si l’operator le demande
- Lire la doc du CRD installée :
```bash
oc get crd | head
oc get crd | grep -i <motcle>
oc explain <kind> --api-version=<apiVersion>
```
- Appliquer un CR minimal (selon operator), puis vérifier :
```bash
oc get <kind>
oc describe <kind> <name> | sed -n '1,220p'
```

### 4) Désinstaller proprement
Ordre recommandé :
1. Supprimer les CR instances (si présentes)
2. Supprimer `Subscription`
3. Supprimer `CSV` (si pas auto)
4. Supprimer `OperatorGroup`

Exemple :
```bash
oc delete subscription <sub-name> -n "$NS"
oc delete csv <csv-name> -n "$NS" || true
oc delete operatorgroup <og-name> -n "$NS" || true
```

## Vérifications
- Installation: CSV `Succeeded`, pods operator `Running`.
- Désinstallation: plus de CSV/Subscription dans le namespace.

## Nettoyage
```bash
oc delete project "$NS"
```
