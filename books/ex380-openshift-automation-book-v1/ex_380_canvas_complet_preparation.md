# Canvas complet – Préparation EX380 (OpenShift Automation and Integration)

## 1. Objectif global

Préparer de façon structurée l’examen **Red Hat Certified Specialist in OpenShift Automation and Integration (EX380)** sur **OpenShift 4.14**, en s’appuyant sur :

- Un dépôt Git d’entraînement : `ex380-openshift-automation/`.
- Des labs orientés **CLI-first**.
- Des scénarios d’“examen blanc”.
- Des diagrammes d’architecture (à générer plus tard).

But final : être capable de **planifier, implémenter et exploiter** un cluster OpenShift à grande échelle avec :

- Authentification avancée (LDAP, OIDC/Keycloak) et RBAC.
- Sauvegarde / restauration avec OADP.
- Partitionnement de cluster (MachineConfigPools, nœuds dédiés).
- Scheduling avancé (taints/tolerations, PDB, (anti-)affinity, defaults).
- GitOps avec OpenShift GitOps (Argo CD intégré).
- Monitoring & métriques.
- Logging centralisé avec Vector + Loki / Event Router.

---

## 2. Vue d’ensemble du dépôt

Arborescence logique du dépôt :

```text
ex380-openshift-automation/
├── README.md
├── LAB_TEMPLATE.md
├── 00-prereq-refresh/
├── 01-auth-identities/
├── 02-oadp-backup-restore/
├── 03-cluster-partitioning/
├── 04-advanced-scheduling/
├── 05-gitops-openshift/
├── 06-monitoring-metrics/
├── 07-logging-loki-vector/
├── 08-exam-scenarios/
├── diagrams/
└── manus/
```

### 2.1. Fichiers racine

- **`README.md`** :
  - Présentation du dépôt, des objectifs et de la structure.
  - Conseils de parcours (ordre des dossiers, rythme, environnement cible).
- **`LAB_TEMPLATE.md`** :
  - Gabarit standard de lab.
  - Contient la structure type : objectifs, prérequis, énoncé type examen, plan d’attaque, commandes, vérifications, nettoyage, points clés.

### 2.2. Dossiers pédagogiques

- **`00-prereq-refresh/`** : warm-up EX280 (bases admin OCP).
- **`01-auth-identities/`** : IDP LDAP, IDP OIDC Keycloak, Group Sync, RBAC, kubeconfig.
- **`02-oadp-backup-restore/`** : installation OADP, DPA, backup/restore de namespaces, snapshots, schedules.
- **`03-cluster-partitioning/`** : labels de nœuds, MachineConfigPools, nœuds infra/dédiés.
- **`04-advanced-scheduling/`** : taints/tolerations, PDB, (anti-)affinity, defaults de projet.
- **`05-gitops-openshift/`** : installation OpenShift GitOps, GitOps pour infra + apps, App-of-Apps simple.
- **`06-monitoring-metrics/`** : troubleshooting applicatif/cluster via métriques, alertes et silences.
- **`07-logging-loki-vector/`** : stack logging Vector + Loki, Event Router, rétention.
- **`08-exam-scenarios/`** : scénarios complets EX380-like.
- **`diagrams/`** : descriptions des schémas d’architecture.
- **`manus/`** : prompt pour agents Manus / IA afin de compléter/enrichir les labs.

---

## 3. Détail par bloc pédagogique

### 3.1. Bloc 00 – Prérequis / Révision EX280

Dossier : `00-prereq-refresh/`

Contenu clé :

- `README.md` : objectifs de révision.
- `lab-01-review-ex280.md` :
  - Création d’un projet `ex380-warmup`.
  - Déploiement d’une app HTTP simple (image UBI httpd).
  - Service + Route publique.
  - ConfigMap + Secret injectés par `oc set env`.
  - Probes (liveness, readiness) par `oc set probe`.
  - Ressources (requests/limits) par `oc set resources`.
  - PVC 1Gi + montage dans le pod.

Objectif : réactiver les réflexes EX280 avant d’attaquer EX380.

---

