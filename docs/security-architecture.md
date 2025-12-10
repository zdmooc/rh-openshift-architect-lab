# Architecture sécurité OpenShift – Lab Architecte

## 1. Objectifs

* Définir un modèle de sécurité cohérent pour le lab OpenShift.
* Préparer des patterns réutilisables en entreprise :

  * séparation des environnements,
  * RBAC clair,
  * segmentation réseau,
  * gestion des secrets.

## 2. Principes généraux

* **Least privilege** : chaque compte (humain ou technique) n’a que les droits nécessaires.
* **Séparation des environnements** : dev / test / prod (dans le lab : différents namespaces).
* **Séparation plateforme / apps** :

  * plateformes : `openshift-*`, `kube-*`, `openshift-gitops`, monitoring…
  * apps de lab : `ex280-*`, `ex288-*`, `ex370-*`, `ex380-*`, `ex480-*`, `ex482-*`, `sandbox-*`.
* **Traçabilité** : opérations faites via `oc`/GitOps, pas de bricolage manuel durable en prod.

## 3. Modèle RBAC

### 3.1. Rôles types

Pour les namespaces applicatifs (lab) :

* `lab-admin` :

  * peut gérer tous les objets du projet (mais pas la plateforme).
* `lab-dev` :

  * peut déployer/mettre à jour ses apps, lire les logs, voir les events.
* `lab-ops` :

  * accès lecture + actions de run (rollout, restart, scale), mais pas de modification de manifests GitOps.

Ces rôles seront matérialisés par des `Role`/`RoleBinding` dans :

```text
platform/security/rbac/
```

### 3.2. Séparation des rôles plateforme vs lab

* Plateforme :

  * admins cluster (`cluster-admin`) limités en nombre.
  * gestion des Operators, nodes, storage, réseau global.
* Lab :

  * droits accordés par namespace (via `RoleBinding`) pour les utilisateurs de test et d’exercices.

L’objectif est que la plupart des actions quotidiennes se fassent avec des comptes “non cluster-admin”.

## 4. Segmentation réseau (NetworkPolicy)

### 4.1. Principes

* **Deny by default** pour les namespaces applicatifs :

  * aucune communication pod→pod par défaut entre namespaces.
  * ouverture explicite (whitelist) vers :

    * services internes nécessaires (DB, API internes),
    * egress contrôlé (DNS, proxies, sorties HTTP/HTTPS autorisées).

### 4.2. Implémentation dans le lab

Dans :

```text
platform/security/networkpolicies/
```

on définit par exemple :

* `default-deny-all.yaml` :

  * bloque tout trafic entrant dans un namespace.
* `allow-same-namespace.yaml` :

  * autorise le trafic entre pods d’un même namespace.
* `allow-egress-dns-http.yaml` :

  * autorise l’egress vers le DNS du cluster et vers HTTP/HTTPS sortant si besoin.

Chaque namespace de lab (`ex280-*`, etc.) appliquera un set minimal de NetworkPolicy pour imiter une prod sécurisée.

## 5. Gestion des secrets

### 5.1. Bonnes pratiques

* Ne jamais committer de secrets en clair dans Git.
* Utiliser :

  * `Secret` Kubernetes,
  * ou un outil de type SealedSecrets / vault externe (référence possible plus tard).
* Séparer :

  * secrets plateforme (certificats d’ingress, comptes techniques globaux),
  * secrets applicatifs par namespace.

### 5.2. Intégration GitOps

Dans ce lab :

* Les manifests non sensibles (types, noms de secrets) peuvent être dans Git.
* Les valeurs sensibles peuvent être injectées :

  * via SealedSecrets (future étape),
  * ou via des scripts locaux (non committés) en mode “lab”.

L’objectif est de montrer la logique, même si le lab reste simplifié.

## 6. PodSecurity / SCC

Sur OpenShift :

* Utilisation de `SecurityContextConstraints` (SCC) pour définir les permissions des pods.
* Principe :

  * utiliser les SCC par défaut (`restricted`) pour la majorité des workloads.
  * éviter les SCC privilégiés (`privileged`) sauf cas très particuliers (stockage, monitoring spécifique…).

Pour le lab, on documentera :

* quels workloads utilisent quoi,
* comment vérifier que les workloads de lab restent dans un profil sécurisé.

## 7. Organisation des manifests sécurité dans le dépôt

Dans ce dépôt :

```text
platform/
  security/
    namespaces/        # conventions de nommage, labels, annotations
    rbac/              # Role, RoleBinding, ClusterRoleBinding modèles
    networkpolicies/   # NetworkPolicy par namespace / pattern
```

* `namespaces/` :

  * YAML de création de namespaces avec labels d’environnement (ex: `env=dev`, `env=rec`, `env=prod-lab`).
* `rbac/` :

  * définitions des rôles `lab-admin`, `lab-dev`, `lab-ops`.
* `networkpolicies/` :

  * modèles pour `default-deny`, `allow-same-namespace`, `allow-egress-*`.

Ces manifests sont faits pour être appliqués via GitOps (voir `docs/gitops-platform.md`).

## 8. Roadmap sécurité pour ce lab

1. Créer un set minimal de roles et RoleBinding :

   * `lab-admin`, `lab-dev`, `lab-ops` dans `platform/security/rbac/`.
2. Appliquer un modèle de NetworkPolicy par défaut pour les namespaces de lab.
3. Documenter les conventions de namespaces (labels env, équipe, projet).
4. Plus tard :

   * intégrer SealedSecrets ou un gestionnaire de secrets externe.
   * ajouter des contrôles automatiques (Kyverno/Gatekeeper) pour valider les bonnes pratiques.
