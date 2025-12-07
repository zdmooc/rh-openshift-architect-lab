# EX280 – Semaine 4 – IdP, RBAC, Quotas, Project Template, Helm

> Contexte : CRC / OpenShift 4, cluster local. Rôle : **kubeadmin** (admin cluster) + **zidane** (user htpasswd). Namespace de travail principal : `ex280-lab02`, puis projets de test.

---
## 0. Objectif Semaine 4

Savoir faire **uniquement en CLI** :

1. Ajouter un **Identity Provider htpasswd** et créer l’utilisateur `zidane`.
2. Gérer les **contexts** kubeconfig (`kubeadmin`, `developer`, `zidane`).
3. Créer des **groups** et configurer le **RBAC** projet (rôles `admin`, `view`, etc.).
4. Mettre en place des **ResourceQuota** et un **ClusterResourceQuota** basés sur des labels.
5. Créer un **project template** (`project.config.openshift.io/cluster`) qui injecte quotas + limits dans les nouveaux projets.
6. Utiliser **Helm** côté dev : `install`, `upgrade`, `history`, `rollback`, `uninstall` + debug CPU/quotas.

---
## 1. IdP htpasswd – ajout de l’utilisateur `zidane`

### 1.1. Préparation du fichier htpasswd (sans binaire `htpasswd`)

Dossier local de travail :

```bash
cd ~/htpasswd-idp
```

Génération du hash htpasswd (format APR1) :

```bash
openssl passwd -apr1 'MotDePasseFort!'
# Exemple de sortie (celle utilisée) :
# $apr1$XtnBOovm$0yhqh3zULaIUEV1ArVQ7T/
```

Création du fichier `users.htpasswd` :

```bash
cd ~/htpasswd-idp

echo 'zidane:$apr1$XtnBOovm$0yhqh3zULaIUEV1ArVQ7T/' > users.htpasswd

cat users.htpasswd
# zidane:$apr1$XtnBOovm$0yhqh3zULaIUEV1ArVQ7T/
```

### 1.2. Secret `htpasswd-secret` dans `openshift-config`

En **kubeadmin** :

```bash
oc create secret generic htpasswd-secret \
  --from-file=htpasswd=users.htpasswd \
  -n openshift-config

oc get secret htpasswd-secret -n openshift-config
```

### 1.3. Configuration d’`OAuth/cluster`

Vérifier l’`OAuth` :

```bash
oc get oauth cluster -o yaml | head -n 30
```

Tu as corrigé la conf pour que dans `spec.identityProviders` tu aies quelque chose du type :

```yaml
spec:
  identityProviders:
  - name: developer
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpasswd-secret
```

### 1.4. Test de login avec l’IdP htpasswd

```bash
oc login -u zidane -p 'MotDePasseFort!' https://api.crc.testing:6443

oc whoami
# → zidane
```

Résultat : l’IdP htpasswd est opérationnel, `zidane` est un utilisateur reconnu par OpenShift.

---
## 2. Contextes kubeconfig et bascule kubeadmin ↔ zidane

### 2.1. Lister les contexts disponibles

```bash
oc config get-contexts
```

Exemples de contexts présents :

- `/api-crc-testing:6443/zidane` (user htpasswd)
- `ex280-lab02/api-crc-testing:6443/kubeadmin` (cluster-admin dans le projet ex280-lab02)
- `crc-admin`, `crc-developer`, etc.

### 2.2. Bascule vers kubeadmin

```bash
oc config use-context ex280-lab02/api-crc-testing:6443/kubeadmin

oc whoami
# kubeadmin

oc auth can-i '*' '*' --all-namespaces
# yes
```

### 2.3. Bascule vers `zidane`

```bash
oc config use-context /api-crc-testing:6443/zidane

oc whoami
# zidane
```

**Mental model :**
- `kubeadmin` = rôle **cluster-admin** : configuration globale (IdP, project template, CRQ…).
- `zidane` = **user applicatif** : travail dans ses projets, gestion des workloads avec les droits attribués.

---
## 3. Groupes & RBAC projet – `ex280-lab02`

