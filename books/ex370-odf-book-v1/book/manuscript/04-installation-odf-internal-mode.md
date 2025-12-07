# Chapitre 4 – Installation d'ODF en Internal Mode

## 4.1. Pré-requis

- Nœuds avec des disques supplémentaires non utilisés par OpenShift.
- Ressources CPU/RAM suffisantes.
- OperatorHub accessible.

## 4.2. Labelliser les nœuds de stockage

```bash
oc label node <node1> cluster.ocs.openshift.io/openshift-storage=''
oc label node <node2> cluster.ocs.openshift.io/openshift-storage=''
oc label node <node3> cluster.ocs.openshift.io/openshift-storage=''
```

## 4.3. Installation de l'operator

- Via console : OperatorHub → OpenShift Data Foundation → Install.
- Via YAML : Subscription + OperatorGroup (voir `labs/02-install-odf-internal-mode`).

## 4.4. Création du StorageCluster

- Créer un YAML `StorageCluster` en Internal Mode.
- Sélectionner les nœuds labellisés.
- Laisser ODF gérer automatiquement la topologie (standard).

## 4.5. Vérifications

```bash
oc get pods -n openshift-storage
oc get storageclass
oc get cephcluster -n openshift-storage
```

Le dashboard ODF doit afficher un état **HEALTH_OK**.
