# Exam blanc EX370 – Scénario

Durée conseillée : 3 h.

1. Vérifie l'état du cluster OpenShift et du cluster ODF.
2. Configure un projet `ex370-mock` et déploie :
   - une app utilisant un PVC CephFS (partage de fichiers),
   - une app utilisant un PVC RBD (base de données simulée).
3. Fais pointer la registry interne sur une StorageClass ODF.
4. Configure le monitoring pour stocker ses données sur ODF.
5. Crée un VolumeSnapshot pour la base simulée, puis un clone, et vérifie
   que tu peux revenir à un état antérieur.
6. Crée un ObjectBucketClaim, configure un client S3 et écris des fichiers
   dans le bucket.
7. Mets en place un Role/RoleBinding pour restreindre la gestion des PVC/OBC
   au seul utilisateur `developer` dans le projet.

Garde la trace de toutes les commandes utilisées pour pouvoir les rejouer.
