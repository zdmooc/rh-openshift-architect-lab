# EX370 – OpenShift Data Foundation – Canvas complet

## 0. Objectif du canvas

Avoir en **un seul document** tout ce qu’il te faut pour préparer la certification **Red Hat Certified Specialist in OpenShift Data Foundation (EX370)** :

- Vision globale de l’examen et des prérequis.
- Plan de préparation (organisation par semaines / blocs).
- Synthèse des concepts ODF (Ceph, NooBaa, File/Block/Object, snapshots…).
- Pack de **commandes clés** à connaître par cœur.
- Fiches résumées pour chaque **lab** du dépôt `ex370-odf`.
- **Checklist pré‑examen** pour valider que tu es prête.

---

## 1. EX370 – Vue d’ensemble

### 1.1. Rôle de la certification

EX370 valide ta capacité à :

- Administrer le **stockage OpenShift** basé sur **OpenShift Data Foundation (ODF)**.
- Fournir du stockage **bloc, fichier, objet** aux workloads applicatifs.
- Brancher les **services de cluster** (registry, monitoring, logging) sur ODF.
- Gérer la **capacité**, les **quotas**, l’**extension de volumes**.
- Mettre en place **snapshots, clones, backup/restore** simples.
- Exposer de l’**object storage** S3-compatible avec OBC + client S3.
- Assurer la **sécurité** (RBAC, SCC, secrets) autour du stockage.

### 1.2. Pré-requis recommandés

- Niveau Linux ~ **RHCSA (EX200)**.
- Niveau OpenShift ~ **EX280** :
  - `oc` CLI, projets, déploiements, services, routes.
  - RBAC de base, quotas, LimitRange, ConfigMap/Secret.
- Connaissance basique de :
  - Concepts de stockage (disques, PV/PVC, StorageClass).
  - Conteneurs/stateful vs stateless.

### 1.3. Positionnement vs EX280 / EX288

- **EX280** : admin cluster OpenShift (infrastructure, sécurité, réseau, quotas…).
- **EX288** : développeur OpenShift (build, CI/CD, templates, Helm, pipelines).
- **EX370** : **administration du stockage** ODF pour :
  - Workloads applicatifs (PVC File/Block).
  - Services internes (registry, monitoring, logging).
  - Use cases S3 (backups, archives, fichiers applicatifs).

---

## 2. Plan de préparation EX370 (3 semaines)

Organisation compatible avec ton plan EX280/EX288 :

- **Semaine 1** : OCP Refresh + installation ODF (Internal Mode).
- **Semaine 2** : File/Block/NFS + registry + monitoring + Loki + capacité/snapshots.
- **Semaine 3** : Object Storage + RBAC/Sécurité + Exam blanc.

### 2.1. Semaine 1 – OCP Refresh + ODF Internal Mode

**Objectifs fin S1 :**

- Être à l’aise avec `oc` (get/describe/logs/events/apply/edit/exec).
- Comprendre les briques ODF et Ceph.
- Savoir **installer ODF en Internal Mode** et valider la santé du cluster.

**Blocs de travail :**

1. **Bloc A (2 h) – OCP Refresh**
   - Commandes de base `oc`.
   - Déployer une app simple (Deployment + Service + Route).
   - Jouer avec ConfigMap, Secret, logs, exec.

2. **Bloc B (2 h) – Concepts ODF + prérequis infra**
   - Internal vs External Mode.
   - Composants Ceph : MON, OSD, MGR, CephFS, RBD, RGW.
   - NooBaa, Object storage.
   - Disques, labels de nœuds, contraintes CPU/RAM.

3. **Bloc C (2 h) – Installation ODF (Internal Mode)**
   - Labelliser les nœuds de stockage.
   - Installer l’operator ODF.
   - Créer le `StorageCluster`.
   - Vérifier pods, StorageClass, santé ODF.

**Labs associés :**

- `labs/01-ocp-refresh`
- `labs/02-install-odf-internal-mode`

---

### 2.2. Semaine 2 – File/Block/NFS, services de cluster, capacité

**Objectifs fin S2 :**

- Savoir choisir et utiliser **CephFS (File)** vs **RBD (Block)**.
- Savoir brancher registry/monitoring/logging sur ODF.
- Savoir limiter et surveiller la **capacité** (quotas, LimitRange, extension PVC).
- Savoir manipuler **snapshots et clones** de PVC.

**Blocs :**

1. **Bloc A – File/Block/NFS**
   - StorageClass ODF (CephFS / RBD / Object).
   - PVC File (RWX) vs PVC Block (RWO).
   - StorageClass custom (reclaimPolicy, allowVolumeExpansion).

