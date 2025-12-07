# Chapitre 2 – Rappels OpenShift pour EX370

Ce chapitre ne remplace pas une vraie préparation EX280, mais rappelle les points
indispensables pour être à l'aise pendant EX370.

## 2.1. Contexte et projet courant

Commandes à maîtriser par cœur :

```bash
oc whoami
oc config get-contexts
oc project
oc projects
```

## 2.2. Inspection du cluster

```bash
oc get nodes -o wide
oc get clusterversion
oc get clusteroperators
oc get pods -A
oc get events -A
```

Utilise `oc describe` sur les ressources clés (node, pod, pvc, pv, storageclass)
pour comprendre leur état et les éventuels messages d'erreur.

## 2.3. Ressources de base

- Pods, Deployments, ReplicaSets, Services, Routes.
- ConfigMaps et Secrets pour la configuration.
- Namespaces/projets pour l'isolation et les quotas.

Rappels rapides :

```bash
oc new-project ex370-lab
oc create deployment hello --image=registry.access.redhat.com/ubi8/ubi
oc expose deployment hello --port=8080
oc expose svc/hello
oc get all -n ex370-lab
```

## 2.4. Quotas et LimitRange

EX370 implique de manipuler les quotas liés au stockage (PV/PVC).

- `ResourceQuota` : limite le nombre/taille des PVC, pv, etc.
- `LimitRange` : définit des bornes par défaut/min/max pour les ressources.

Tu trouveras des exemples dans `labs/05-capacity-and-extensions/`.
