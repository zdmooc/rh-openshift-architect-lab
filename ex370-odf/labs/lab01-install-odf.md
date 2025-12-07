# Lab EX370‑01 – Installation et configuration ODF (conceptuel)

Note : l’installation réelle d’ODF dépend fortement de ton environment
(infrastructure, subscription, etc.). Ce lab te sert de checklist/logbook.

## Objectif

- Comprendre les grandes étapes d’installation d’ODF.
- Identifier les StorageClass fournies.
- Tester une première PVC consommée par une application.

## Scénario (à adapter à ton environnement)

1. Installer les opérateurs nécessaires (ODF / OCS).
2. Créer un cluster de stockage ODF (au moins 3 nœuds workers recommandés).
3. Vérifier les StorageClass créées (block, file, object).
4. Créer une PVC utilisant la StorageClass par défaut ODF.
5. Déployer une petite appli (ex. PostgreSQL) sur cette PVC.
6. Vérifier la persistance des données après redéploiement des pods.

Documente ici :
- les commandes utilisées,
- les captures d’écran éventuelles,
- les problèmes rencontrés et leurs solutions.