2. **Bloc B – Services de cluster sur ODF**
   - Registry interne → StorageClass ODF.
   - Monitoring (Prometheus/Alertmanager/Thanos) → ODF.
   - LokiStack (logging) → ODF.

3. **Bloc C – Capacité + snapshots/clones**
   - Dashboard ODF, usage des pools.
   - Quotas, LimitRange pour PV/PVC.
   - Extension de PVC.
   - VolumeSnapshot, VolumeSnapshotClass, PVC clone.

**Labs associés :**

- `labs/03-file-block-nfs`
- `labs/04-registry-monitoring-lokistack`
- `labs/05-capacity-and-extensions`
- `labs/06-snapshots-and-clones`

---

### 2.3. Semaine 3 – Object Storage, sécurité, Exam blanc

**Objectifs fin S3 :**

- Être autonome pour l’**object storage** via OBC + S3 client (s3cmd).
- Maîtriser les points **sécurité** : RBAC, SCC, Secrets.
- Avoir fait au moins un **exam blanc 3 h**.

**Blocs :**

1. **Bloc A – Object Storage ODF**
   - NooBaa / RGW / bucket.
   - ObjectBucketClaim (OBC).
   - Endpoint + credentials, utilisation avec s3cmd.

2. **Bloc B – RBAC / SCC / Secrets**
   - Roles/RoleBindings sur PVC, OBC, snapshots.
   - ServiceAccount dédiée aux pods qui montent des volumes.
   - Secrets pour credentials S3.

3. **Bloc C – Exam blanc EX370**
   - Scénario `labs/09-mock-exam-ex370`.
   - 3 h, style examen : aucune doc externe, seulement man/oc explain + YAML fournis.

**Labs associés :**

- `labs/07-object-storage-obc-s3cmd`
- `labs/08-rbac-scc-secrets`
- `labs/09-mock-exam-ex370`

---

## 3. Synthèse des concepts ODF

### 3.1. Internal Mode vs External Mode

- **Internal Mode**
  - ODF gère directement les disques locaux/attachés aux nœuds OpenShift.
  - Ceph est déployé dans le cluster OCP (pods rook-ceph, noobaa…).
  - C’est le mode que tu dois **maîtriser pour l’examen**.

- **External Mode**
  - ODF s’appuie sur un cluster Ceph existant externe.
  - Plus rare pour EX370, à connaître conceptuellement.

### 3.2. Composants Ceph

- **MON** : maintient la carte du cluster, quorum.
- **OSD** : stocke les données sur disque.
- **MGR** : monitoring, métriques, services.
- **CephFS** : système de fichiers distribué (RWX).
- **RBD** : block device (RWO) pour bases de données.
- **RGW** : gateway S3 pour stockage objet.

### 3.3. NooBaa et Object Storage

- NooBaa fournit une couche d’object storage S3-compatible.
- Les **ObjectBucketClaim (OBC)** créent :
  - un **bucket**,
  - un **endpoint** S3,
  - un **pair de credentials** (Secret + ConfigMap).

### 3.4. Intégration avec OpenShift

- ODF expose des **StorageClass** :
  - `ocs-storagecluster-cephfs` : File, RWX.
  - `ocs-storagecluster-ceph-rbd` : Block, RWO.
  - (éventuellement) StorageClass objet.

- Workflows :
  - Dev/ops créent des **PVC** en citant la StorageClass.
  - Le driver CSI ODF crée les **PV** correspondants.
  - Les pods montent les PVC comme volumes.

### 3.5. File vs Block vs Object – quand choisir quoi

- **File (CephFS, RWX)** :
  - Partage de fichiers entre plusieurs pods.
  - Serveurs web, applicatifs,
  - Frameworks qui ont besoin d’un FS partagé.

- **Block (RBD, RWO)** :
  - Bases de données.
  - Workloads avec fort I/O, patterns type disque brut.

- **Object (S3)** :
  - Backups, archives, exports.
  - Fichiers applicatifs accessibles par API S3.

---

## 4. Pack de commandes essentielles

### 4.1. OpenShift de base

```bash
# Contexte
oc whoami
oc config get-contexts
oc project
oc projects

# Cluster
oc get nodes -o wide
oc get clusterversion
oc get clusteroperators

# Ressources dans un namespace
oc get all -n <ns>
oc get pods,svc,route -n <ns>

# Logs / events
oc logs <pod> [-c container] -n <ns>
oc get events -n <ns>

# Debug
oc describe pod/<name> -n <ns>
oc exec -it pod/<name> -n <ns> -- bash

# YAML
oc get <ressource> <nom> -n <ns> -o yaml
oc apply -f fichier.yaml
oc delete -f fichier.yaml

# Doc
oc explain <type>
oc explain <type>.<champ>
```

