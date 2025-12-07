# Lab EX370‑02 – Base de données stateful + sauvegarde

## Objectif

Mettre en place une base de données stateful sur ODF et simuler
une stratégie de sauvegarde/restauration.

## Scénario (conceptuel, à adapter)

1. Déployer PostgreSQL ou MySQL :
   - avec un Deployment (ou StatefulSet),
   - une PVC ODF pour les données.

2. Initialiser une base de test :
   - créer une table,
   - insérer quelques enregistrements.

3. Mettre en place une sauvegarde simple :
   - par exemple un `pg_dump` ou équivalent dans un job Kubernetes,
   - stockage du dump dans un volume objet ou fichier.

4. Tester la restauration :
   - supprimer et recréer le pod/Deployment,
   - réimporter la sauvegarde,
   - vérifier que les données sont présentes.

5. Noter ici :
   - les StorageClass utilisées,
   - la taille des volumes,
   - le temps de restauration.

Ce lab te aide à parler de **PRA/PCA** autour d’ODF en entretien.
