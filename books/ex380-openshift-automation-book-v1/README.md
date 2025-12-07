# EX380 – Red Hat Certified Specialist in OpenShift Automation and Integration

Ce dépôt est un kit de préparation “from scratch” à l’examen **EX380**, basé sur **Red Hat OpenShift Container Platform 4.14**.

Objectif : t’entraîner à planifier, implémenter et gérer des déploiements OpenShift à grande échelle, en couvrant les grands thèmes de l’examen :

- Authentification & identités (LDAP, OIDC/Keycloak, RBAC, kubeconfig)
- Sauvegarde / restauration avec OADP (Velero + plugins CSI / S3)
- Cluster partitioning (labels, MachineConfigPools, nœuds infra/dédiés)
- Scheduling avancé (taints/tolerations, PDB, affinity/anti-affinity, defaults)
- GitOps avec OpenShift GitOps (Argo CD intégré)
- Monitoring & métriques (Prometheus, Alertmanager, Grafana)
- Logging centralisé (Cluster Logging, Vector + Loki, Event Router)

> Prérequis : niveau EX280 (ou équivalent) confortable, DO180/DO280 déjà assimilés.

## Structure du dépôt

- `LAB_TEMPLATE.md` : modèle standard de TP.
- `00-prereq-refresh/` : révision EX280 / DO280.
- `01-auth-identities/` : IdentityProviders, GroupSync, RBAC, kubeconfig.
- `02-oadp-backup-restore/` : OADP, backups, restores, snapshots, schedules.
- `03-cluster-partitioning/` : labels, MachineConfigPools, nœuds dédiés.
- `04-advanced-scheduling/` : taints/tolerations, PDB, affinity, defaults.
- `05-gitops-openshift/` : OpenShift GitOps (Argo CD) pour infra + apps.
- `06-monitoring-metrics/` : troubleshooting applicatif/cluster via métriques.
- `07-logging-loki-vector/` : stack de logs centralisée.
- `08-exam-scenarios/` : scénarios EX380-like, chronométrés.
- `diagrams/` : descriptions d’architecture (à transformer en PNG/Draw.io).
- `manus/` : prompts pour agents (Manus, autres IA) afin de générer les diagrammes et enrichir les labs.

## Mode d’emploi conseillé

1. Lire `LAB_TEMPLATE.md` et t’en servir comme modèle.
2. Commencer par `00-prereq-refresh` (1–2 jours de warm-up).
3. Travailler chaque dossier dans l’ordre, en **CLI-first** :
   - lire le `README.md` du dossier,
   - exécuter chaque `lab-XX-*.md`,
   - prendre des notes (carnet ou wiki).
4. Terminer par `08-exam-scenarios` en conditions d’examen :
   - 1 scénario = 2–3 h,
   - pas de documentation web, uniquement `oc` / `kubectl` / manpages.

## Environnements possibles

- **OpenShift Local / crc** pour la pratique basique.
- Un cluster de lab 4.x (on-prem ou cloud) pour :
  - OADP avec un vrai backend objet (MinIO, S3),
  - GitOps multi-namespaces,
  - Logging/Monitoring réalistes.

> Ce dépôt est un matériel d’entraînement. Il ne contient ni sujets d’examen, ni braindumps, ni réponses officielles Red Hat.
