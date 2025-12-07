# Semaine 1 - Socle OpenShift / K8s

## S1.B1 - Cluster, login, projet

**But** : se connecter au cluster, vérifier les nœuds, travailler dans le bon projet.

### Concepts
- Un **contexte `oc`** = cluster + utilisateur + projet courant.
- Un **projet** OpenShift = un **namespace** Kubernetes.

### Commandes
```bash
# Connexion (exemple)
oc login -u developer https://api.crc.testing:6443
# ou pour l’admin
oc login -u kubeadmin https://api.crc.testing:6443

# Voir le projet courant
oc project

# Lister tous les projets accessibles
oc projects

# Créer ton projet de labo
oc new-project ex280-lab02

# Vérifier les nœuds du cluster
oc get nodes
```

### À retenir (EX280)
- Toujours vérifier le projet courant avec `oc project` avant de créer des ressources.
- Savoir basculer de projet : `oc project <nom>`.

---

## S1.B2 - Deployment simple HTTPD

**But** : créer un Deployment HTTPD depuis une image Red Hat UBI.

### Concepts
- Un **Deployment** gère :
  - le nombre de pods (replicas)
  - les mises à jour (rolling update)
- L’image `registry.access.redhat.com/ubi8/httpd-24` embarque Apache HTTPD.

### Commandes
```bash
# Création du Deployment
#  create deployment httpd-demo \
  --image=registry.access.redhat.com/ubi8/httpd-24 \
  --port=8080

# Vérifier les pods créés
#  get pods

# Vue détaillée (IP, node, etc.)
oc get pods -o wide

# Vérifier le Deployment
#  get deploy
oc describe deploy httpd-demo
```

### À retenir (EX280)
- Commande clé : `oc create deployment`.
- Un Deployment possède un **selector de labels** qui pointe vers ses pods.

---

## S1.B3 - Service + Route

**But** : exposer l’application vers l’intérieur du cluster, puis vers l’extérieur.

### Concepts
- **Service (ClusterIP)** : IP interne stable, load-balancing entre les pods.
- **Route** : URL HTTP(s) accessible depuis l’extérieur (spécifique OpenShift).

### Commandes
```bash
# Exposer le Deployment en Service (ClusterIP)
oc expose deployment httpd-demo --port=8080

# Voir le Service
#  get svc
oc describe svc httpd-demo

# Exposer le Service en Route
#  expose service httpd-demo

# Voir la Route
#  get route
```

Exemple d’URL :
```text
http://httpd-demo-ex280-lab02.apps-crc.testing
```

### À retenir (EX280)
- `oc expose deployment` → **Service**.
- `oc expose service` → **Route**.
- URL publique trouvable avec `oc get route`.

---

## S1.B4 - Scaling + Endpoints

**But** : augmenter/réduire le nombre de pods et comprendre l’impact sur le Service.

### Concepts
- `replicas` = nombre de pods voulus.
- **Endpoints** = liste `IP:port` des pods sélectionnés par le Service.

### Commandes
```bash
# Monter à 3 replicas
#  scale deployment httpd-demo --replicas=3

# Vérifier les pods
#  get pods -o wide

# Voir les endpoints du Service
#  get endpoints httpd-demo
oc describe svc httpd-demo
```

### À retenir (EX280)
- Commande clé : `oc scale deployment <name> --replicas=N`.
- Le Service envoie le trafic vers **tous** les endpoints correspondants.

---

## S1.B5 - ConfigMap + Secret (configuration externe)

**But** : sortir la configuration du conteneur et l’injecter dans les pods.

### Concepts
- **ConfigMap** : données non sensibles (env, paramètres fonctionnels).
- **Secret** : données sensibles (mot de passe, token, clé).
- Injection classique : **variables d’environnement**.

### Commandes
```bash
# Créer une ConfigMap
#  create configmap httpd-config \
  --from-literal=APP_ENV=ex280-lab02 \
  --from-literal=APP_OWNER=zidane

oc get configmap

# Créer un Secret générique
#  create secret generic httpd-secret \
  --from-literal=APP_PASSWORD=S3cr3t-Ex280

oc get secret

# Injecter dans le Deployment
#  set env deployment/httpd-demo --from=configmap/httpd-config
oc set env deployment/httpd-demo --from=secret/httpd-secret

# Voir la liste des variables configurées au niveau du Deployment
#  set env deployment/httpd-demo --list

# Vérifier dans un pod
#  get pods
oc exec -it <NOM_POD> -- env | grep APP_
```

