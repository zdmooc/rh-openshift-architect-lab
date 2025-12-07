# Lab EX288‑02 – Configuration applicative et CI simple

## Objectif

Gérer la configuration applicative selon l’environnement (dev/rec/prod)
et automatiser un pipeline simple de build/déploiement.

## Scénario

1. Créer trois namespaces :
   - `ex288-dev`
   - `ex288-rec`
   - `ex288-prod`

2. Pour chaque namespace :
   - créer un ConfigMap avec des valeurs différentes (`APP_ENV`, `WELCOME_MSG`),
   - déployer la même image applicative, mais câblée sur le ConfigMap local.

3. Mettre en place un pipeline CI (GitLab, Tekton, ou autre) :
   - étape 1 : build de l’image et push sur un registry,
   - étape 2 : mise à jour du manifest dans un repo Git d’“environnement”,
   - étape 3 : (option) intégration avec Argo CD pour appliquer les manifests.

4. Vérifier que :
   - l’application renvoie la bonne configuration selon le namespace,
   - le pipeline se déclenche automatiquement sur commit.

Ce lab prépare les notions que tu retrouves ensuite dans EX380.
