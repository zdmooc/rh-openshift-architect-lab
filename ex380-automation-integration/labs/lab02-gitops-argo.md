# Lab EX380‑02 – GitOps avec Argo CD

## Objectif

Déployer et mettre à jour des applications sur OpenShift en mode GitOps
à l’aide d’Argo CD.

## Scénario

1. Installer Argo CD sur ton cluster de lab (ou utiliser OpenShift GitOps).

2. Créer un dépôt Git “environnements” contenant :
   - un ou plusieurs dossiers de manifests/Helm pour ton appli,
   - au moins deux environnements (`dev`, `rec`).

3. Créer une Application Argo CD pour `dev` :
   - source : repo Git + chemin,
   - destination : cluster + namespace.

4. Vérifier :
   - sync initiale,
   - auto‑heal (corruption volontaire d’un Deployment puis resync),
   - comportement lors d’un changement de version d’image.

5. Répéter pour `rec` avec des valeurs différentes (replicas, ressources).

Ce lab est un pivot vers le multi‑cluster (EX480) et le reste de la plateforme.
