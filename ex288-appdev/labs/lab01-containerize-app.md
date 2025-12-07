# Lab EX288‑01 – Containeriser une application

## Objectif

Partir d’une petite application (ex. service REST Java/Quarkus ou Node.js)
et la rendre exécutable sur OpenShift.

## Scénario

1. Partir d’un projet simple :
   - service HTTP qui renvoie une page JSON avec un message et la version.

2. Écrire un `Dockerfile` ou utiliser un build S2I :
   - exposer le port correct,
   - prévoir une variable `APP_ENV` (dev/rec/prod) lue par l’appli.

3. Construire l’image :
   - localement (podman/docker) ou via build OpenShift.

4. Déployer sur un projet `ex288-dev` :
   - Deployment,
   - Service,
   - Route.

5. Vérifier :
   - la réponse de l’API,
   - les logs,
   - la configuration via `APP_ENV`.

Note : met ton code source dans un sous‑dossier (par exemple `src/`) dans
ce dépôt, ou dans un dépôt séparé référencé depuis ici.
