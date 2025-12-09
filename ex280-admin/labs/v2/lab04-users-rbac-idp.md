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
