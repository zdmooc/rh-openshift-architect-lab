# Lab EX288‑03 – Templates (Helm ou Kustomize)

## Objectif

Utiliser un outil de templating (Helm ou Kustomize) pour gérer plusieurs
environnements à partir d’une base commune.

## Scénario

1. Créer un répertoire `charts/app/` (pour Helm) ou `base/` + `overlays/`
   (pour Kustomize) avec :
   - Deployment,
   - Service,
   - ConfigMap (ou valeurs de config),
   - Route.

2. Définir au moins deux environnements :
   - `dev` avec peu de ressources, une bannière “DEV”,
   - `rec` avec plus de ressources, une bannière “REC”.

3. Déployer successivement `dev` puis `rec` :
   - vérifier les manifests générés,
   - vérifier les pods, services, routes.

4. Documenter dans ce fichier :
   - les valeurs principales,
   - les commandes d’installation/mise à jour (`helm install/upgrade` ou
     `kubectl apply -k` pour Kustomize).

Ce lab te donne une base pour EX288, EX380 et l’ensemble des parties GitOps.
