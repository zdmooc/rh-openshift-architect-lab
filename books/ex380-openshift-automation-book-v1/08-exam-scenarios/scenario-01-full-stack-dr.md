# SCÉNARIO-01 – Full stack DR : Auth + OADP + GitOps

- **Durée cible** : 3 h
- **Mode** : “whiteboard + examen blanc”
- **Objectif** : enchaîner plusieurs compétences EX380 dans un scénario unique.

## 1. Contexte

On te fournit :

- un cluster OCP 4.14,
- un Keycloak prêt avec un realm `ocp`,
- un MinIO dans le namespace `minio`,
- un repo Git `https://git.example.com/ex380/demo-app.git`.

Tu dois :

1. Mettre en place l’auth OIDC via Keycloak.
2. Installer OADP et configurer le backend MinIO.
3. Déployer une app stateful via GitOps.
4. Sauvegarder et restaurer le namespace applicatif.

## 2. Tâches

1. **Auth**
   - Ajouter un IDP OIDC `keycloak-oidc`.
   - Donner `cluster-admin` au groupe OIDC `ocp-admins`.

2. **OADP**
   - Installer OADP Operator.
   - Créer une DPA vers le MinIO `ex380-backups`.
   - Tester un backup à vide (pour valider le flux).

3. **GitOps**
   - Installer OpenShift GitOps.
   - Créer une `Application` Argo CD qui déploie l’app `demo-app` dans `ex380-demo`.
   - Vérifier que l’app est “Healthy / Synced”.

4. **DR**
   - Configurer un `Backup` OADP pour le namespace `ex380-demo`.
   - Supprimer le namespace `ex380-demo`.
   - Restaurer depuis le backup et valider que l’app remarche.

## 3. Contraintes

- Utiliser uniquement la CLI (`oc`, `argocd` CLI si dispo) et des manifests YAML.
- Pas de Helm ni de scripts, sauf si tu les rédiges toi-même pendant le scénario.
- Temps limite recommandé : 3 h.

## 4. Checklist de fin

- [ ] Login via Keycloak fonctionnel.
- [ ] Groupe `ocp-admins` avec droits admin.
- [ ] DPA OADP `oadp-s3` en état `Ready`.
- [ ] Application GitOps `demo-app` déployée et Healthy.
- [ ] Backup du namespace disponible.
- [ ] Namespace restauré, app fonctionnelle.
