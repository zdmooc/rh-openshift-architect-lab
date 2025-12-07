# Cluster de lab – Setup minimal

Objectif : disposer d’un cluster sur lequel tu peux exécuter tous les labs.

## Options possibles

1. **CodeReady Containers (CRC)** ou OpenShift Local
   - Avantage : expérience très proche d’un vrai cluster OpenShift.
   - Inconvénient : gourmand en ressources (RAM/CPU).

2. **OKD / Kind + OpenShift GitOps**
   - Avantage : léger, bonne solution de lab sur portable.
   - Inconvénient : certaines commandes/ressources diffèrent légèrement d’OCP.

3. **Cluster managé (ROSA, ARO, etc.)**
   - Avantage : proche d’un contexte client.
   - Inconvénient : coût potentiel + dépendance au cloud provider.

Choisis une option et documente précisément :
- la version de la plateforme,
- la méthode d’installation,
- les commandes de base pour te connecter (`oc login`),
- la manière dont tu exposes les routes (ingress, load balancer, etc.).

Ajoute ici tes notes concrètes (images, scripts, captures) au fur et à mesure.
