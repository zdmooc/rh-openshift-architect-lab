
# Diagrams EX380 – Descriptions

Utilise ces descriptions comme base pour générer des schémas (Draw.io, Mermaid, outil IA d’images…).

- `ex380-overview` : vue globale cluster OCP 4.14 avec blocs Auth, OADP, GitOps, Monitoring, Logging.
- `ex380-auth-flows` : flux utilisateur → Keycloak → OAuth OpenShift → API/console.
- `ex380-oadp-dr` : flux de backup/restore via OADP (Velero) vers S3/MinIO.
- `ex380-gitops-flow` : Git developer → repo Git → Argo CD → cluster.
- `ex380-logging-monitoring` : applications → logs/metrics → Loki/Prometheus → Grafana/Alertmanager.

Tu peux générer :

- des fichiers `.drawio`,
- des diagrammes Mermaid,
- ou des PNG à partir d’un outil graphique.
