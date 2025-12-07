# EX280 – Semaine 7 & 8 – Bootcamp final + Pré‑exam

## Objectif global S7–S8

Être capable, **en conditions d’examen**, d’enchaîner des scénarios EX280 (et quelques ponts EX288) en **10–20 min** chacun, avec :

- Réflexes CLI stables (aucune hésitation sur les commandes de base).
- Diagnostic structuré (events → describe → logs → routes/endpoints → quotas/SCC/NetPol).
- Capacité à **prioriser** : réparer la panne qui bloque la prod avant le “cosmétique”.
- 2 examens blancs complets réalisés en fin de parcours.

---

# Semaine 7 – Bootcamp EX280 (micro‑scénarios)

## Organisation

- **J1–J3** : 4–6 micro‑scénarios/jour (10–20 min chacun).
- **J4–J5** : scénarios longs (2–3 h) avec enchaînement de tâches.
- **J6–J7** : focus sur les faiblesses + 1 scénario “build from Git” (pont EX288).

Chaque micro‑scénario doit avoir :

1. **Énoncé court** (1 ou 2 phrases).
2. **Objectif** clair.
3. **Critères de réussite** (ce que tu dois vérifier/montrer).

---

## Brique 1 – Scénarios “Users/Groups/RBAC”

### Exemple de scénario

> Créer un user développeur pour un projet, l’ajouter à un groupe, et lui donner les droits pour déployer dans un namespace donné.

### Commandes et réflexes

```bash
# Vérifier où tu es
oc project

# Vérifier les utilisateurs (HTPasswd / cluster)
oc get users
oc get groups

# Créer un groupe (si besoin)
oc adm groups new dev-ex280

# Ajouter un user dans un groupe
oc adm groups add-users dev-ex280 zidane

# Donner des droits dans le namespace ex280-lab02
oc adm policy add-role-to-user edit zidane -n ex280-lab02
# ou via groupe
oc adm policy add-role-to-group edit dev-ex280 -n ex280-lab02

# Vérification RBAC
och auth can-i create deployment -n ex280-lab02 --as=zidane
oc auth can-i get pods -n ex280-lab02 --as=zidane
```

### À retenir EX280

- `oc adm policy add-role-to-user` / `add-role-to-group` sont les réflexes pour RBAC.
- `oc auth can-i` pour vérifier les droits, avec `--as=` si besoin de simuler un user.

---

## Brique 2 – Scénarios “SCC / ServiceAccount”

### Exemple de scénario

> Un pod ne démarre pas à cause de la SCC. Diagnostiquer puis corriger proprement (sans donner plus de droits que nécessaire).

### Commandes et réflexes

```bash
# Voir les événements du namespace
oc get events --sort-by=.lastTimestamp | tail -n 20

# Voir pourquoi un pod est bloqué
oc describe pod <pod>

# Lister les SCC
oc get scc
oc describe scc restricted

# Lister les SA du projet
oc get sa

# Associer une SCC à un SA
oc adm policy add-scc-to-user anyuid -z httpd-sa -n ex280-lab02
# (ou utiliser une SCC plus restrictive fournie par l’énoncé)

# Vérifier la SA utilisée par un pod
oc get deploy httpd-demo -o yaml | sed -n '/serviceAccountName:/p'
```

### À retenir EX280

- Lire le message d’erreur dans `oc describe pod` (section **Events**).
- Savoir attacher une SCC à une SA via `oc adm policy add-scc-to-user`.
- Ne pas utiliser systématiquement `anyuid` en prod réelle, mais en EX280 tu dois maîtriser la mécanique.

---

## Brique 3 – Scénarios “Quotas / LimitRange”

### Exemple de scénario

> Un développeur ne peut plus créer de pods dans un projet. Tu dois diagnostiquer et adapter le quota.

### Commandes et réflexes

