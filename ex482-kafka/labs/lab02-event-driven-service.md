# Lab EX482‑02 – Service métier event‑driven

## Objectif

Construire un petit service métier qui consomme/produit des messages Kafka
et le déployer sur OpenShift.

## Scénario

1. Écrire un microservice (Quarkus, Spring ou autre) qui :
   - consomme des événements sur un topic (ex. `orders`),
   - applique une règle simple (ex. calcul de montant, ajout d’un champ),
   - produit le résultat sur un autre topic (ex. `orders-validated`).

2. Containeriser l’application et la déployer sur OpenShift :
   - Deployment,
   - ConfigMap pour les paramètres Kafka (bootstrap servers, topics),
   - Secret pour les credentials si nécessaire.

3. Tester bout‑en‑bout :
   - produire quelques messages sur `orders`,
   - vérifier leur transformation et leur présence sur `orders-validated`,
   - observer les logs du microservice.

4. Documenter ici :
   - le schéma des messages,
   - les topics utilisés,
   - les patterns que tu pourrais réutiliser (saga, event sourcing simple…).
