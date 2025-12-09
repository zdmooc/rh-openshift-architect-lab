# Lab 08 — Authentification: configurer HTPasswd IdP + gestion users/groups/passwords


## Objectifs EX280 couverts
- Configurer le provider HTPasswd
- Créer/supprimer des users
- Modifier les mots de passe
- Créer/gérer des groups
- Modifier permissions user/group

## Prérequis (cluster-admin requis)
- Tu dois pouvoir modifier `OAuth` cluster et créer des secrets dans `openshift-config`.
- Outils : `htpasswd` (paquet `httpd-tools` sur Linux, ou binaire équivalent sur Windows/WSL).

## Tâches
### 1) Créer un fichier htpasswd local (2 utilisateurs)
```bash
htpasswd -c -B -b htpasswd.users devuser 'DevPassw0rd!'
htpasswd -B -b htpasswd.users opsuser 'OpsPassw0rd!'
cat htpasswd.users
```

### 2) Créer/mettre à jour le secret dans `openshift-config`
```bash
oc create secret generic htpass-secret   --from-file=htpasswd=htpasswd.users   -n openshift-config --dry-run=client -o yaml | oc apply -f -
oc get secret htpass-secret -n openshift-config
```

### 3) Déclarer HTPasswd dans l’objet OAuth cluster
> On ajoute un IdP nommé `htpasswd`.
```bash
cat <<'YAML' | oc apply -f -
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: htpasswd
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret
YAML
```

Attendre la prise en compte (quelques instants) :
```bash
oc get oauth cluster -o yaml | sed -n '1,200p'
oc get pods -n openshift-authentication
```

### 4) Créer un groupe et lier un rôle
Créer un namespace de test et un groupe :
```bash
export NS=ex280-lab08-authz
oc new-project "$NS"

oc adm groups new ex280-devs
oc adm groups add-users ex280-devs devuser
oc adm policy add-role-to-group edit ex280-devs -n "$NS"
```

Vérifier rolebinding :
```bash
oc get rolebinding -n "$NS"
oc describe rolebinding -n "$NS" | sed -n '1,220p'
```

### 5) Modifier un mot de passe (htpasswd)
Mettre à jour le fichier local puis recharger dans le secret :
```bash
htpasswd -B -b htpasswd.users devuser 'DevPassw0rd!v2'
oc create secret generic htpass-secret   --from-file=htpasswd=htpasswd.users   -n openshift-config --dry-run=client -o yaml | oc apply -f -
```

### 6) Supprimer un user / retirer d’un groupe
```bash
oc adm groups remove-users ex280-devs devuser
oc get group ex280-devs -o yaml
```

## Vérifications
- `OAuth/cluster` contient un `identityProviders` de type HTPasswd.
- Le groupe `ex280-devs` existe et possède un binding `edit` dans le projet.
- Après mise à jour, le secret `htpass-secret` a un `resourceVersion` différent.

## Nettoyage (optionnel)
- Supprimer projet :
```bash
oc delete project "$NS"
```
- Retirer l’IdP HTPasswd (si cluster partagé) : éditer `oauth/cluster`.