```bash
# Vérifier les ResourceQuota et LimitRange
och get resourcequota
oc describe resourcequota

oc get limitrange
oc describe limitrange

# Essayer de créer un pod simple (pour reproduire l’erreur)
oc run test-quota --image=registry.access.redhat.com/ubi8/httpd-24 --restart=Never

# Lire l’erreur
# Error from server (Forbidden): exceeded quota: ...

# Adapter le quota (YAML)
oc edit resourcequota compute-quota

# Vérifier les valeurs Used/Hard
oc describe resourcequota compute-quota
```

### À retenir EX280

- Le message **exceeded quota** est très typique → regarder `ResourceQuota`.
- Adapter proprement le YAML (et pas tout supprimer).

---

## Brique 4 – Scénarios “NetworkPolicy”

### Exemple de scénario

> Une appli ne peut plus appeler un service dans un autre namespace après mise en place de NetPol. Trouver et corriger la politique.

### Commandes et réflexes

```bash
# Voir les NetPol dans le namespace
oc get networkpolicy
oc describe networkpolicy <nom>

# Repérer l’existence d’un deny-all
och get networkpolicy
# Exemple : default-deny-all

# Tester la connectivité depuis un pod
oc exec -it <pod> -- curl -sS http://service:8080 || echo "KO"

# Créer une NetPol d’ouverture ciblée
cat << 'EOF' > allow-httpd-from-namespace.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-httpd-from-same-namespace
spec:
  podSelector:
    matchLabels:
      app: httpd-demo
  ingress:
  - from:
    - podSelector: {}
    ports:
    - protocol: TCP
      port: 8080
EOF

oc apply -f allow-httpd-from-namespace.yaml
```

### À retenir EX280

- Penser **NetPol** dès que “ça ping mais ça curl pas”.
- Combiner `oc describe networkpolicy` + tests `curl`.

---

## Brique 5 – Scénarios “Routes / TLS / Services”

### Exemple de scénario

> Une route renvoie 503 ou ne résout pas. Diagnostiquer, corriger soit la route, soit le service, soit les endpoints.

### Commandes et réflexes

```bash
# Routes
oc get route
oc describe route <nom>

# Services
oc get svc
oc describe svc <nom>

# Endpoints
oc get endpoints
oc get endpoints <nom> -o yaml

# Vérifier que les labels du Service matchent ceux des pods
oc get pods --show-labels
oc describe svc httpd-demo | sed -n '/Selector:/,/Endpoints:/p'

# TLS (edge typiquement)
oc create route edge httpd-tls \
  --service=httpd-demo \
  --cert=cert.crt --key=cert.key --ca-cert=ca.crt
```

### À retenir EX280

- Un 503 sur route OCP = souvent **pas d’endpoint** ou **mauvais selector**.
- Lire la section Selector/Endpoints du Service.

---

## Brique 6 – Scénarios “PV/PVC + StatefulSet”

### Exemple de scénario

> Une base simple (statefulset) ne démarre pas parce que le PVC est Pending. Tu dois diagnostiquer et corriger.

### Commandes et réflexes

```bash
# Voir PV/PVC
oc get pv
oc get pvc
oc describe pvc pvc-httpd-data

# Vérifier la StorageClass
oc get storageclass

# Débugger un PVC Pending
oc describe pvc <nom>
# Regarder les events liés au provisioner

# StatefulSet
oc get statefulset
oc describe statefulset <nom>

# Vérifier que le volumeClaimTemplates pointe sur une StorageClass existante
oc get statefulset <nom> -o yaml | sed -n '/volumeClaimTemplates:/,/containers:/p'
```

### À retenir EX280

- `STATUS=Pending` sur PVC = problème StorageClass / provisioner.
- `describe pvc` montre les events et la cause (ex : storageclass inconnue).

---

## Brique 7 – Scénarios “Update / Rollback”

### Exemple de scénario

> Une nouvelle version d’image casse l’appli. Tu dois revenir rapidement à la version précédente.

