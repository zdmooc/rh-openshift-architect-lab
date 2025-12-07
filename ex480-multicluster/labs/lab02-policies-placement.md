# Lab EX480‑02 – Policies et placement multi‑cluster

## Objectif

Utiliser RHACM pour imposer des politiques communes et déployer
des applications sur plusieurs clusters selon des règles de placement.

## Scénario

1. Créer une `Policy` simple :
   - ex. forcer une `LimitRange` ou une `ResourceQuota` dans un namespace.
   - appliquer cette policy à un ClusterSet ou à un cluster.

2. Vérifier la compliance :
   - voir le statut dans RHACM,
   - corriger un cas de non‑compliance,
   - vérifier la remontée de l’état.

3. Créer une application “multi‑cluster” :
   - utiliser un placement pour déployer sur 2 clusters,
   - modifier ensuite le placement pour ne cibler qu’un seul cluster,
   - observer l’effet (ajout/suppression des ressources côté clusters).

Documente clairement ce qui se passe, afin de pouvoir l’expliquer en entretien.
