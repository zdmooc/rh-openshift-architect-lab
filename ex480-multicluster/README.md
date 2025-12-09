# EX480 - Multi-cluster & ACM (Architecte OpenShift)

Ce module couvre les notions d'architecture multi-cluster et Advanced Cluster Management.

## 1. Objectifs

- Concevoir une topologie mgmt + clusters workload.
- Définir des policies et un modèle de placement.
- Préparer une approche GitOps multi-cluster.

## 2. Topologie cible (exemple)

- Cluster "mgmt" : GitOps, ACM, observabilité centrale
- Cluster "build" : workloads CI/CD, préprod
- Cluster "prod" : workloads de production

## 3. Labs à implémenter

- Lab 1 : Définition de la topologie et des labels de clusters
- Lab 2 : Création de policies ACM (RBAC, quotas, sécurité)
- Lab 3 : Déploiement applicatif via placement rules

