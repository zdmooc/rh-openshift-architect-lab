# Lab EX482‑01 – Cluster Kafka, topics, producteurs/consommateurs

## Objectif

Déployer un cluster Kafka sur OpenShift (AMQ Streams ou équivalent open source)
et manipuler des topics, producteurs et consommateurs.

## Scénario

1. Installer l’opérateur Kafka (AMQ Streams ou Strimzi).
2. Déployer un cluster Kafka minimal.
3. Créer un topic `orders` avec un certain nombre de partitions.
4. Lancer :
   - un producteur qui envoie des messages,
   - un consommateur qui lit les messages.
5. Observer :
   - la répartition des messages,
   - le comportement en cas de redémarrage d’un broker.

Note ici les commandes, manifests, valeurs importantes (replicas, partitions…).
