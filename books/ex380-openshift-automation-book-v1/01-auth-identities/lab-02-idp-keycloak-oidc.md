# LAB-01-02 – Configurer Keycloak comme IdentityProvider OIDC

- **Bloc** : Auth & identités
- **Durée cible** : 60–90 min

## 1. Objectifs

- Déclarer un IDP OIDC Keycloak dans OpenShift.
- Vérifier le login via ce fournisseur.
- Associer un groupe Keycloak à un rôle cluster OpenShift.

## 2. Pré-requis

- Un Keycloak accessible depuis ton cluster.
- Un realm `ocp` (par exemple) avec :
  - un client OIDC de type `confidential` ou `public`,
  - au moins un utilisateur `ocp-user` dans un groupe `ocp-admins`.

## 3. Énoncé

1. Ajoute un IdentityProvider OIDC basé sur ton Keycloak.
2. Permets à `ocp-user` de se connecter à la console OpenShift.
3. Donne au groupe `ocp-admins` le rôle `cluster-admin`.
4. Vérifie que `ocp-user` dispose bien de privilèges admin.

## 4. Implémentation

### 4.1. Récupérer les infos côté Keycloak

- `issuer` : `https://keycloak.example.com/realms/ocp`
- `clientID` : `openshift`
- `clientSecret` : `<secret si confidential>`
- `ca` : certificat de confiance si self-signed.

### 4.2. Ajouter l’IDP OIDC dans la ressource OAuth

```bash
oc edit oauth cluster
```

Ajouter une entrée :

```yaml
spec:
  identityProviders:
  - name: keycloak-oidc
    mappingMethod: claim
    type: OpenID
    openID:
      claims:
        preferredUserName:
        - preferred_username
        name:
        - name
        email:
        - email
        groups:
        - groups
      clientID: openshift
      clientSecret:
        name: keycloak-oidc-client-secret
      issuer: https://keycloak.example.com/realms/ocp
      ca:
        name: keycloak-ca
```

Créer le Secret `keycloak-oidc-client-secret` et le ConfigMap `keycloak-ca` si besoin :

```bash
oc create secret generic keycloak-oidc-client-secret -n openshift-config   --from-literal=clientSecret='<ton-secret>'

oc create configmap keycloak-ca -n openshift-config   --from-file=ca.crt=/tmp/keycloak-ca.crt
```

### 4.3. RBAC – donner cluster-admin au groupe

```bash
oc adm policy add-cluster-role-to-group cluster-admin ocp-admins
```

### 4.4. Vérifications

1. Ouvre la console Web OpenShift.
2. Choisis le provider `keycloak-oidc`.
3. Connecte-toi avec `ocp-user`.
4. Vérifie :

```bash
oc whoami
oc get nodes
oc get projects
```

## 5. Points à retenir

- `oauth/cluster` = CR central de config auth.
- L’IDP OpenID/Keycloak repose sur `issuer`, `clientID`, `clientSecret`.
- Les groupes OIDC peuvent être mappés directement à des rôles OpenShift via `oc adm policy`.