### 3.2. Bloc 01 – Authentification & identités

Dossier : `01-auth-identities/`

Objectifs :

- Configurer différents IdentityProviders dans OpenShift.
- Mapper les claims externes (groupes, username) vers les utilisateurs OCP.
- Gérer la synchronisation de groupes et les droits via RBAC.
- Générer des kubeconfig ciblés pour les utilisateurs.

Fichiers principaux :

- `README.md` : synthèse des objectifs et liste des labs.
- `lab-01-idp-ldap.md` : skeleton pour IDP LDAP.
- `lab-02-idp-keycloak-oidc.md` : lab détaillé pour Keycloak OIDC.
- `lab-03-group-sync.md` : skeleton Group Sync.
- `lab-04-rbac-kubeconfig.md` : skeleton RBAC + kubeconfig.

Lab déjà détaillé : `lab-02-idp-keycloak-oidc.md` :

- Ajout d’un IDP OpenID dans la ressource `oauth/cluster`.
- Configuration des claims `preferred_username`, `name`, `email`, `groups`.
- Création de secrets pour `clientSecret` et `CA` de Keycloak.
- Attribution du rôle `cluster-admin` au groupe Keycloak `ocp-admins`.
- Vérification du login et des droits via `oc whoami`, `oc get nodes`.

---

### 3.3. Bloc 02 – OADP : Sauvegarde et restauration

Dossier : `02-oadp-backup-restore/`

Objectifs :

- Installer l’operator **OADP** dans `openshift-adp`.
- Déclarer un backend S3 (MinIO, S3, etc.).
- Créer une ressource `DataProtectionApplication` (DPA).
- Sauvegarder / restaurer un namespace applicatif avec PVC.
- Planifier des backups / snapshots CSI.

Fichiers principaux :

- `README.md` : description des objectifs.
- `lab-01-install-oadp-operator.md` : lab détaillé.
- `lab-02-backup-namespace-stateful.md` : skeleton backup namespace.
- `lab-03-restore-namespace.md` : skeleton restore.
- `lab-04-schedules-snapshots.md` : skeleton schedules + snapshots.

Points clés du lab 02-01 :

- Création de `OperatorGroup` et `Subscription` pour OADP.
- Secret `cloud-credentials` avec `aws_access_key_id` / `aws_secret_access_key`.
- Ressource `DataProtectionApplication` `oadp-s3` avec :
  - `backupLocations` (bucket, prefix, s3Url, s3ForcePathStyle).
  - plugins par défaut (openshift, aws, csi).

---

### 3.4. Bloc 03 – Cluster partitioning

Dossier : `03-cluster-partitioning/`

Objectifs :

- Utiliser des labels de nœuds (`node-role`, labels custom) pour orienter les workloads.
- Comprendre et manipuler les `MachineConfigPool` (MCP).
- Dédier certains nœuds à des usages (infra, logging, workloads critiques, etc.).

Labs (squelettes à compléter) :

- `lab-01-node-labels-node-selector.md` :
  - Ajouter des labels aux nodes.
  - Utiliser `nodeSelector` sur des Deployments.
- `lab-02-machineconfigpools.md` :
  - Créer/adapter un MCP.
  - Vérifier la reconcialiation des nœuds.
- `lab-03-dedicated-infra-nodes.md` :
  - Isoler des nœuds infra.
  - Déplacer certains pods système/ingress/logging sur ces nœuds.

---

### 3.5. Bloc 04 – Scheduling avancé

Dossier : `04-advanced-scheduling/`

Objectifs :

- Utiliser **taints/tolerations** pour contrôler le placement.
- Définir des **PodDisruptionBudget (PDB)** pour garantir la disponibilité minimale.
- Configurer **affinity / anti-affinity** et éventuellement `topologySpreadConstraints`.
- Définir des defaults de projet (tolerations, LimitRange, ResourceQuota).

Labs (squelettes) :