Objectif : donner au groupe `ex280-dev-team` les droits `admin` sur le projet `ex280-lab02`, et vérifier que `zidane` hérite bien de ces droits via le groupe.

### 3.1. Création du groupe

En kubeadmin :

```bash
oc project ex280-lab02

oc adm groups new ex280-dev-team zidane

oc get groups
oc describe group ex280-dev-team
# Users: zidane
```

### 3.2. Attribuer le rôle `admin` au groupe dans le projet

```bash
oc adm policy add-role-to-group admin ex280-dev-team -n ex280-lab02

oc get rolebinding -n ex280-lab02
```

Tu observes un `rolebinding` type :

```text
Name:         admin-0
Role:         ClusterRole/admin
Subjects:     Group ex280-dev-team
```

### 3.3. Vérifier les droits (simulation `oc auth can-i`)

Toujours côté kubeadmin, en testant `--as` et `--as-group` :

```bash
oc auth can-i get pods -n ex280-lab02 \
  --as=zidane \
  --as-group=system:authenticated \
  --as-group=ex280-dev-team
# yes

oc auth can-i '*' '*' -n ex280-lab02 \
  --as=zidane \
  --as-group=system:authenticated \
  --as-group=ex280-dev-team
# no (selon règles globales cluster)
```

### 3.4. Test réel en se loggant en `zidane`

```bash
oc login -u zidane -p 'MotDePasseFort!' https://api.crc.testing:6443

oc whoami
# zidane

oc project ex280-lab02

oc get pods -n ex280-lab02
# → OK, l’accès est fonctionnel
```

Tu maîtrises :
- `oc adm groups new` pour créer des groupes.
- `oc adm policy add-role-to-group` pour donner des rôles par projet.
- `oc auth can-i` pour vérifier les droits, avec `--as` et `--as-group`.

---
## 4. Quotas : ResourceQuota (namespace) & ClusterResourceQuota (multi-namespaces)

### 4.1. ResourceQuota basique dans `ex280-lab02`

Fichier `resourcequota-basic.yaml` :

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
spec:
  hard:
    requests.cpu: "200m"
    requests.memory: "256Mi"
    limits.cpu: "500m"
    limits.memory: "640Mi"
    pods: "4"
```

Application et vérification :

```bash
oc apply -f resourcequota-basic.yaml -n ex280-lab02

oc get resourcequota -n ex280-lab02
oc describe resourcequota compute-quota -n ex280-lab02
```

Tu vois les compteurs `Used / Hard` évoluer en fonction des pods et des requests/limits.

### 4.2. Label du namespace pour CRQ

```bash
oc project ex280-lab02

oc label namespace ex280-lab02 env=sandbox --overwrite

oc get namespace ex280-lab02 --show-labels
# env=sandbox, ...
```

### 4.3. ClusterResourceQuota `crq-ex280-sandbox`

Fichier `clusterresourcequota-ex280-sandbox.yaml` :

```yaml
apiVersion: quota.openshift.io/v1
kind: ClusterResourceQuota
metadata:
  name: crq-ex280-sandbox
spec:
  quota:
    hard:
      requests.cpu: "2"
      requests.memory: "4Gi"
      limits.cpu: "4"
      limits.memory: "8Gi"
      pods: "10"
  selector:
    labels:
      matchLabels:
        env: sandbox
```

Application et inspection :

```bash
oc apply -f clusterresourcequota-ex280-sandbox.yaml

oc get clusterresourcequotas
oc describe clusterresourcequota crq-ex280-sandbox
```

Dans le `describe`, tu vois :
- `Namespace Selector: ["ex280-lab02"]`
- `Resource Used/Hard` pour CPU, mémoire, pods.

**Différence clé :**
- `ResourceQuota` → quotas **par namespace**.
- `ClusterResourceQuota` → quotas **multi-namespaces**, sélectionnés par labels.

---
## 5. Project Template global (standardisation des nouveaux projets)

Objectif : chaque `oc new-project` utilise un template qui crée automatiquement :
- un `Project` avec annotations (display name, description),
- un `ResourceQuota` standard,
- un `LimitRange` standard.

### 5.1. Template `project-template-ex280`

Fichier final :

```yaml
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: project-template-ex280
objects:
- apiVersion: project.openshift.io/v1
  kind: Project
  metadata:
    name: ${PROJECT_NAME}
    annotations:
      openshift.io/display-name: ${PROJECT_DISPLAYNAME}
      openshift.io/description: ${PROJECT_DESCRIPTION}
- apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: compute-quota
  spec:
    hard:
      requests.cpu: "200m"
      requests.memory: "256Mi"
      limits.cpu: "500m"
      limits.memory: "640Mi"
      pods: "4"
- apiVersion: v1
  kind: LimitRange
  metadata:
    name: basic-limits
  spec:
    limits:
    - type: Container
      default:
        cpu: "200m"
        memory: "256Mi"
      defaultRequest:
        cpu: "50m"
        memory: "64Mi"
parameters:
- name: PROJECT_NAME
  description: Nom technique du projet
  required: true
- name: PROJECT_DISPLAYNAME
  description: Nom affiché
  required: false
- name: PROJECT_DESCRIPTION
  description: Description du projet
  required: false
```

Application dans `openshift-config` :

```bash
oc project openshift-config
oc apply -f project-template-ex280.yaml -n openshift-config

oc get template project-template-ex280 -n openshift-config -o yaml | head -n 30
```

### 5.2. Lier le template à `project.config.openshift.io/cluster`

Avant patch :

```bash
oc get project.config.openshift.io cluster -o yaml | head -n 30
```

Patch :

```bash
oc patch project.config.openshift.io/cluster \
  --type=merge \
  -p '{"spec":{"projectRequestTemplate":{"name":"project-template-ex280"}}}'
```

Après patch :

```yaml
spec:
  projectRequestTemplate:
    name: project-template-ex280
```

### 5.3. Test : nouveau projet en kubeadmin

```bash
oc new-project ex280-test-template-admin \
  --display-name="EX280 Test Template Admin" \
  --description="Projet de test du project template EX280"

oc get project ex280-test-template-admin

oc get resourcequota,limitrange -n ex280-test-template-admin
oc describe resourcequota compute-quota -n ex280-test-template-admin
oc describe limitrange basic-limits -n ex280-test-template-admin
```

Tu observes que le `ResourceQuota` et le `LimitRange` sont créés automatiquement.

### 5.4. Test : nouveau projet créé par `zidane`

Login en `zidane` :

```bash
oc login -u zidane -p 'MotDePasseFort!' https://api.crc.testing:6443
oc whoami
# zidane

oc new-project ex280-test-template-zidane \
  --display-name="EX280 Test Template Zidane" \
  --description="Projet de test du project template EX280 (user htpasswd)"
```

Côté kubeadmin, tu confirmes que :
- le projet **existe**,
- `ResourceQuota`/`LimitRange` sont présents.

Puis tu donnes à `zidane` le rôle `admin` sur ce projet :

```bash
oc adm policy add-role-to-user admin zidane -n ex280-test-template-zidane

oc describe rolebinding admin -n ex280-test-template-zidane
# Subjects: User zidane
```

En `zidane` :

```bash
oc project ex280-test-template-zidane
oc get resourcequota,limitrange
# → OK
```

**Conclusion :** tu maîtrises le **Project Template** + **RBAC** associé pour que les nouveaux projets aient une base standard (quotas & limits) et que les users aient les bons droits.

---
## 6. Helm côté dev – cycle complet sur Nginx

Namespace de travail : `ex280-test-template-zidane` avec user `zidane`.

### 6.1. Vérifications et préparation

```bash
helm version

oc project
# ex280-test-template-zidane

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm search repo nginx | head
# bitnami/nginx 22.3.2 1.29.3 ...
```

### 6.2. Installation de `my-nginx`

```bash
helm install my-nginx bitnami/nginx \
  --namespace ex280-test-template-zidane \
  --create-namespace=false \
  --set service.type=ClusterIP

