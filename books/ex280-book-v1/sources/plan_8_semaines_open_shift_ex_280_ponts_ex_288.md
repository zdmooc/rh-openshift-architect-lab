# Plan global — 8 semaines (EX280 + ponts EX288)

## Chiffrage
- **Durée totale** : 8 semaines = **56 jours**
- **Rythme** : **6 h/jour** en **3 blocs de 2 h**
- **Total** : **≈ 336 h**

## Cadre quotidien (stable)
- **Bloc A (2 h)** : Exécution “build/deploy” (résultat visible)
- **Bloc B (2 h)** : Admin/sécurité/réseau (RBAC/SCC/NetPol/quotas/routes)
- **Bloc C (2 h)** : Drills chronométrés + notes “playbook” + débrief incident

### Règles de progression
- Tout exercice doit être faisable **CLI-first**.
- Chaque semaine : au moins **1 rebuild from scratch**.
- Chaque semaine : au moins **1 scénario chronométré** (60–180 min selon la semaine).
- Objectif Bootcamp : **scénarios en 10–20 min**.

---

# Semaine 1 — Fondations OCP/K8s (DO180 “maison”) + premiers réflexes EX288
**Objectif fin S1** : déployer une app stateless via CLI + config + route + probes + limits.

- **J1–J2** :
  - Projets/namespaces
  - Pods, YAML de base
  - Logs/events, labels/selectors
  - Affichages rapides (wide, jsonpath, tri/filtre)

- **J3** :
  - Deployments/ReplicaSets
  - Services
  - Routes HTTP (exposition simple)

- **J4** :
  - ConfigMaps/Secrets
  - Injection env/volumes

- **J5** :
  - Probes (readiness/liveness/startup)
  - Requests/limits
  - Scaling (replicas)

- **J6** : **Rebuild** complet “from scratch” (objectif < 90 min)
- **J7** : **Mini-exam 1 h** : scénario unique bout-en-bout + checklist

---

# Semaine 2 — Batch + stockage + TLS “simple” + démarrage EX288 (build/registry)
**Objectif fin S2** : app + PVC + Job/CronJob + Route TLS basique + config injectée, en < 1 h.

- **J1–J2** :
  - Jobs (ponctuel) + vérifs (status, logs, retries)
  - CronJobs (planification) + historique
  - Job qui écrit dans un volume

- **J3** :
  - PV/PVC
  - StorageClass
  - StatefulSet simple
  - Debug PVC Pending

- **J4** :
  - Routes avancées
  - TLS basique (certificat simple) + route sécurisée

- **J5 (Pont EX288)** :
  - Registry interne
  - Bases Build/BuildConfig
  - Publier une image dans la registry

- **J6** : Rebuild complet + chronométrage
- **J7** : Mini-exam 2 h

---

# Semaine 3 — Updates/rollbacks + ImageStreams/triggers + Kustomize + templates
**Objectif fin S3** : maîtriser “image → deploy → update → rollback” + overlays env.

- **J1** :
  - Rollout status / pause / resume
  - Rollback
  - Tags vs digests (bases)

- **J2 (Pont EX280↔EX288)** :
  - **ImageStreams**
  - **Triggers** (auto-update)

- **J3** :
  - **Kustomize** overlays (dev/stage)
  - Labels/annotations pour séparation

- **J4 (Pont EX288)** :
  - **Templates** (paramètres)
  - `oc process` + déploiement

- **J5** :
  - Déployer “depuis images / templates / Helm (basique)”

- **J6** : Rebuild + drill “update + rollback” (< 15–20 min)
- **J7** : Scénario long (2–3 h)

---

# Semaine 4 — Identité & multi-tenancy (cœur EX280) + Helm côté dev
**Objectif fin S4** : users/groups + RBAC + quotas + project templates + SCC.

- **J1** :
  - **HTPasswd IdP**
  - Créer/supprimer users
  - Changer mots de passe

- **J2** :
  - **Groups**
  - RBAC : Role/RoleBinding
  - `oc auth can-i` (réflexe)

- **J3** :
  - **ClusterResourceQuota**
  - ResourceQuota/LimitRange
  - Démontrer échec/réussite selon quotas

- **J4** :
  - **Project templates** (projet “prêt à l’emploi”)
  - Standardiser création de projets

