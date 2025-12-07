# Lab EX380‑01 – Pipeline CI d’image conteneur

## Objectif

Mettre en place un pipeline CI qui :
- construit une image d’application,
- la scanne,
- la pousse vers un registry,
- met à jour un manifest pour déploiement.

## Scénario

1. Choisir un outil CI (GitLab CI, GitHub Actions ou autre) et :
   - créer un fichier de pipeline (`.gitlab-ci.yml`, etc.),
   - définir des stages `build`, `scan`, `push`.

2. Étape `build` :
   - construire l’image à partir du Dockerfile de ton appli,
   - tagger l’image avec le commit ou la version.

3. Étape `scan` :
   - lancer un scan basique (Trivy, Grype…),
   - faire échouer le pipeline si des vulnérabilités critiques sont trouvées.

4. Étape `push` :
   - pousser l’image vers un registry (Docker Hub, Quay, Artifactory…).

5. Étape `update-manifest` (option) :
   - mettre à jour le tag d’image dans un fichier de manifest ou de chart Helm.

Ce lab prépare la partie “CI” de ta chaîne DevSecOps.
