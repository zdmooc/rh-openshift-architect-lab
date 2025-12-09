# EX280 — Pack de labs (aligné sur les objectifs “les plus récents” Red Hat)

Ce pack contient uniquement des **labs Markdown** (aucune structure de dépôt imposée).  
Objectif : pratiquer *tous* les points de l’examen EX280 (OpenShift Admin / Day-2) via CLI `oc` (et parfois console).

## Conventions
- Les commandes sont données pour `bash`/Git Bash.
- Les ressources utilisent des préfixes `ex280-...` pour limiter les collisions.
- Chaque lab inclut :
  - Objectifs
  - Contexte / prérequis
  - Tâches
  - Vérifications
  - Nettoyage
- Lorsque ta plateforme locale (ex: CRC / OpenShift Local) ne supporte pas une fonctionnalité (ex: `LoadBalancer`), le lab propose une **branche “Examen / Prod”** + une **branche “Local/CRC”** pour rester utile.

## Recommandation d’usage (méthode exam)
- Toujours commencer par lire toutes les tâches du lab.
- Écrire une “checklist” de ce qui doit exister à la fin (ressources + champs).
- Utiliser `oc explain`, `oc get -o yaml`, `oc describe`, `oc logs`, `oc events` en boucle.
- Privilégier les manifests YAML + `oc apply` dès que possible.

## Nommage
- Namespace: `ex280-<lab>-<tonprenom>` (adapte au besoin)
- Applis: `hello`, `web`, `api`, etc.

## Fichiers inclus
- `lab01` à `lab14`

Bon entraînement.