- **J5 (Pont EX288)** :
  - **Helm** : install/upgrade/rollback
  - values par environnement

- **J6** : 4 scénarios “RBAC/quota/template” (30–45 min chacun)
- **J7** : Mini-exam “sécurité + multi-tenancy”

---

# Semaine 5 — Sécurité applicative + réseau (Routes/TLS + NetworkPolicies) + non-HTTP
**Objectif fin S5** : corriger SCC/RBAC/NetPol/Route/TLS sans tâtonner.

- **J1–J2** :
  - ServiceAccounts
  - SCC : diagnostiquer un pod bloqué
  - Ajuster SA/SCC proprement

- **J3–J4** :
  - NetworkPolicies avancées
  - Deny-all → ouvertures ciblées (namespace, labels)
  - Tests : curl, DNS

- **J5** :
  - Routes/TLS en pratique (edge/passthrough/re-encrypt si dispo)
  - **Exposition non-HTTP** (en plus des routes)

- **J6** : “Incident day” : 5 pannes (quota, SCC, NetPol, route, image pull)
- **J7** : Scénario complet chronométré (2–3 h)

---

# Semaine 6 — Operators + troubleshooting structuré + Tekton (EX288 utile)
**Objectif fin S6** : installer/supprimer un operator + résoudre pannes classiques + pipeline simple.

- **J1** :
  - OperatorHub/OLM : install + delete
  - Vérifs (pods/services/events)

- **J2** :
  - CR (Custom Resource)
  - Vérifier que l’operator déploie la ressource attendue

- **J3–J4** :
  - Playbooks troubleshooting :
    - image introuvable / pull secrets / registry
    - quota dépassé
    - SCC trop restrictive
    - NetworkPolicy qui bloque
    - route/TLS mal configurée
  - Réflexes : events → describe → logs → endpoints/routes → policies

- **J5 (Pont EX288)** :
  - **OpenShift Pipelines (Tekton)** : Task/PipelineRun
  - Déclenchement manuel + lecture logs

- **J6–J7** : “Mini-EX280” 3 h + débrief 2 h

---

# Semaine 7 — Bootcamp EX280 (avec rappels EX288 sur builds/templates)
**Objectif fin S7** : enchaîner des tâches EX280 en 10–20 min.

- **J1–J3** :
  - 4–6 micro-scénarios/jour (10–20 min chacun) :
    - users/groups + RBAC
    - SCC/SA
    - quotas/limitranges
    - NetPol
    - routes/TLS
    - PV/PVC
    - rollbacks
    - imagestreams/triggers

- **J4–J5** :
  - Examens blancs 2–3 h (conditions réelles)

- **J6–J7** :
  - Ciblage faiblesses
  - Refaire uniquement les scénarios lents
  - 1 scénario “build from Git + template/imagestream” (pont EX288)

---

# Semaine 8 — Pré-exam (stabilité + vitesse)
**Objectif fin S8** : 2 examens blancs complets + “chaos exam” + playbook final.

- **J1–J3** :
  - Examens “du chaos” (3–4 h) couvrant :
    - projets
    - apps
    - users/groups
    - RBAC/SCC
    - réseau + NetPol
    - routes/TLS
    - stockage
    - quotas
    - update/rollback + imagestreams
    - (1 point operator si possible)

- **J4–J5** :
  - 2 examens blancs complets (3 h)
  - Objectif : chaque scénario typique < 15–20 min

- **J6** :
  - Relecture rapide objectifs + checklist perso
  - Consolidation “documentation mentale”

- **J7** :
  - Répétition finale : scénario unique complet en conditions réelles

---

## Où EX288 s’interface le mieux (sans alourdir)
- **S2** : registry + Build/BuildConfig
- **S3** : ImageStreams + triggers + Templates + Kustomize
- **S4** : Helm
- **S6** : Tekton/Pipelines

## Livrables finaux (jour J)
- 1 **Checklist** EX280 (objectifs → commandes → vérifs)
- 1 **Playbook ultra-court** :
  - Déployer une app
  - Exposer une route + TLS
  - Ajouter ConfigMap/Secret
  - Ajouter PVC
  - Fix permissions (RBAC/SCC/SA)
  - Fix réseau (NetPol/route)
  - Fix image pull / registry
  - Rollback + imagestream trigger
