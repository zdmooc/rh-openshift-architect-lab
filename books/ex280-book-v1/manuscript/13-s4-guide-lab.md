# Semaine 4 - Identité, multi‑tenancy & Helm

### Objectif S4
Être capable, uniquement en CLI :
- De gérer **IdP htpasswd**, utilisateurs et groupes.
- D’assigner des **rôles** (RBAC) à des utilisateurs / groupes.
- De configurer **LimitRange / ResourceQuota / ClusterResourceQuota** par projet.
- De définir un **project template** “clé en main”.
- De manipuler **Helm** (install, upgrade, rollback) côté dev.

---

### 4.1 Brique 6 - IdP htpasswd (vue admin cluster)

> À faire uniquement avec un compte cluster‑admin (`kubeadmin` sur CRC).

**Concepts**
- `htpasswd` = fichier local d’utilisateurs / mots de passe.
- Secret `htpasswd-secret` dans `openshift-config`.
- CR `OAuth/cluster` référence ce secret.

**Étapes type (sur ta machine locale)**

1. Créer le fichier htpasswd :
```bash
htpasswd -c -B -b users.htpasswd zidane 'MotDePasseFort!'
# ajouter d’autres users (sans -c pour ne pas écraser)
htpasswd -B -b users.htpasswd dev1 'Passw0rd!'
```

2. Créer le secret dans `openshift-config` :
```bash
oc create secret generic htpasswd-secret \
  --from-file=htpasswd=users.htpasswd \
  -n openshift-config
```

3. Patcher l’`OAuth` :
```bash
oc edit oauth cluster
```

Exemple d’IdP à ajouter dans `spec.identityProviders` :
```yaml
- name: local-htpasswd
  mappingMethod: claim
  type: HTPasswd
  htpasswd:
    fileData:
      name: htpasswd-secret
```

4. Se reconnecter via la console/CLI avec un user htpasswd.

**À retenir EX280**
- `htpasswd` → secret openshift-config → `oauth/cluster`.
- Savoir retrouver cette conf pour troubleshooting.

---

### 4.2 Brique 7 - Users, groups, RBAC projet

**Concepts**
- Un utilisateur apparaît quand il se connecte, ou via `oc create user` (selon version).
- Un **group** rassemble plusieurs users.
- On assigne des **roles** à un user ou group dans un projet.

**Groups**
```bash
# Créer un groupe\ noc adm groups new dev-team zidane dev1 dev2

# Lister / voir\ noc get groups
oc describe group dev-team
```

**RBAC projet** (ex : donner admin sur `ex280-lab02` au groupe) :
```bash
oc adm policy add-role-to-group admin dev-team -n ex280-lab02

# Vérifier pour un user précis
oc auth can-i create deployment -n ex280-lab02 --as=dev1
```

**Donner un rôle à un user directement**
```bash
oc adm policy add-role-to-user view zidane -n ex280-lab02
oc adm policy add-role-to-user edit dev1 -n ex280-lab02
```

**À retenir EX280**
- `oc adm groups new`, `oc adm policy add-role-to-{user,group}`.
- `oc auth can-i` = réflexe de vérification.

---

### 4.3 Brique 8 - ClusterResourceQuota vs ResourceQuota

**Concepts**
- `ResourceQuota` = quota par **namespace**.
- `ClusterResourceQuota` = quota **trans‑namespaces** (pattern multi‑projets).

**Exemple ResourceQuota (rappel)**
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
```bash
oc apply -f resourcequota-basic.yaml -n ex280-lab02
oc describe resourcequota compute-quota -n ex280-lab02
```

**Exemple ClusterResourceQuota** (nommage type EX280) :
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
  selector:
    labels:
      matchLabels:
        env: sandbox
```

Appliquer :
```bash
oc apply -f clusterresourcequota-ex280.yaml
oc get clusterresourcequota
oc describe clusterresourcequota crq-ex280-sandbox
```

**À retenir EX280**
- `ClusterResourceQuota` → API `quota.openshift.io/v1`.
- Sélection des namespaces via labels (ex : `env=sandbox`).

---

### 4.4 Brique 9 - Project template

**Concepts**
- OpenShift peut utiliser un **template de projet** pour pré‑créer :
  - quotas, limitranges,
  - rôles de base,
  - ConfigMaps / Secrets standards.

**Étapes type**

1. Créer un template projet :
```yaml
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: project-template-ex280
objects:
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
```

2. Placer le template dans un projet infra (souvent `openshift-config` ou projet dédié) :
```bash
oc apply -f project-template-ex280.yaml -n openshift-config
```

3. Lier ce template au cluster (CR `Project` ou `ProjectRequest` selon version) :
```bash
oc edit project.config.openshift.io/cluster
```

Exemple à ajouter :
```yaml
spec:
  projectRequestTemplate:
    name: project-template-ex280
```

4. Tester la création d’un nouveau projet :
```bash
oc new-project ex280-test-template
oc get resourcequota,limitrange -n ex280-test-template
```

**À retenir EX280**
- Project template = standardisation automatique des nouveaux projets.
- Tout passe par un Template + `project.config.openshift.io/cluster`.

---

### 4.5 Brique 10 - Helm côté dev (pont EX288)

**Concepts**
- Helm = gestionnaire de packages Kubernetes.
- `chart` = paquet (templates + values).
- Cycle de base : install → upgrade → rollback → uninstall.

**Commandes de base**

1. Initialiser / vérifier Helm :
```bash
helm version
```

2. Ajouter un repo public (ex : Bitnami) :
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

3. Chercher un chart :
```bash
helm search repo nginx
```

4. Installer un chart simple :
```bash
helm install my-nginx bitnami/nginx \
  --namespace ex280-lab02 \
  --create-namespace=false

oc get all -n ex280-lab02 -l app.kubernetes.io/instance=my-nginx
```

5. Upgrade (avec override de valeurs) :
```bash
helm upgrade my-nginx bitnami/nginx \
  --namespace ex280-lab02 \
  --set service.type=ClusterIP
```

6. Rollback :
```bash
helm history my-nginx -n ex280-lab02
helm rollback my-nginx 1 -n ex280-lab02
```

7. Uninstall :
```bash
helm uninstall my-nginx -n ex280-lab02
```

**À retenir EX280/EX288**
- `helm install / upgrade / rollback / uninstall`.
- Label `app.kubernetes.io/instance` pour filtrer les ressources d’un release.

---