### Commandes et réflexes

```bash
# Voir l’historique du deployment
oc rollout history deployment/httpd-demo

# Déployer une nouvelle image cassée (exemple)
oc set image deployment/httpd-demo httpd-24=registry.../ubi8/httpd-24:badtag
oc rollout status deployment/httpd-demo

# Constat : pods en CrashLoopBackOff
oc get pods
oc describe pod <pod>

# Rollback
oc rollout undo deployment/httpd-demo
oc rollout status deployment/httpd-demo

# Vérifier la version d’image
oc get deploy httpd-demo -o wide
```

### À retenir EX280

- `oc rollout undo` est le réflexe si nouvelle version foireuse.
- Toujours valider avec `oc rollout status`.

---

## Brique 8 – Scénario “Build from Git + template/imagestream” (pont EX288)

### Exemple de scénario

> À partir d’un dépôt Git simple, tu dois créer un BuildConfig, image en registry interne, puis déployer via Deployment/Route.

### Commandes et réflexes

```bash
# Créer un BuildConfig depuis Git
oc new-build https://github.com/tonorg/tonrepo.git \
  --name=myapp \
  --strategy=source

oc get bc
oc start-build myapp --follow

# ImageStream
oc get is

# Déployer depuis l’ImageStream
oc new-app myapp:latest --name=myapp-deploy

# Exposer en service + route
oc expose deployment myapp-deploy --port=8080
oc expose service myapp-deploy

oc get route
```

### À retenir EX288

- `oc new-build` + `oc start-build` + `ImageStream` → pipeline simple source→image→déploiement.
- Tu n’as pas besoin de tout mémoriser, mais de comprendre la chaîne.

---

# Semaine 8 – Pré‑exam & examens blancs

## Organisation

- **J1–J3** : scénarios “du chaos” (3–4 h) couvrant la plupart des briques EX280.
- **J4–J5** : 2 examens blancs complets (3 h chacun).
- **J6** : consolidation / fiches de synthèse.
- **J7** : répétition finale.

---

## Brique 9 – Scénarios “Chaos” (J1–J3)

Principe :

1. On te donne un cluster “cassé” (projet EX280 avec plusieurs pannes mélangées).
2. Tu dois **diagnostiquer** puis **réparer** dans un ordre logique.

Checklist typique à suivre dans chaque scénario :

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

Objectif :

- Utiliser **toujours la même routine** de diagnostic.
- Identifier **rapidement** la ou les causes racine.

---

## Brique 10 – Examens blancs (J4–J5)

### Format suggéré

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

### Stratégie pendant l’examen blanc

1. Lire tout l’énoncé **une fois**.
2. Numéroter les tâches (T1, T2, …).
3. Commencer par les **tâches rapides et sûres** (projets, ConfigMap, Secrets, etc.).
4. Garder le temps pour les tâches à panne (NetPol, SCC, quotas).
5. À chaque tâche, valider avec 1–2 commandes (`oc get`, `oc describe`, `curl` si besoin).

---

## Brique 11 – Consolidation (J6)

### Fiches de synthèse à préparer

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

## Brique 12 – Répétition finale (J7)

### Scénario unique complet

> En 2–3 h, bâtir **de zéro** un projet complet :
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

Objectif :

- Tourner en boucle sur **toute la panoplie EX280**.
- Sortir de J7 avec un **chemin mental** clair pour le jour de l’examen.

---

## Mantra final

1. **Toujours commencer par `oc project`, `oc get pods`, `oc get events`.**
2. Un seul outil de plus en cas de doute : `oc describe`.
3. Ne jamais paniquer sur les messages d’erreur : les lire **en entier**, surtout la fin.
4. Traiter en priorité ce qui empêche l’appli de tourner (pods/route/pvc), ensuite seulement le “beau”.
5. Répéter jusqu’à ce que les commandes sortent **sans réfléchir**.