### 4.2. ODF / Storage

```bash
# Pods ODF
oc get pods -n openshift-storage

# StorageClass
oc get storageclass

# PV / PVC
oc get pv
oc get pvc -A

# Snapshots
oc get volumesnapshotclass
oc get volumesnapshot -A

# OBC
oc get objectbucketclaim -A
oc get obc -A  # selon CRD installée
```

### 4.3. Quotas / LimitRange

```bash
oc get resourcequota -n <ns>
oc get limitrange -n <ns>
```

### 4.4. RBAC

```bash
oc get role,rolebinding -n <ns>
oc get clusterrole,clusterrolebinding
oc describe role <nom> -n <ns>
```

---

## 5. Fiches Labs (dépôt `ex370-odf`)

### 5.1. Lab 01 – OCP Refresh (`labs/01-ocp-refresh`)

**Objectif :** réchauffer les réflexes OpenShift.

- Créer un projet `ex370-lab01`.
- Déployer une app UBI simple.
- Exposer via Service + Route.
- Vérifier events, logs, YAML.

Commandes clés :

- `oc new-project ex370-lab01`
- `oc create deployment hello --image=registry.access.redhat.com/ubi8/ubi`
- `oc expose deployment hello --port=8080`
- `oc expose svc/hello`
- `oc get all -n ex370-lab01`

---

### 5.2. Lab 02 – Installation ODF Internal Mode (`labs/02-install-odf-internal-mode`)

**Objectif :** déployer ODF en Internal Mode.

Étapes :

1. Label nodes de stockage :
   ```bash
   oc label node <node1> cluster.ocs.openshift.io/openshift-storage=''
   ```
2. Appliquer `operator-subscription.yaml` pour ODF.
3. Appliquer `storagecluster-sample.yaml`.
4. Vérifier : pods `openshift-storage`, StorageClass, dashboard ODF.

---

### 5.3. Lab 03 – File / Block (`labs/03-file-block-nfs`)

**Objectif :** manipuler CephFS (File) et RBD (Block).

Fichiers essentiels :

- `pvc-samples.yaml` :
  - `pvc-cephfs-sample` (RWX, CephFS).
  - `pvc-rbd-sample` (RWO, RBD).
- `deployment-cephfs.yaml`, `deployment-rbd.yaml` : pods qui montent les PVC.
- `storageclass-custom.yaml` : StorageClass RBD avec `allowVolumeExpansion: true`.

Points à vérifier :

- Pods montent bien les volumes.
- Écrire un fichier dans `/data` vs `/var/lib/data` et le retrouver après restart.

---

### 5.4. Lab 04 – Registry / Monitoring / Loki (`labs/04-registry-monitoring-lokistack`)

**Objectif :** brancher services de cluster sur ODF.

- Patch de la registry pour utiliser un PVC ODF.
- Config monitoring pour stocker sur ODF.
- Exemple de valeurs LokiStack avec StorageClass ODF.

Pay attention :

- Créer le `ConfigMap` `cluster-monitoring-config` dans `openshift-monitoring`.
- Toujours vérifier `oc get pods -n openshift-monitoring` et `oc get pods -n openshift-logging`.

---

### 5.5. Lab 05 – Capacité & extension (`labs/05-capacity-and-extensions`)

**Objectif :** quotas, LimitRange, extension de PVC.

- `quota-examples.yaml` : ResourceQuota + LimitRange.
- `pvc-expand-example.yaml` : PVC initial (5Gi) avec StorageClass expandable.

Scénario :

1. Créer namespace `ex370-capacity`.
2. Appliquer quotas + LimitRange.
3. Créer le PVC de 5Gi.
4. Étendre à 10Gi.
5. Vérifier dans le pod (ex `df -h`).

---

### 5.6. Lab 06 – Snapshots & clones (`labs/06-snapshots-and-clones`)

**Objectif :** VolumeSnapshot + clone.

- `volumesnapshotclass.yaml` : définit la classe de snapshot.
- `volumesnapshot-example.yaml` : snapshot d’un PVC.
- `cloned-pvc.yaml` : PVC clone basé sur snapshot.

Scénario type :

1. App écrit des données sur PVC.
2. Snapshot du PVC.
3. Corruption volontaire.
4. Création d’un clone à partir du snapshot, re‑montage dans un pod.

---

### 5.7. Lab 07 – Object Storage (OBC & s3cmd) (`labs/07-object-storage-obc-s3cmd`)

**Objectif :** utiliser l’object storage ODF.

- `obc-sample.yaml` : ObjectBucketClaim.
- `s3cmd-example.conf` : template de config s3cmd.

