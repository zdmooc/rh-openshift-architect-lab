# Feuille de route EX280 – CRC + Repos Git

## 1. Objectif

Reprendre la pratique **EX280** sur **CRC (OpenShift Local 4.19.3)** avec un seul chemin de vérité :

- `EX280-Ultimate-Guide/` : réservoir de labs/scénarios (référence uniquement).
- `rh-openshift-architect-lab/ex280-admin/` : **chemin pratique exam** (Lab00→Lab14).
- `rh-openshift-architect-lab/books/ex280-book-v1/` : **cours + semaines**.

---

## 2. Architecture des dépôts

### 2.1. EX280-Ultimate-Guide (référence)

- Racine : `/c/workspaces/openshift2026/EX280-Ultimate-Guide`
- Rôle : livre complet + 20+ labs + scénarios.
- Usage : trouver des idées de variantes / exercices, **sans recopier en vrac**.

### 2.2. rh-openshift-architect-lab / ex280-admin

- Racine : `/c/workspaces/openshift2026/rh-openshift-architect-lab`
- Dossier : `ex280-admin/`
- Contenu ciblé :
  - `ex280-admin/README.md` : index + ordre recommandé + suivi.
  - `ex280-admin/checklists/` : objectifs EX280 à cocher.
  - `ex280-admin/labs/` : **Lab00 → Lab14** (format court, CLI, verify, cleanup).

### 2.3. rh-openshift-architect-lab / books/ex280-book-v1

- Dossier : `books/ex280-book-v1/`
- Sous-dossiers :
  - `manuscript/` : Semaine 1 → 8, chapitres f0 → f6.
  - `sources/` : notes détaillées (dont `ex_280_semaine_3_rollout_image_streams.md`).
- Rôle : explications, schémas, cours, **pas de labs exam**.

---

## 3. Plan des labs EX280 (00 → 14)

### 3.1. Liste des labs dans `ex280-admin/labs/`

Chaque fichier suit le format : **Objectif, Pré-requis, Steps, Vérifications, Cleanup, Pièges**.

| Lab | Fichier                                      | Thème principal                                          |
|-----|----------------------------------------------|----------------------------------------------------------|
| 00  | `lab00-env-and-repos.md`                     | CRC, oc, kubeadmin, projet test, pod test               |
| 01  | `lab01-projects-and-access.md`               | Projets, contextes oc, vue cluster                       |
| 02  | `lab02-deploy-expose-config.md`              | Deployment, Service, Route, ConfigMap/Secret            |
| 03  | `lab03-pvc-probes-resources.md`              | PVC, ressources CPU/Mem, probes                          |
| 04  | `lab04-users-rbac-idp.md`                    | Users / groups / RBAC projet                             |
| 05  | `lab05-serviceaccounts-scc-secrets.md`       | ServiceAccounts, Secrets, SCC                            |
| 06  | `lab06-networking-routes-tls.md`             | Routes edge/passthrough, TLS self-signed                 |
| 07  | `lab07-networkpolicies.md`                   | NetworkPolicies (isolation / autorisation)               |
| 08  | `lab08-quotas-limits-scaling.md`             | ResourceQuota, LimitRange, scaling                       |
| 09  | `lab09-logging-events-troubleshooting.md`    | Logs, events, describe, troubleshooting                  |
| 10  | `lab10-templates.md`                         | Templates OpenShift                                      |
| 11  | `lab11-helm-kustomize.md`                    | Helm release simple + overlay Kustomize                  |
| 12  | `lab12-operators-olm.md`                     | Operators / OLM (parcours + install simple)              |
| 13  | `lab13-jobs-cronjobs.md`                     | Jobs & CronJobs                                          |
| 14  | `lab14-mini-exam-scenario.md`                | Mini-exam 90 min (scénario complet)                      |

---

## 4. Correspondance Labs ⇄ Book ⇄ Ultimate-Guide

### 4.1. Labs fondations

- **Lab00**
  - Book : Semaine 1 – début (« prise en main cluster / projets »).
  - Ultimate-Guide : prérequis (installation, cluster sain, oc, login).

- **Lab01**
  - Book : Semaine 1 – Brique « Cluster, login, projet ».
  - Ultimate-Guide : labs de gestion de projets / contextes.

- **Lab02**
  - Book : Semaine 1–2 – déploiement simple + exposition.
  - Ultimate-Guide : labs déploiement + services + routes.

- **Lab03**
  - Book : Semaine 2 – stockage + fiabilité applicative.
  - Ultimate-Guide : labs PVC + probes.