### À retenir (EX280)
- Création : `oc create configmap` / `oc create secret generic`.
- Injection : `oc set env deployment/... --from=configmap/...` ou `--from=secret/...`.
- Toujours vérifier dans le pod avec `oc exec ... env`.

---

## S1.B6 - Probes (readiness / liveness)

**But** : contrôler la santé de l’application.

### Concepts
- **Readiness probe** :
  - indique si le pod est **prêt à recevoir du trafic**.
  - si KO → le Service ne l’utilise pas.
- **Liveness probe** :
  - indique si le pod est **vivant**.
  - si KO → Kubernetes redémarre le conteneur.
- Types courants : HTTP GET, TCP socket.

### Commandes (TCP)
```bash
# Supprimer d’éventuelles probes existantes
#  set probe deployment/httpd-demo --readiness --remove
oc set probe deployment/httpd-demo --liveness  --remove

# Probes TCP
#  set probe deployment/httpd-demo \
  --readiness \
  --open-tcp=8080 \
  --initial-delay-seconds=5 \
  --timeout-seconds=2

oc set probe deployment/httpd-demo \
  --liveness \
  --open-tcp=8080 \
  --initial-delay-seconds=10 \
  --timeout-seconds=2

# Vérifier sur le Deployment
#  describe deployment httpd-demo | egrep 'Liveness|Readiness'
```

### À retenir (EX280)
- `oc set probe` permet d’ajouter/modifier/supprimer les probes.
- `--open-tcp=PORT` = probe TCP.
- Readiness = participation au Service, Liveness = redémarrage.

---

## S1.B7 - Requests / Limits (ressources)

**But** : contrôler la consommation CPU / mémoire et la qualité de service.

### Concepts
- **requests** : ressources minimales *demandées* (scheduling).
- **limits** : plafond maximal autorisé.
- Les combinaisons requests/limits déterminent la **QoS** (Guaranteed / Burstable / BestEffort).

### Commandes
```bash
# Définir requests et limits sur le Deployment
#  set resources deployment/httpd-demo \
  --requests=cpu=50m,memory=64Mi \
  --limits=cpu=200m,memory=256Mi

# Vérifier sur le Deployment
#  describe deployment httpd-demo | grep -A5 Limits

# Vérifier sur un Pod
#  get pods
oc describe pod <NOM_POD> | grep -A5 Limits
```

### À retenir (EX280)
- Commande clé : `oc set resources deployment/...`.
- Différence conceptuelle : `requests` (planification) vs `limits` (plafond).

---

## S1.B8 - PVC + volume + persistance

**But** : monter un volume persistant et vérifier que les données survivent au redémarrage du pod.

### Concepts
- **PVC (PersistentVolumeClaim)** : demande de stockage.
- **PV (PersistentVolume)** : ressource de stockage réelle.
- Le pod monte un volume basé sur un PVC → les données sont persistantes.

### YAML PVC
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-httpd-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: crc-csi-hostpath-provisioner
```

### Commandes
```bash
# Créer le PVC
#  apply -f pvc-httpd-data.yaml
oc get pvc

# Attacher le PVC au Deployment
#  set volume deployment/httpd-demo \
  --add \
  --name=httpd-data \
  --type=persistentVolumeClaim \
  --claim-name=pvc-httpd-data \
  --mount-path=/var/www/html/data   # ou un chemin adapté

# Vérifier sur le Deployment
#  describe deployment httpd-demo | grep -A5 "Volumes"

# Vérifier que le PVC est Bound
#  get pvc
```

### Test de persistance (principe)
```bash
# 1) Pod 1 : écrire un fichier sur le volume
oc exec -it <POD1> -- sh -c "echo 'EX280 PVC OK' > /var/www/html/data/test.txt; ls -l /var/www/html/data; cat /var/www/html/data/test.txt"

# 2) Supprimer le pod
oc delete pod <POD1>
oc get pods   # attendre que <POD2> soit Running

# 3) Pod 2 : vérifier que le fichier existe toujours
oc exec -it <POD2> -- sh -c "ls -l /var/www/html/data; cat /var/www/html/data/test.txt"
# → doit afficher : EX280 PVC OK
```

### À retenir (EX280)
- Création du PVC → `oc apply -f ...`, statut `Bound`.
- Attache au Deployment → `oc set volume ... --claim-name=... --mount-path=...`.
- Test : écrire un fichier, supprimer le pod, vérifier dans le nouveau pod.

---






