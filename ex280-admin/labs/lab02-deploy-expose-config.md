# Lab EX280‑02 – Déployer, exposer et configurer une application

## Objectif

Savoir déployer une application simple, l’exposer via un service/route
et gérer sa configuration avec ConfigMap/Secret.

## Scénario

1. Dans le projet `ex280-dev` :
   - Déployer une application HTTP (par exemple image UBI httpd ou nginx).
   - S’assurer qu’elle est en `Deployment` avec au moins 2 replicas.

2. Créer :
   - un `Service` pour l’exposer dans le cluster,
   - une `Route` pour l’exposer vers l’extérieur.

3. Ajouter une page de configuration :
   - Créer un `ConfigMap` contenant un message (par ex. `WELCOME_MSG`).
   - Monter ce ConfigMap dans le pod (en variable d’environnement ou fichier).
   - Vérifier que la page renvoie ce message.

4. Ajouter un mot de passe en `Secret` :
   - Créer un `Secret` avec un mot de passe d’admin.
   - Monter le secret en variable d’environnement (ou fichier).
   - Vérifier qu’il n’apparaît pas en clair dans les logs.

## Points clés

- `oc new-app` ou `oc create deployment` + `oc expose`.
- Différence ConfigMap vs Secret.
- Gestion du rollout (`oc rollout status`, `oc rollout history`).