### 4.2. Labs sécurité / réseau

- **Lab04–Lab05**
  - Book : Semaine 3 – Users/Groups/RBAC, SCC, SA, Secrets.
  - Ultimate-Guide : labs RBAC, policies, SA/SCC.

- **Lab06–Lab07**
  - Book : Semaine 4 – Routes, TLS, NetworkPolicies.
  - Ultimate-Guide : labs réseau / access control.

### 4.3. Labs quotas / automation / operators

- **Lab08–Lab09**
  - Book : Semaine 5 – quotas, limits, troubleshooting.
  - Ultimate-Guide : labs resource management + debugging.

- **Lab10–Lab12**
  - Book : Semaine 6 – Templates, Helm/Kustomize, Operators.
  - Ultimate-Guide : labs équivalents sur packaging / OLM.

### 4.4. Labs batch / examen

- **Lab13–Lab14**
  - Book : Semaine 7–8 – Jobs/CronJobs, bootcamp, pré-exam.
  - Ultimate-Guide : scénarios synthèse / examens blancs.

---

## 5. Ordre de travail pratique (mode interactif)

### Phase 0 — Hygiène repo

1. Ranger les fichiers « semaine 3 » dans `books/ex280-book-v1/sources/` et `books/DOCS/archive/`.
2. Vérifier `.gitignore` (node_modules, artefacts générés).
3. S’assurer que `ex280-admin/labs/` contient au moins Lab01, Lab02, Lab03.

### Phase 1 — Fondations (S1–S2)

- [ ] Lab00 — CRC + oc + kubeadmin + projet test
- [ ] Lab01 — Projects & Access
- [ ] Lab02 — Deploy & Expose & Config
- [ ] Lab03 — PVC, Probes & Resources

Règle : tant que Lab00–03 ne sont pas fluides **en CLI uniquement**, on ne monte pas plus haut.

### Phase 2 — Sécurité / Réseau (S3–S4)

- [ ] Lab04 — Users, Groups & RBAC
- [ ] Lab05 — SA & SCC & Secrets
- [ ] Lab06 — Routes & TLS
- [ ] Lab07 — NetworkPolicies

### Phase 3 — Quotas, Troubleshooting, Packaging (S5–S6)

- [ ] Lab08 — Quotas, Limits & Scaling
- [ ] Lab09 — Logging & Troubleshooting
- [ ] Lab10 — Templates
- [ ] Lab11 — Helm & Kustomize
- [ ] Lab12 — Operators & OLM

### Phase 4 — Batch + Mini-exam (S7–S8)

- [ ] Lab13 — Jobs & CronJobs
- [ ] Lab14 — Mini Exam Scenario (90 min)

---

## 6. Règles de travail EX280 (mode examen)

1. **CLI-first** : toutes les opérations doivent être faisables en `oc`/`helm`.
2. **Toujours vérifier le namespace** avant de créer/lire une ressource.
3. **Toujours vérifier l’état du cluster** avant de commencer un lab :
   - `oc whoami`
   - `oc get co`
   - `oc get nodes`
4. En cas d’échec :
   - `oc describe` (sur la ressource concernée)
   - `oc logs` (sur le pod concerné)
   - `oc get events --sort-by=.lastTimestamp`

---

## 7. Suivi de progression (à cocher)

### Labs

- [ ] Lab00 — Env & Repos — Date :
- [ ] Lab01 — Projects & Access — Date :
- [ ] Lab02 — Deploy & Expose & Config — Date :
- [ ] Lab03 — PVC, Probes & Resources — Date :
- [ ] Lab04 — Users, Groups & RBAC — Date :
- [ ] Lab05 — ServiceAccounts, SCC & Secrets — Date :
- [ ] Lab06 — Routes & TLS — Date :
- [ ] Lab07 — NetworkPolicies — Date :
- [ ] Lab08 — Quotas, Limits & Scaling — Date :
- [ ] Lab09 — Logging & Troubleshooting — Date :
- [ ] Lab10 — Templates — Date :
- [ ] Lab11 — Helm & Kustomize — Date :
- [ ] Lab12 — Operators & OLM — Date :
- [ ] Lab13 — Jobs & CronJobs — Date :
- [ ] Lab14 — Mini Exam Scenario — Date :

### Boucles de révision

- [ ] Rebuild complet (Lab00→14) réalisé une fois.
- [ ] Rebuild complet réalisé deux fois.
- [ ] Rebuild complet réalisé trois fois (niveau examen).

