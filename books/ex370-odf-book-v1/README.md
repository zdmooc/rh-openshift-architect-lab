# EX370 – Red Hat Certified Specialist in OpenShift Data Foundation

Ce dépôt est un support complet de préparation à l'examen **EX370 – OpenShift Data Foundation**.

Il contient :

- Un **plan de préparation** aligné sur les objectifs officiels Red Hat.
- Un pseudo **ebook** structuré en chapitres dans `book/manuscript/`.
- Des **labs reproductibles** dans `labs/` (YAML, scripts, scénarios).
- Quelques **scripts utilitaires** dans `scripts/` pour vérifier rapidement l'état d'ODF.

## Structure

- `00-meta/` : plan détaillé + checklist des objectifs d'examen.
- `book/manuscript/` : cours théorique et notes structurées en chapitres.
- `images/` : modèles de diagrammes Draw.io (architecture, dataflow).
- `labs/` : TP guidés, utilisables comme base d'exam blanc.
- `scripts/` : scripts bash d'aide (santé ODF, listing StorageClass, nettoyage).

## Usage

1. Cloner le dépôt ou dézipper l'archive localement.
2. Lire les chapitres dans `book/manuscript/` en parallèle des labs correspondants.
3. Exécuter les labs dans l'ordre sur un cluster OpenShift disposant d'ODF.
4. Terminer par le lab `09-mock-exam-ex370` en conditions chronométrées.

Ce dépôt est pensé pour être complété/enrichi : ajoute tes propres captures, retours d'expérience,
variantes de labs et commandes utiles.
