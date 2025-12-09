# EX280 – OpenShift Administrator (labs)

## Objectif

Couvrir les compétences pratiques d’un **OpenShift Administrator** en mode 100 % CLI,
avec une séquence de labs courts, vérifiables et rejouables.

## Structure

- `labs/` : labs numérotés **Lab00 → Lab14** (chemin de pratique “examen”).
- `checklists/` : checklists d’objectifs EX280.
- Références associées :
  - Book EX280 : `books/ex280-book-v1` (cours, semaines S1→S8, chapitres f0→f6).
  - Drills intensifs : dépôt `EX280-Ultimate-Guide` (scénarios longs, révisions).

---

## Labs (ordre recommandé)

1. `labs/lab00-env-and-repos.md`  
   Bootstrap CRC + `oc` + repo Git + pod de test.

2. `labs/lab01-projects-and-access.md`  
   Projets, contexte `oc`, premiers pods.

3. `labs/lab02-deploy-expose-config.md`  
   Deployment, Service, Route, ConfigMap, Secret.

4. `labs/lab03-pvc-probes-resources.md`  
   PVC, Deployment avec volume, probes, requests/limits (+ option PV manuel).

5. `labs/lab04-users-rbac-idp.md`  
   Users, groups, RBAC projet (+ option IdP `htpasswd` sur CRC).

6. `labs/lab05-serviceaccounts-scc-secrets.md`  
   ServiceAccounts, Secrets liés, SCC, pod avec SA dédiée.

7. `labs/lab06-networking-routes-tls.md`  
   Routes HTTP, certificat auto-signé, route TLS edge.

8. `labs/lab07-networkpolicies.md`  
   NetworkPolicy : autoriser un client à joindre un server, diagnostic.

9. `labs/lab08-quotas-limits-scaling.md`  
   ResourceQuota, LimitRange, scaling manuel + HPA (autoscale).

10. `labs/lab09-logging-events-troubleshooting.md`  
    Casser un déploiement, diagnostiquer via logs/events/describe, corriger.

11. `labs/lab10-templates.md`  
    Template applicatif + (option) `projectRequestTemplate` pour les nouveaux projets.

12. `labs/lab11-helm-kustomize.md`  
    Release Helm simple + overlay Kustomize appliqué sur un namespace.

13. `labs/lab12-operators-olm.md`  
    OperatorGroup, Subscription, CSV, compréhension du cycle OLM.

14. `labs/lab13-jobs-cronjobs.md`  
    Job + CronJob utilisant une ServiceAccount dédiée.

15. `labs/lab14-mini-exam-scenario.md`  
    Mini “exam blanc” 90 min : projet unique avec PVC, probes, quotas, ConfigMap/Secret,
    Service/Route et troubleshooting final.

---

## Références

- **Book EX280**  
  - Chemin : `books/ex280-book-v1`  
  - Rôle : explications détaillées, cours, semaines S1→S8, rappels théoriques.

- **EX280-Ultimate-Guide**  
  - Rôle : banque de scénarios plus longs et de drills intensifs.  
  - Utilisation : uniquement pour compléter / renforcer les labs, pas comme chemin principal.

---

## Suivi de progression

1. Utiliser la checklist :
   - Fichier : `checklists/ex280-objectives-checklist.md`
   - Cocher les objectifs au fur et à mesure (par thème : projets, RBAC, stockage, réseau, etc.).

2. Tracer les labs rejoués :
   - En tête de chaque fichier de lab, ajouter par exemple :
     - `Dernière réussite : 2025-12-09 (en < 45 min)`  
   - Ou maintenir un petit tableau dans un fichier perso (dates + temps + remarques).

3. Mode “exam” :
   - Une fois tous les labs maîtrisés individuellement, rejouer :
     - Lab08 (quotas/limits)  
     - Lab03 (PVC/probes)  
     - Lab02 (deploy/service/route/config)  
     - puis Lab14 (mini scénario) en conditions chronométrées.
