# Lab04 — Users, Groups, RBAC & (option) HTPasswd IdP

## Objectif

- Créer un groupe et le lier à un rôle sur un projet.
- Vérifier les bindings et les permissions.
- (Option CRC avancée) Ajouter un IdP `htpasswd` et tester un user non-kubeadmin.

## Pré-requis

- kubeadmin (cluster-admin).
- Labs 00→03 OK.
- Pour la partie IdP `htpasswd` : binaire `htpasswd` disponible dans le PATH (ou équivalent).

---

## Partie A — RBAC projet (core EX280)

### Step A1 — Projet de travail

```bash
oc get project ex280-lab04-rbac-zidane || oc new-project ex280-lab04-rbac-zidane
oc project ex280-lab04-rbac-zidane
```

### Step A2 — Créer un groupe logique

```bash
oc adm groups new ex280-devs zidane-dev1 zidane-dev2 || true

oc get groups
oc describe group ex280-devs
```

### Step A3 — Lier un rôle au groupe sur le projet

```bash
oc policy add-role-to-group edit ex280-devs -n ex280-lab04-rbac-zidane

oc get rolebindings -n ex280-lab04-rbac-zidane
# Adapter le nom du binding :
# oc describe rolebinding -n ex280-lab04-rbac-zidane <nom-du-rolebinding>
```

### Step A4 — Vérifier les permissions

```bash
oc auth can-i get pods --as=zidane-dev1 -n ex280-lab04-rbac-zidane || true
oc auth can-i create deployment --as=zidane-dev1 -n ex280-lab04-rbac-zidane || true
oc auth can-i delete project --as=zidane-dev1 -n ex280-lab04-rbac-zidane || true
```

---

## Vérifications (Partie A)

```bash
oc get project ex280-lab04-rbac-zidane
oc get groups | grep ex280-devs || echo "Groupe ex280-devs non trouvé"
oc get rolebindings -n ex280-lab04-rbac-zidane
```

Critères :

- Projet `ex280-lab04-rbac-zidane` existe.
- Groupe `ex280-devs` existe avec membres `zidane-dev1`, `zidane-dev2`.
- Un rolebinding lie `ex280-devs` au rôle `edit` sur le projet.

---

## Cleanup (Partie A, optionnel)

```bash
oc delete project ex280-lab04-rbac-zidane --ignore-not-found
# (Optionnel) ne pas supprimer le groupe si tu veux le réutiliser
# oc delete group ex280-devs --ignore-not-found
```

---

## Partie B — (Option CRC) IdP HTPasswd + test de login

> Modifie OAuth du cluster. À faire plutôt sur CRC.

### Step B1 — Créer un fichier htpasswd (machine locale)

```bash
mkdir -p /c/workspaces/openshift2026/auth
cd /c/workspaces/openshift2026/auth

htpasswd -c -B -b users.htpasswd ex280-user1 Passw0rd!
htpasswd    -B -b users.htpasswd ex280-user2 Passw0rd!
```

### Step B2 — Secret dans `openshift-config`

```bash
oc project default

oc -n openshift-config create secret generic htpasswd-auth \
  --from-file=htpasswd=/c/workspaces/openshift2026/auth/users.htpasswd

oc -n openshift-config get secret htpasswd-auth
```

### Step B3 — Sauvegarde + modification OAuth

```bash
oc get oauth cluster -o yaml > /c/workspaces/openshift2026/auth/oauth-cluster-backup.yaml
oc get oauth cluster -o yaml > /c/workspaces/openshift2026/auth/oauth-cluster-htpasswd.yaml
```

Éditer `oauth-cluster-htpasswd.yaml` et ajouter (ou compléter) :

```yaml
spec:
  identityProviders:
  - name: ex280-htpasswd
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpasswd-auth
```

Puis appliquer :

```bash
oc replace -f /c/workspaces/openshift2026/auth/oauth-cluster-htpasswd.yaml
```

### Step B4 — Tester le login user htpasswd

```bash
oc logout || true

oc login -u ex280-user1 -p 'Passw0rd!' https://api.crc.testing:6443
oc whoami

# Revenir kubeadmin
oc login -u kubeadmin -p '<KUBEADMIN_PWD>' https://api.crc.testing:6443
oc whoami
```

---

## Rollback (Optionnel CRC)

```bash
oc replace -f /c/workspaces/openshift2026/auth/oauth-cluster-backup.yaml
```

---

## Pièges fréquents

- `htpasswd` non trouvé → générer le fichier depuis un conteneur httpd si besoin.
- `oc replace` KO → erreur d’indentation YAML.
- Login user htpasswd KO → vérifier Secret et ressource `oauth/cluster`.

