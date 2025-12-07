# Lab EX280‑01 – Projets, utilisateurs et accès

## Objectif

Savoir :
- créer et gérer des projets (namespaces),
- attribuer des rôles de base à des utilisateurs,
- vérifier l’isolation entre projets.

## Scénario

1. Créer trois projets de travail :
   - `ex280-dev`
   - `ex280-rec`
   - `ex280-prod`

2. Créer ou simuler trois utilisateurs :
   - `dev-user` (droits sur ex280-dev uniquement),
   - `rec-user` (droits sur ex280-rec),
   - `ops-user` (droits d’admin sur les trois projets).

3. Attribuer les rôles via `oc adm policy` :
   - `edit` pour les développeurs dans leur projet,
   - `admin` ou `view` selon le besoin.

4. Vérifier :
   - que chaque utilisateur voit uniquement son projet,
   - qu’un dev ne peut pas lister/modifier les ressources d’un autre projet.

## Points clés

- Commandes `oc new-project`, `oc get projects`, `oc project`.
- Concepts `Role`, `RoleBinding`, `ClusterRole`, `ClusterRoleBinding`.
- Bonne pratique : toujours vérifier le projet courant avec `oc project` avant
  de créer des ressources.