- `lab-01-taints-tolerations.md` : ajout de taints sur certains nœuds, tolerations côté pod.
- `lab-02-pdb-resilience.md` : création de PDB et tests de `oc drain`.
- `lab-03-affinity-anti-affinity.md` : distribution des pods sur plusieurs zones/nœuds.
- `lab-04-project-defaults.md` : configuration de LimitRange, ResourceQuota, tolerations par défaut.

---

### 3.6. Bloc 05 – GitOps avec OpenShift GitOps

Dossier : `05-gitops-openshift/`

Objectifs :

- Installer l’operator **Red Hat OpenShift GitOps** (Argo CD).
- Gérer un namespace infra et un namespace applicatif via des CR `Application`.
- Mettre en place un pattern simple d’App-of-Apps.

Fichiers principaux :

- `README.md` : synthèse.
- `lab-01-install-openshift-gitops.md` : lab détaillé (Operator + accès Argo CD).
- `lab-02-gitops-infra-namespace.md` : skeleton.
- `lab-03-gitops-app-namespace.md` : skeleton.
- `lab-04-app-of-apps.md` : skeleton App-of-Apps.

Lab 05-01 :

- Création d’un `OperatorGroup` et `Subscription` pour GitOps.
- Vérification du namespace `openshift-gitops`.
- Récupération du mot de passe admin via secret `openshift-gitops-cluster`.
- Port-forward vers `svc/openshift-gitops-server` et login Argo CD.

---

### 3.7. Bloc 06 – Monitoring & métriques

Dossier : `06-monitoring-metrics/`

Objectifs :

- Exploiter la stack monitoring native (Prometheus / Alertmanager / Grafana).
- Diagnostiquer :
  - un problème de performance applicative (latence, erreurs HTTP),
  - un problème cluster (ressources nodes, etcd, API server).
- Gérer le routing des alertes et les silences.

Labs (squelettes) :

- `lab-01-troubleshoot-app-metrics.md` :
  - analyser les métriques d’une app (latence, erreurs).
  - corréler avec des pics de charge ou pannes.
- `lab-02-troubleshoot-cluster-metrics.md` :
  - surveiller les ressources nodes, etcd, control plane.
- `lab-03-alerts-silences.md` :
  - gérer les routes d’alertes et les silences dans Alertmanager.

---

### 3.8. Bloc 07 – Logging centralisé (Vector + Loki)

Dossier : `07-logging-loki-vector/`

Objectifs :

- Installer l’operator de logging (en fonction de la version d’OCP).
- Mettre en place un pipeline Vector vers Loki.
- Activer un Event Router.
- Définir une politique de rétention.

Labs (squelettes) :

- `lab-01-install-logging-operator.md` : installation de l’operator.
- `lab-02-forward-logs-loki.md` : configuration d’un pipeline vers Loki.
- `lab-03-event-router.md` : activation des logs d’événements Kubernetes.
- `lab-04-log-retention.md` : stratégie de rétention (durée, taille).

---

### 3.9. Bloc 08 – Exam scenarios

Dossier : `08-exam-scenarios/`

Objectifs :

- Rejouer des scénarios **multi-compétences** en mode examen blanc.
- Entraîner la gestion du temps (2–3 h par scénario).

Fichiers :

- `README.md` : explication des règles.
- `scenario-01-full-stack-dr.md` : scénario détaillé Auth + OADP + GitOps.
- `scenario-02-cluster-partitioning.md` : skeleton.
- `scenario-03-gitops-end-to-end.md` : skeleton.
- `scenario-04-observability-incident.md` : skeleton.

Exemple scénario 01 :

- Mettre en place l’auth OIDC via Keycloak.
- Installer OADP + DPA vers MinIO.
- Déployer une app stateful en GitOps.
- Backup + suppression + restore du namespace applicatif.
- Durée cible : 3 h.

---

## 4. Diagrams et visuels (dossier `diagrams/`)

But : disposer de schémas visuels pour mémoriser les flux et l’architecture.

Descriptions de base (à transformer en vrais diagrammes) :

1. **`ex380-overview`** :
   - Cluster OCP 4.14 au centre.
   - À la périphérie : Auth, OADP, GitOps, Monitoring, Logging.
   - Flèches montrant les interactions (IDP, S3, Git, systèmes externes).