oc get all -n ex280-test-template-zidane
```

Premier pod : `Pending` avec `Insufficient cpu` (quota/CRC limités).

### 6.3. Correction par `helm upgrade` (resources)

Tu as réduit les requests/limits de CPU et mémoire :

```bash
helm upgrade my-nginx bitnami/nginx \
  --namespace ex280-test-template-zidane \
  --set resources.requests.cpu=50m \
  --set resources.limits.cpu=100m \
  --set resources.requests.memory=64Mi \
  --set resources.limits.memory=128Mi
```

Vérification :

```bash
oc get pod -n ex280-test-template-zidane \
  -l app.kubernetes.io/instance=my-nginx -o wide

oc describe pod -n ex280-test-template-zidane my-nginx-<XXX>
# Status: Running, Ready: True
# Requests: cpu 50m, memory 64Mi
# Limits:   cpu 100m, memory 128Mi
```

### 6.4. Historique et rollback

Historique des révisions :

```bash
helm history my-nginx -n ex280-test-template-zidane
# 1: Install complete
# 2: Upgrade complete
```

Rollback vers la révision 1 :

```bash
helm rollback my-nginx 1 -n ex280-test-template-zidane

oc get pod -n ex280-test-template-zidane \
  -l app.kubernetes.io/instance=my-nginx -o wide
```

Les pods peuvent repasser en `Pending` si les ressources de la révision 1 sont trop élevées par rapport au quota.

Nouvel historique après rollback :

```bash
helm history my-nginx -n ex280-test-template-zidane
# 3: Rollback to 1
```

### 6.5. Désinstallation propre

```bash
helm uninstall my-nginx -n ex280-test-template-zidane

oc get all -n ex280-test-template-zidane
# No resources found
```

**Cycle Helm maîtrisé :**

- `helm install`
- `helm upgrade` (avec `--set` pour modifier les `resources`)
- `helm history`
- `helm rollback`
- `helm uninstall`

Et tu sais filtrer les objets d’une release avec :

```bash
oc get pod -n ex280-test-template-zidane \
  -l app.kubernetes.io/instance=my-nginx
```

---
## 7. Checklist mentale EX280 – Semaine 4

1. **IdP htpasswd**
   - [ ] Générer un hash avec `openssl passwd -apr1`
   - [ ] Créer `users.htpasswd` (user:hash)
   - [ ] `oc create secret generic htpasswd-secret -n openshift-config --from-file=htpasswd=users.htpasswd`
   - [ ] Vérifier `oauth/cluster` → `fileData.name: htpasswd-secret`
   - [ ] `oc login -u zidane -p ...` OK

2. **Contexts & RBAC**
   - [ ] `oc config get-contexts`, `oc config use-context ...`
   - [ ] `oc adm groups new ex280-dev-team zidane`
   - [ ] `oc adm policy add-role-to-group admin ex280-dev-team -n ex280-lab02`
   - [ ] `oc auth can-i get pods -n ex280-lab02 --as=zidane --as-group=ex280-dev-team`

3. **Quotas**
   - [ ] `ResourceQuota` par namespace (`compute-quota`)
   - [ ] Label `env=sandbox` sur `ex280-lab02`
   - [ ] `ClusterResourceQuota crq-ex280-sandbox` avec `selector.labels.matchLabels.env=sandbox`

4. **Project template**
   - [ ] Template `project-template-ex280` dans `openshift-config`
   - [ ] `project.config.openshift.io/cluster.spec.projectRequestTemplate.name=project-template-ex280`
   - [ ] Test `oc new-project ex280-test-template-admin` → RQ + LR auto
   - [ ] Test `oc new-project ex280-test-template-zidane` + `add-role-to-user admin` pour `zidane`

5. **Helm**
   - [ ] `helm repo add bitnami ...`, `helm repo update`, `helm search repo`
   - [ ] `helm install my-nginx bitnami/nginx --namespace ...`
   - [ ] `helm upgrade` pour ajuster `resources.requests/limits`
   - [ ] `helm history`, `helm rollback`, `helm uninstall`
   - [ ] Debug `Pending / Insufficient cpu` avec `oc describe pod` + quotas.

Ce canvas = ta **fiche complète Semaine 4** pour EX280/EX288 : identité, multi-tenancy (RBAC/Quotas/Project template) et Helm côté dev.

