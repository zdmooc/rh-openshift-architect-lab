# ex280-book-v1

Dépôt de structure (Leanpub-compatible) pour transformer tes notes EX280 en livre pédagogique (fondamentaux → labs → pre-exam).

## Structure
- `manuscript/` : chapitres Markdown
- `resources/diagrams/` : sources Mermaid (.mmd)
- `resources/images/` : images exportées (SVG pour eBook, PNG 300 DPI pour papier)
- `Book.txt` : ordre des chapitres pour Leanpub
- `scripts/` : aides (export Mermaid, checklists)

## Étapes (V1)
1) Remplir `manuscript/10..16-*.md` en collant le contenu depuis tes fichiers sources, sans réécriture.
2) Générer les images depuis Mermaid (SVG recommandé pour eBook).
3) Vérifier lisibilité (taille police, contraste) et homogénéité des légendes.

## Export Mermaid (option)
Voir `scripts/export-mermaid.md`.
