# QCM 01 — Concepts EX288
1) Rôle d'une ImageStream ?
2) Différence Deployment vs DeploymentConfig ?
3) Commande pour exposer un Service ?
4) Où vivent les Routes ?
5) Annuler un rollout ?

## Réponses
1) Référentiel d'images + trigger imageChange.
2) DC a des triggers intégrés (IS/Build); Deployment = K8s.
3) oc expose svc/<name>.
4) Au niveau projet (namespace).
5) oc rollout undo dc/<name>.
