# Lab EX280‑03 – Persistance, probes et ressources

## Objectif

Ajouter de la persistance à une application, ainsi que des probes et des
limites/requests de ressources.

## Scénario

1. Créer une `PersistentVolumeClaim` :
   - StorageClass par défaut ou dédiée (si disponible).
   - Taille 1–2 Gi.
   - Mode d’accès adapté (ReadWriteOnce le plus souvent).

2. Modifier le Deployment de ton application HTTP (lab 02) pour :
   - Monter la PVC sur un chemin (ex. `/var/www/html/data`).
   - Créer un fichier dans ce volume et vérifier qu’il persiste après
     suppression/recréation du pod.

3. Ajouter des probes :
   - `readinessProbe` avec HTTP GET sur `/healthz` ou `/`.
   - `livenessProbe` avec HTTP GET ou exec simple.

4. Ajouter des ressources :
   - `resources.requests.cpu` et `.memory`.
   - `resources.limits.cpu` et `.memory`.

5. Vérifier :
   - l’état des pods (`READY`, `RESTARTS`),
   - le comportement en cas de probe qui échoue (pod redémarré),
   - le comportement en cas de limite CPU/mémoire.

## Points clés

- Savoir éditer un Deployment (YAML ou `oc set resources` / `oc set probe`).
- Comprendre la différence readiness vs liveness.
- Comprendre la notion de PVC et le lien avec la StorageClass.
