# Lab EX480‑01 – Introduction à RHACM (conceptuel)

Si tu as accès à Red Hat Advanced Cluster Management (RHACM), ce lab
peut être pratiqué tel quel. Sinon, utilise‑le comme support théorique.

## Objectif

- Découvrir la console RHACM.
- Enregistrer au moins un cluster “managed”.
- Comprendre les notions de `ClusterSet`, `Placement`, `Policy`.

## Scénario

1. Installer RHACM sur un cluster “management”.
2. Enregistrer un cluster “workload” :
   - via import auto ou manuel,
   - vérifier l’état dans la console (Healthy, etc.).
3. Créer un `ClusterSet` et associer ton cluster.
4. Créer une application de test déployée via RHACM :
   - définir un Placement (critères de sélection de cluster),
   - vérifier le déploiement sur le cluster cible.

Note tes commandes, captures et problèmes ici.
