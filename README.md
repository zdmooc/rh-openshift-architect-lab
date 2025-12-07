# RH OpenShift Architect Lab

Dépôt de travail pour préparer une trajectoire **Red Hat Certified OpenShift Architect** sur 18–24 mois.

Il est organisé par certification et par type de contenus :
- `00-roadmap/` : feuille de route globale, planning, stratégie.
- `common/` : socle commun (cluster de lab, GitOps, conventions).
- `ex280-admin/` : préparation EX280 (OpenShift Administrator).
- `ex288-appdev/` : préparation EX288 (OpenShift Application Developer).
- `ex380-automation-integration/` : préparation EX380 (Automation & Integration).
- `ex370-odf/` : préparation EX370 (OpenShift Data Foundation).
- `ex480-multicluster/` : préparation EX480 (MultiCluster Management).
- `ex482-kafka/` : préparation EX482 (Event‑Driven Development with Kafka).

> Principe : chaque dossier contient un `README.md` + des labs pratiques
> que tu peux exécuter sur ton propre cluster (CRC, OKD, OpenShift managé, etc.).

## Pré‑requis conseillés

- Confort avec Linux (ligne de commande, SSH, sudo).
- Notions Kubernetes (pods, services, deployments, configmaps, secrets).
- Un cluster de lab (single‑node ou petit cluster) :
  - CodeReady Containers / Local OpenShift,
  - ou OKD / Kind + OpenShift GitOps (pour simuler),
  - ou un cluster managé (ROSA, ARO, OCP managé).

## Usage conseillé

1. Lire `00-roadmap/roadmap-24m.md` pour la trajectoire globale.
2. Monter ton cluster de lab avec `common/cluster-lab-setup.md`.
3. Travailler les labs dans l’ordre :
   - `ex280-admin/` → socle admin,
   - `ex288-appdev/` → vision développeur,
   - `ex380-automation-integration/` → CI/CD & GitOps,
   - `ex370-odf/` → stockage et data,
   - `ex480-multicluster/` → multi‑cluster,
   - `ex482-kafka/` → event‑driven & Kafka.
4. Utiliser les checklists pour t’auto‑évaluer avant chaque examen.

Ce dépôt est un squelette structuré : libre à toi de l’enrichir,
d’ajouter tes propres scripts et de l’adapter à ton contexte de mission.

## Books et supports d’exam

Ce dépôt contient aussi des “books” complets de préparation aux exams :

- `books/ex280-book-v1/` : livre + labs pour **EX280 – OpenShift Administrator**.
- `books/ex370-odf-book-v1/` : livre + labs pour **EX370 – OpenShift Data Foundation (ODF)**.

Chaque book contient :
- un dossier `book/` ou `manuscript/` avec les chapitres,
- un dossier `labs/` avec les exercices pratiques,
- éventuellement des scripts (`scripts/`) et des schémas (`images/`).