2. **`ex380-auth-flows`** :
   - Utilisateur → navigateur → OAuth OCP → IDP Keycloak/LDAP → retour token → API/console.
   - Détail des étapes d’auth.

3. **`ex380-oadp-dr`** :
   - Namespaces applicatifs + PVC → OADP/Velero → backend S3/MinIO.
   - Flèche inverse pour la restauration.

4. **`ex380-gitops-flow`** :
   - Dev → push Git → repo Git.
   - Argo CD → pull depuis Git → apply sur cluster.

5. **`ex380-logging-monitoring`** :
   - Apps/pods → logs → Vector → Loki.
   - Apps/pods → metrics → Prometheus → Alertmanager/Grafana.

---

## 5. Intégration Manus / agents IA (dossier `manus/`)

Dossier : `manus/`

- `prompt-ex380-depot.md` :
  - Prompt dédié pour déléguer à un agent (Manus ou autre IA) :
    - complétion de tous les labs skeleton,
    - enrichissement des scénarios,
    - génération de descriptions de diagrammes encore plus détaillées.

Usage typique :

1. Ouvrir le fichier `prompt-ex380-depot.md`.
2. Le coller dans Manus (ou un autre orchestrateur d’agents IA).
3. Récupérer en sortie des blocs `=== FILE: chemin/...` avec du markdown.
4. Coller ces blocs directement dans le dépôt.

---

## 6. Roadmap de travail suggérée

### 6.1. Phase 1 – Réveil musculaire (1–2 jours)

- Dossier `00-prereq-refresh/`.
- Objectif : être fluide sur les opérations EX280 de base (projets, apps, routes, config, stockage).

### 6.2. Phase 2 – Auth + OADP (3–5 jours)

- `01-auth-identities/` :
  - Faire en priorité `lab-02-idp-keycloak-oidc`.
  - Compléter les skeletons LDAP, Group Sync, RBAC/kubeconfig.
- `02-oadp-backup-restore/` :
  - Faire `lab-01-install-oadp-operator`.
  - Écrire puis exécuter les labs de backup/restore.

### 6.3. Phase 3 – Partitioning + Scheduling (3–5 jours)

- `03-cluster-partitioning/` + `04-advanced-scheduling/`.
- Objectif :
  - Labels de nœuds, MCP, nœuds infra.
  - Taints/tolerations, PDB, (anti-)affinity.
  - Defaults de projet.

### 6.4. Phase 4 – GitOps (3–4 jours)

- `05-gitops-openshift/`.
- Déployer :
  - un namespace infra via GitOps,
  - un namespace applicatif via GitOps,
  - une App-of-Apps simple.

### 6.5. Phase 5 – Observabilité (3–5 jours)

- `06-monitoring-metrics/` + `07-logging-loki-vector/`.
- Objectif :
  - identifier la cause d’un incident via métriques + logs,
  - jouer avec les alertes / silences.

### 6.6. Phase 6 – Exam mode (1–2 semaines)

- `08-exam-scenarios/`.
- Enchaîner plusieurs scénarios en conditions d’examen (2–3 h, pas d’Internet).

---

## 7. To‑do list du dépôt

Liste de tâches pour compléter et enrichir le dépôt :

- [ ] Compléter tous les labs skeletons (`lab-*.md`) en suivant `LAB_TEMPLATE.md`.
- [ ] Ajouter des exemples YAML concrets (CR, Deployments, PDB, etc.).
- [ ] Générer et versionner les diagrammes (Draw.io, PNG, ou Mermaid).
- [ ] Ajouter un ou deux scripts utilitaires (Bash) pour automatiser certaines vérifications.
- [ ] Écrire un ou deux “cheatsheets” (RBAC, OADP, GitOps, taints/tolerations).
- [ ] Ajouter une section “FAQ EX380” dans le `README.md` racine.

Ce canvas sert de **guide maître** pour piloter la préparation EX380 :
- vue d’ensemble,
- structure du dépôt,
- détail des blocs pédagogiques,
- roadmap de travail,
- tâches à compléter au fil du temps.

