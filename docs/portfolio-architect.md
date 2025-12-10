# Portfolio Architecte OpenShift – rh-openshift-architect-lab

## 1. Contexte du lab

Ce dépôt `rh-openshift-architect-lab` sert de support complet pour :

* la préparation aux certifications OpenShift (EX280, EX288, EX370, EX380, EX480, EX482) ;
* la démonstration de compétences d’**architecte OpenShift / Kubernetes** :

  * design de plateforme,
  * GitOps,
  * sécurité,
  * observabilité,
  * multi-cluster.

Le cluster de lab est basé sur OpenShift 4.x (ex : CRC), mais la logique s’applique à des clusters OCP on-prem ou managés (ARO, ROSA, etc.).

## 2. Axes principaux d’architecture démontrés

### 2.1. Architecture globale de plateforme

Référence : `docs/ARCHITECTURE.md`.

* Définition d’une architecture OpenShift de lab structurée :

  * séparation plateformes (`openshift-*`, `kube-*`, `openshift-gitops`) / apps (`ex280-*`, `sandbox-*`),
  * description des briques (contrôle, compute, réseau, stockage).
* Vue d’ensemble logique avec flux utilisateurs → routes → services → pods → stockage.

### 2.2. GitOps de la plateforme

Référence : `docs/gitops-platform.md`, `platform/gitops/`.

* Modèle GitOps pour la configuration de la plateforme :

  * séparation `argocd-apps/` (Applications/AppProjects Argo CD) et `cluster-config/` (manifests bruts),
  * périmètre GitOps clairement défini (namespaces, quotas, RBAC, NetworkPolicy, operators non-core).
* Préparation d’un modèle **app-of-apps** :

  * `platform-root` → sous-apps (`platform-namespaces`, `platform-quotas`, `platform-rbac`, etc.).

### 2.3. Observabilité et SRE

Référence : `docs/observability-sre.md`, `platform/observability/`.

* Définition de la stack metrics/logs :

  * Prometheus / Alertmanager / Thanos (metrics),
  * Loki ou ELK/EFK (logs),
  * intégration Grafana / console OCP.
* Approche SRE :

  * quatre signaux d’or (latence, trafic, erreurs, saturation),
  * exemples de SLO (dispo, latence p95, taux d’erreurs 5xx).
* Préparation de manifests :

  * `ServiceMonitor` / `PodMonitor`,
  * dossiers pour dashboards Grafana JSON.

### 2.4. Sécurité (RBAC, réseau, secrets)

Référence : `docs/security-architecture.md`, `platform/security/`.

* Modèle RBAC par rôles :

  * `lab-admin`, `lab-dev`, `lab-ops` pour les namespaces applicatifs,
  * séparation claire plateforme vs lab.
* Segmentation réseau :

  * approche **deny by default** avec NetworkPolicy,
  * modèles `default-deny-all`, `allow-same-namespace`, `allow-egress-dns-http`.
* Gestion des secrets :

  * principes d’utilisation des `Secret`, SealedSecrets, vault externe (future extension),
  * séparation secrets plateforme / applicatifs.

### 2.5. Vision multi-cluster et ACM

Référence : `docs/multi-cluster.md`, `ex480-multicluster/`.

* Projection vers une architecture multi-cluster :

  * cluster `mgmt` (RHACM/OCM, GitOps, observabilité),
  * clusters `build`, `preprod`, `prod`, `edge`.
* Concepts RHACM :

  * `ManagedCluster`, `ClusterSet`, `Placement`, `Policy`.
* Idées de dossiers :

  * `policies/`, `placements/`, `apps/` pour EX480.

## 3. Ce que ce dépôt montre pour un recruteur / client

### 3.1. Compétences techniques

* Maîtrise des concepts clés OpenShift 4.x :

  * projets, routes, operators, stockage, sécurité, monitoring.
* Capacité à structurer :

  * un **GitOps de plateforme** complet (Argo CD),
  * une architecture de lab réaliste et extensible.
* Compréhension des enjeux SRE :

  * métriques, logs, alerting, SLO/SLA.
* Sensibilité sécurité :

  * RBAC, NetworkPolicy, gestion des secrets, PodSecurity/SCC.
* Vision multi-cluster :

  * topologies mgmt + workload, utilisation d’ACM.

### 3.2. Compétences d’architecture et de structuration

* Capacité à **documenter** une architecture (docs/ structurés, mermaid diagrams).
* Capacité à **industrialiser** :

  * séparation claire des responsabilités (docs vs manifests),
  * préparation à l’automatisation complète (GitOps, policies, SRE).
* Approche pédagogique :

  * réutilisation possible pour former d’autres personnes (modules EX280/EX288/EX380/EX480…).

## 4. Exemples de bullets pour le CV

Ces lignes peuvent être réutilisées telles quelles ou adaptées dans un CV / profil LinkedIn :

* "Conception et mise en œuvre d’un lab complet OpenShift 4.x (EX280/EX288/EX370/EX380/EX480) intégrant GitOps, observabilité, sécurité et scénarios multi-cluster."
* "Mise en place d’un modèle GitOps de plateforme basé sur OpenShift GitOps (Argo CD) : structuration des Applications/AppProjects, app-of-apps, et gestion centralisée des namespaces, quotas, RBAC et NetworkPolicy."
* "Définition d’une architecture observabilité/SRE pour OpenShift (Prometheus, Alertmanager, Grafana, stack logs) avec KPIs cluster et SLO applicatifs (latence, disponibilité, taux d’erreurs)."
* "Conception d’un modèle de sécurité OpenShift : RBAC par rôles (lab-admin, lab-dev, lab-ops), segmentation réseau par NetworkPolicy (deny by default) et bonnes pratiques de gestion des secrets."
* "Élaboration d’une vision multi-cluster avec Red Hat Advanced Cluster Management (RHACM) : topologie hub & spoke, policies globales et scénario GitOps multi-cluster."

## 5. Idées d’extensions futures

* Ajouter des manifests concrets dans `platform/gitops/` (Applications Argo CD, cluster-config complet).
* Intégrer une stack Loki ou EFK et fournir des dashboards Grafana prêts à l’emploi.
* Ajouter des exemples de policies RHACM (YAML) dans `ex480-multicluster/`.
* Intégrer un outil de validation de bonnes pratiques (Kyverno/Gatekeeper) pour compléter la démarche sécurité.

Ce fichier doit rester vivant : à chaque évolution majeure du lab (GitOps complet, Loki, ACM réel…), mettre à jour ce portfolio pour refléter ta progression d’architecte OpenShift.