Étapes :

1. Créer namespace `ex370-obc`.
2. Appliquer `obc-sample.yaml`.
3. Récupérer endpoint + credentials dans Secret/ConfigMap.
4. Configurer `s3cmd` avec `s3cmd-example.conf`.
5. Uploader/Downloader des fichiers.

---

### 5.8. Lab 08 – RBAC / SCC / Secrets (`labs/08-rbac-scc-secrets`)

**Objectif :** sécuriser l’accès au stockage.

- `role-storage-admin.yaml` : Role sur PVC/OBC/snapshots.
- `rolebinding-storage-admin.yaml` : attribuer le rôle à un user (`developer`).
- `s3-credentials-secret.yaml` : stocker les creds S3 dans un Secret.

À tester :

- User sans rôle ne peut pas gérer ces ressources.
- User avec rôle peut créer/patcher/supprimer PVC/OBC.

---

### 5.9. Lab 09 – Exam blanc (`labs/09-mock-exam-ex370`)

**Objectif :** simulation d’examen en 3 h.

- Scénario dans `scenario.md`.
- Couvre : ODF santé, apps File/Block, registry/monitoring, snapshot/clone, OBC + S3, RBAC.

Règles perso :

- Pas de Google.
- Seulement man, `oc explain`, YAML déjà dans le dépôt.
- Note toutes les commandes dans un fichier `~/ex370-mock-commands.sh`.

---

## 6. Checklist pré‑examen (condensée)

Tu pars à l’examen quand les cases ci‑dessous sont **vraiment** cochées.

### 6.1. Cluster & ODF

- [ ] Je sais vérifier l’état d’un cluster OCP (nodes, operators, events).
- [ ] Je sais vérifier la santé d’ODF (pods, StorageClass, dashboard, cephcluster).
- [ ] Je connais la différence Internal vs External Mode.

### 6.2. File / Block / NFS

- [ ] Je sais créer un PVC File (CephFS) et l’utiliser dans un Deployment.
- [ ] Je sais créer un PVC Block (RBD) et l’utiliser dans un Deployment.
- [ ] Je sais choisir RWX vs RWO selon le cas d’usage.
- [ ] Je sais créer une StorageClass custom avec `allowVolumeExpansion`.

### 6.3. Registry / Monitoring / Logging

- [ ] Je sais faire pointer la registry interne sur une StorageClass ODF.
- [ ] Je sais configurer le monitoring pour utiliser un PVC ODF.
- [ ] Je sais décrire une configuration LokiStack sur ODF (même si pas 100 % par cœur).

### 6.4. Capacité / quotas / extension

- [ ] Je sais créer un `ResourceQuota` pour limiter storage requests.
- [ ] Je sais créer un `LimitRange` pour encadrer la taille des PVC.
- [ ] Je sais étendre un PVC existant et vérifier la nouvelle taille dans le pod.

### 6.5. Snapshots / clones

- [ ] Je sais créer une `VolumeSnapshotClass` ODF.
- [ ] Je sais créer un `VolumeSnapshot` pour un PVC.
- [ ] Je sais créer un clone de PVC à partir d’un snapshot et l’utiliser.

### 6.6. Object Storage

- [ ] Je sais créer une `ObjectBucketClaim`.
- [ ] Je sais retrouver endpoint + creds dans Secret/ConfigMap.
- [ ] Je sais configurer un client S3 (s3cmd ou autre) et faire put/get.

### 6.7. Sécurité

- [ ] Je sais créer un Role/RoleBinding pour restreindre la gestion des ressources de storage.
- [ ] Je sais lier une ServiceAccount à une SCC si nécessaire.
- [ ] Je sais stocker des credentials S3 dans un Secret et les injecter dans un pod.

### 6.8. Troubleshooting

- [ ] Je sais diagnostiquer un pod en Pending à cause du storage (events, describe).
- [ ] Je sais diagnostiquer un PVC/PV en `Lost` ou `Failed`.
- [ ] Je sais résoudre des erreurs de montage simples (permissions, quota, taille).

---

## 7. Stratégie le jour J

1. **Lecture rapide** de tous les exercices.
2. Commencer par :
   - vérification cluster/ODF,
   - tâches rapides (création PVC, petites apps).
3. Noter toutes les commandes dans un script texte.
4. Garder 20–30 min à la fin pour :
   - revérifier les ressources demandées,
   - corriger les namespaces / typo / StorageClass.

Ce canvas + le dépôt `ex370-odf` te donnent une base complète. Tu peux maintenant enrichir au fur et à mesure avec tes propres notes, erreurs rencontrées et variantes d’exercices pour ancrer tout ça dans le temps.

