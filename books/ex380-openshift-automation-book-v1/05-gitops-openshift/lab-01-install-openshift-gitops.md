# LAB-05-01 – Installer OpenShift GitOps (Argo CD)

- **Bloc** : GitOps
- **Durée cible** : 45–60 min

## 1. Objectifs

- Installer l’Operator **Red Hat OpenShift GitOps**.
- Vérifier la présence du namespace `openshift-gitops`.
- Se connecter à l’instance Argo CD admin.

## 2. Pré-requis

- Cluster OCP 4.14+ avec cluster-admin.
- Accès Internet aux catalogues d’operators Red Hat.

## 3. Énoncé

1. Installe l’Operator OpenShift GitOps en scope cluster.
2. Vérifie la création du namespace `openshift-gitops`.
3. Récupère le mot de passe admin Argo CD et teste la connexion.

## 4. Installation Operator

```bash
oc new-project openshift-operators-redhat || true

cat <<'EOF' | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-gitops-operator-group
  namespace: openshift-operators
spec:
  targetNamespaces:
  - openshift-operators
EOF
```

Subscription :

```bash
cat <<'EOF' | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-gitops-operator
  namespace: openshift-operators
spec:
  channel: latest
  name: openshift-gitops-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

Vérifie :

```bash
oc get csv -n openshift-operators | grep gitops
oc get ns | grep openshift-gitops
```

## 5. Connexion Argo CD

```bash
oc get pods -n openshift-gitops
```

Récupérer le mot de passe admin :

```bash
oc get secret -n openshift-gitops   openshift-gitops-cluster   -o jsonpath='{.data.admin\.password}' | base64 -d; echo
```

Port-forward pour accéder à l’UI :

```bash
oc port-forward svc/openshift-gitops-server -n openshift-gitops 8443:443
```

Puis ouvrir `https://localhost:8443` et se connecter avec :

- user : `admin`
- password : valeur du secret ci-dessus.

## 6. Points clés

- Operator OpenShift GitOps = Argo CD intégré et supporté Red Hat.
- Namespace standard : `openshift-gitops`.
- L’admin GitOps se fait via CR `Application`, `AppProject`, etc.
