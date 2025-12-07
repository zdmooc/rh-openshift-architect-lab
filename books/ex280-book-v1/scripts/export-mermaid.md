# Export Mermaid vers images

Tu as deux options :

## Option A — Mermaid CLI (mmdc)
1) Installer `@mermaid-js/mermaid-cli` (Node.js requis)
2) Exporter :
   - SVG (recommandé eBook)
   - PNG (papier) et vérifier la lisibilité

Exemples (à adapter) :
```bash
mmdc -i resources/diagrams/fig-01-overview.mmd -o resources/images/fig-01-overview.svg
mmdc -i resources/diagrams/fig-16-troubleshooting-routine.mmd -o resources/images/fig-16-troubleshooting-routine.svg
```

## Option B — Export via éditeur Mermaid en ligne
1) Ouvrir le `.mmd` et coller dans un éditeur Mermaid
2) Export en SVG
3) Placer le fichier dans `resources/images/` avec le même nom
