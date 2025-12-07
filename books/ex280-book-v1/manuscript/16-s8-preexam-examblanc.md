# Semaine 8 - Pré‑exam & examens blancs

## Organisation

- **J1-J3** : scénarios “du chaos” (3-4 h) couvrant la plupart des briques EX280.
- **J4-J5** : 2 examens blancs complets (3 h chacun).
- **J6** : consolidation / fiches de synthèse.
- **J7** : répétition finale.

---

## Brique 9 - Scénarios “Chaos” (J1-J3)

### 9.1. Principe

1. Cluster “cassé” (projet EX280 avec plusieurs pannes mélangées).
2. Tu dois **diagnostiquer** puis **réparer** dans un ordre logique.

### 9.2. Checklist typique par scénario

```bash
# 1. Contexte
oc whoami
oc project

# 2. Pods & événements
oc get pods
oc get events --sort-by=.lastTimestamp | tail -n 20

# 3. Si pod en erreur
oc describe pod <pod>
oc logs <pod> [-c <container>]

# 4. Vérifier Service/Endpoints/Route
oc get svc,route,endpoints
oc describe svc <svc>
oc describe route <route>

# 5. Vérifier quotas/limitranges
oc get resourcequota,limitrange
oc describe resourcequota

# 6. Vérifier NetPol
oc get networkpolicy
oc describe networkpolicy

# 7. Vérifier SCC/SA
oc get sa
oc get scc
oc describe pod <pod> | sed -n '/Service Account:/p'

# 8. Vérifier PV/PVC
oc get pvc,pv
oc describe pvc <pvc>
```

### 9.3. Objectif

- Utiliser **toujours la même routine** de diagnostic.
- Identifier **rapidement** la ou les causes racine.

---

## Brique 10 - Examens blancs (J4-J5)

### 10.1. Format suggéré

- Durée : **3 h**.
- Contenu :
  - Création de projet.
  - Déploiement d’applications.
  - ConfigMap/Secret.
  - Routes/TLS.
  - PV/PVC.
  - RBAC/SCC/NetPol.
  - Quotas/LimitRange.
  - Rollout/rollback.
  - (1 mini‑scénario Operator si possible).

### 10.2. Stratégie pendant l’examen blanc

1. Lire tout l’énoncé **une fois**.
2. Numéroter les tâches (T1, T2, …).
3. Commencer par les **tâches rapides et sûres** (projets, ConfigMap, Secrets, etc.).
4. Garder le temps pour les tâches à panne (NetPol, SCC, quotas).
5. À chaque tâche, valider avec 1-2 commandes (`oc get`, `oc describe`, `curl` si besoin).

---

## Brique 11 - Consolidation (J6)

### 11.1. Fiches de synthèse à préparer

1. **Playbook EX280 ultra‑court** (1 page) avec :
   - Création projet / user / groupe / RBAC.
   - Déploiement appli + Service + Route.
   - ConfigMap / Secret / env.
   - Probes + ressources.
   - PV/PVC.
   - Quotas / LimitRange.
   - SCC / ServiceAccount.
   - NetworkPolicy.
   - Routes/TLS.
   - Rollout / rollback.

2. **Tableau mental** : problème → zone à vérifier

   - Pod `ImagePullBackOff` → image, pull secret, registry.
   - Pod `CrashLoopBackOff` → logs conteneur, config appli.
   - Pod `Pending` → quota, SCC, PVC Pending.
   - Route 503 → service/endpoint.
   - App inaccessible entre namespaces → NetPol.

---

## Brique 12 - Répétition finale (J7)

### 12.1. Scénario unique complet

> En 2-3 h, bâtir **de zéro** un projet complet :
>
> - Projet dédié.
> - User + groupe + RBAC.
> - App déployée (Deployment).
> - Service + Route + (TLS si possible).
> - ConfigMap/Secret.
> - Probes + ressources.
> - PV/PVC pour la persistance.
> - LimitRange + ResourceQuota.
> - NetworkPolicy simple.
> - Incident simulé (quota ou SCC) à corriger.

### 12.2. Objectif

- Tourner en boucle sur **toute la panoplie EX280**.
- Sortir de J7 avec un **chemin mental** clair pour le jour de l’examen.

---

## Mantra final

1. **Toujours commencer par `oc project`, `oc get pods`, `oc get events`.**
2. Un seul outil de plus en cas de doute : `oc describe`.
3. Ne jamais paniquer sur les messages d’erreur : les lire **en entier**, surtout la fin.
4. Traiter en priorité ce qui empêche l’appli de tourner (pods/route/pvc), ensuite seulement le “beau”.
5. Répéter jusqu’à ce que les commandes sortent **sans réfléchir**.






