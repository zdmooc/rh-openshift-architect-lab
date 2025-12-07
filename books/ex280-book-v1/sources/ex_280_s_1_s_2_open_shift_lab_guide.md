# Formation OpenShift EX280 – Semaine 1 & 2

Projet de travail : `ex280-lab02`  
Cluster : CRC local (OpenShift 4.x)  
Mode : **CLI-first** avec `oc` (Git Bash Windows)

---

## Objectifs globaux

### Objectif fin Semaine 1
Être capable, **uniquement en CLI**, de :
- Créer un projet
- Déployer une application simple (Deployment)
- L’exposer (Service + Route)
- Gérer le scaling
- Gérer la configuration (ConfigMap / Secret)
- Ajouter probes (readiness / liveness) + ressources (requests / limits)
- Attacher un PVC et tester la persistance

### Objectif fin Semaine 2
Toujours en CLI, savoir :
- Organiser les ressources avec **labels** (app/env/tier/owner)
- Documenter avec des **annotations**
- Naviguer avec `-l`, `-L`, `--field-selector`
- Mettre en place un **LimitRange** (defaults CPU / RAM)
- Mettre en place un **ResourceQuota** (budget CPU / RAM / pods)
- Comprendre l’impact concret sur la création / scalabilité des pods

---

# Semaine 1 – Socle OpenShift / K8s

## S1.B1 – Cluster, login, projet

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

## S1.B2 – Deployment simple HTTPD

**But** : créer un Deployment HTTPD depuis une image Red Hat UBI.

### Concepts
- Un **Deployment** gère :
  - le nombre de pods (replicas)
  - les mises à jour (rolling update)
- L’image `registry.access.redhat.com/ubi8/httpd-24` embarque Apache HTTPD.

### Commandes
```bash
# Création du Deployment\ noc create deployment httpd-demo \
  --image=registry.access.redhat.com/ubi8/httpd-24 \
  --port=8080

# Vérifier les pods créés\ noc get pods

# Vue détaillée (IP, node, etc.)
oc get pods -o wide

# Vérifier le Deployment\ noc get deploy
oc describe deploy httpd-demo
```

### À retenir (EX280)
- Commande clé : `oc create deployment`.
- Un Deployment possède un **selector de labels** qui pointe vers ses pods.

---

## S1.B3 – Service + Route

**But** : exposer l’application vers l’intérieur du cluster, puis vers l’extérieur.

### Concepts
- **Service (ClusterIP)** : IP interne stable, load-balancing entre les pods.
- **Route** : URL HTTP(s) accessible depuis l’extérieur (spécifique OpenShift).

### Commandes
```bash
# Exposer le Deployment en Service (ClusterIP)
oc expose deployment httpd-demo --port=8080

# Voir le Service\ noc get svc
oc describe svc httpd-demo

# Exposer le Service en Route\ noc expose service httpd-demo

# Voir la Route\ noc get route
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

## S1.B4 – Scaling + Endpoints

**But** : augmenter/réduire le nombre de pods et comprendre l’impact sur le Service.

### Concepts
- `replicas` = nombre de pods voulus.
- **Endpoints** = liste `IP:port` des pods sélectionnés par le Service.

### Commandes
```bash
# Monter à 3 replicas\ noc scale deployment httpd-demo --replicas=3

# Vérifier les pods\ noc get pods -o wide

# Voir les endpoints du Service\ noc get endpoints httpd-demo
oc describe svc httpd-demo
```

### À retenir (EX280)
- Commande clé : `oc scale deployment <name> --replicas=N`.
- Le Service envoie le trafic vers **tous** les endpoints correspondants.

---

## S1.B5 – ConfigMap + Secret (configuration externe)

**But** : sortir la configuration du conteneur et l’injecter dans les pods.

### Concepts
- **ConfigMap** : données non sensibles (env, paramètres fonctionnels).
- **Secret** : données sensibles (mot de passe, token, clé).
- Injection classique : **variables d’environnement**.

### Commandes
```bash
# Créer une ConfigMap\ noc create configmap httpd-config \
  --from-literal=APP_ENV=ex280-lab02 \
  --from-literal=APP_OWNER=zidane

oc get configmap

# Créer un Secret générique\ noc create secret generic httpd-secret \
  --from-literal=APP_PASSWORD=S3cr3t-Ex280

oc get secret

# Injecter dans le Deployment\ noc set env deployment/httpd-demo --from=configmap/httpd-config
oc set env deployment/httpd-demo --from=secret/httpd-secret

# Voir la liste des variables configurées au niveau du Deployment\ noc set env deployment/httpd-demo --list

# Vérifier dans un pod\ noc get pods
oc exec -it <NOM_POD> -- env | grep APP_
```

### À retenir (EX280)
- Création : `oc create configmap` / `oc create secret generic`.
- Injection : `oc set env deployment/... --from=configmap/...` ou `--from=secret/...`.
- Toujours vérifier dans le pod avec `oc exec ... env`.

---

## S1.B6 – Probes (readiness / liveness)

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
# Supprimer d’éventuelles probes existantes\ noc set probe deployment/httpd-demo --readiness --remove
oc set probe deployment/httpd-demo --liveness  --remove

# Probes TCP\ noc set probe deployment/httpd-demo \
  --readiness \
  --open-tcp=8080 \
  --initial-delay-seconds=5 \
  --timeout-seconds=2

oc set probe deployment/httpd-demo \
  --liveness \
  --open-tcp=8080 \
  --initial-delay-seconds=10 \
  --timeout-seconds=2

# Vérifier sur le Deployment\ noc describe deployment httpd-demo | egrep 'Liveness|Readiness'
```

### À retenir (EX280)
- `oc set probe` permet d’ajouter/modifier/supprimer les probes.
- `--open-tcp=PORT` = probe TCP.
- Readiness = participation au Service, Liveness = redémarrage.

---

## S1.B7 – Requests / Limits (ressources)

**But** : contrôler la consommation CPU / mémoire et la qualité de service.

### Concepts
- **requests** : ressources minimales *demandées* (scheduling).
- **limits** : plafond maximal autorisé.
- Les combinaisons requests/limits déterminent la **QoS** (Guaranteed / Burstable / BestEffort).

### Commandes
```bash
# Définir requests et limits sur le Deployment\ noc set resources deployment/httpd-demo \
  --requests=cpu=50m,memory=64Mi \
  --limits=cpu=200m,memory=256Mi

# Vérifier sur le Deployment\ noc describe deployment httpd-demo | grep -A5 Limits

# Vérifier sur un Pod\ noc get pods
oc describe pod <NOM_POD> | grep -A5 Limits
```

### À retenir (EX280)
- Commande clé : `oc set resources deployment/...`.
- Différence conceptuelle : `requests` (planification) vs `limits` (plafond).

---

## S1.B8 – PVC + volume + persistance

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
# Créer le PVC\ noc apply -f pvc-httpd-data.yaml
oc get pvc

# Attacher le PVC au Deployment\ noc set volume deployment/httpd-demo \
  --add \
  --name=httpd-data \
  --type=persistentVolumeClaim \
  --claim-name=pvc-httpd-data \
  --mount-path=/var/www/html/data   # ou un chemin adapté

# Vérifier sur le Deployment\ noc describe deployment httpd-demo | grep -A5 "Volumes"

# Vérifier que le PVC est Bound\ noc get pvc
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

# Semaine 2 – Labels, annotations, LimitRange, ResourceQuota

## S2.B1 – Labels & selectors

**But** : organiser les ressources et filtrer efficacement.

### Concepts
- **Label** = paire clé/valeur utilisée pour :
  - organiser les ressources
  - sélectionner des objets (`-l`, selectors de Services/Deployments)
- Exemples : `app=httpd-demo`, `env=dev`, `tier=frontend`, `owner=zidane`.

### Commandes
```bash
# Vérifier les labels existants\ noc get deploy httpd-demo --show-labels
oc get pods --show-labels
oc get svc httpd-demo --show-labels

# Ajouter des labels métier au Deployment\ noc label deploy httpd-demo env=dev tier=frontend owner=zidane --overwrite

# Vérifier les labels
oc get deploy httpd-demo --show-labels

# Propager les labels au template de pod
oc patch deployment httpd-demo -p '{
  "spec": {
    "template": {
      "metadata": {
        "labels": {
          "env": "dev",
          "tier": "frontend",
          "owner": "zidane"
        }
      }
    }
  }
}'

# Vérifier sur les pods (après recréation si besoin)
oc get pods --show-labels

# Vérifier le selector du Service\ noc describe svc httpd-demo
```

### À retenir
- `oc label` pour ajouter/modifier des labels (`--overwrite`).
- Les labels du **template de pod** (`spec.template.metadata.labels`) sont ceux qui comptent pour les nouveaux pods.

---

## S2.B2 – Annotations (documentation des objets)

**But** : documenter les ressources (rôle, contact, ticket, etc.).

### Concepts
- **Annotation** = métadonnée libre (non utilisée pour le routage ou les selectors).
- Utile pour : description, contact support, lien vers doc, ticket Jira, etc.

### Commandes
```bash
# Ajouter des annotations\ noc annotate deploy httpd-demo description="Frontend httpd pour EX280" --overwrite
oc annotate svc httpd-demo support-contact="zidane.djamal@example.com" --overwrite

# Vérifier via describe\ noc describe deploy httpd-demo | sed -n '1,25p'
oc describe svc httpd-demo
```

### À retenir
- `oc annotate` pour les annotations.
- Lecture surtout via `oc describe`.

---

## S2.B3 – Listes & filtres avancés (-l, -L, --field-selector)

**But** : naviguer dans un projet chargé uniquement via CLI.

### Concepts
- `-L` = afficher des labels en colonnes.
- `-l` = filtrer sur les labels.
- `--field-selector` = filtrer sur des champs internes (status.phase, metadata.name, etc.).

### Commandes
```bash
# Afficher les labels en colonnes\ noc get pods -L app,env,tier,owner
oc get svc  -L app,env,tier,owner

# Filtres par labels\ noc get pods -l app=httpd-demo
oc get pods -l env=dev,tier=frontend
oc get pods -l app=autre-chose

# Filtres par champs (status.phase)
oc get pods --field-selector status.phase=Running
oc get pods --field-selector status.phase=Pending
```

### À retenir
- `-l` = filtre sur **labels** (que tu contrôles).
- `--field-selector` = filtre sur des champs système (status, metadata...).

---

## S2.B4 – LimitRange : defaults CPU / mémoire

**But** : définir des valeurs par défaut de requests/limits pour les conteneurs **qui n’en déclarent pas**.

### Concepts
- **LimitRange** au niveau du namespace :
  - impose des valeurs par défaut (defaultRequest / default)
  - éventuellement des min/max (non utilisés ici)
- N’impacte **pas** les pods existants ni ceux qui ont déjà des resources.

### YAML LimitRange
```yaml
apiVersion: v1
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

### Commandes
```bash
# Créer le LimitRange\ noc apply -f limitrange-basic.yaml
oc get limitrange
oc describe limitrange basic-limits
```

Exemple de sortie :
```text
Type        Resource  Min  Max  Default Request  Default Limit
----        --------  ---  ---  ---------------  -------------
Container   cpu       -    -    50m              200m
Container   memory    -    -    64Mi             256Mi
```

### Tester l’effet
```bash
# Créer un Deployment SANS resources\ noc create deployment demo-nores \
  --image=registry.access.redhat.com/ubi8/httpd-24

# Vérifier les pods\ noc get pods -l app=demo-nores

# Voir les ressources injectées\ noc describe pod -l app=demo-nores | sed -n '/Limits:/,/Environment:/p'
```

### À retenir
- LimitRange n’agit que sur les **nouveaux** pods sans resources déclarées.
- Il injecte les valeurs `defaultRequest` (requests) et `default` (limits).

---

## S2.B5 – ResourceQuota : budget CPU / mémoire / pods

**But** : limiter le “budget” de ressources d’un namespace.

### Concepts
- **ResourceQuota** compte l’utilisation (`Used`) et compare au plafond (`Hard`).
- Si une création ou un scale dépasse le plafond → l’API refuse la requête (`Forbidden: exceeded quota`).

### YAML ResourceQuota
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

### Commandes
```bash
# Créer le quota\ noc apply -f resourcequota-basic.yaml
oc get resourcequota
oc describe resourcequota compute-quota
```

Exemple de sortie (extrait) :
```text
Resource         Used   Hard
--------         ----   ----
limits.cpu       400m   500m
limits.memory    512Mi  640Mi
pods             2      4
requests.cpu     100m   200m
requests.memory  128Mi  256Mi
```

### Dépasser le quota (test)
```bash
# Tentative de création d’un pod supplémentaire\ noc run quota-test \
  --image=registry.access.redhat.com/ubi8/httpd-24 \
  --restart=Never
```

Erreur typique :
```text
Error from server (Forbidden): pods "quota-test" is forbidden: exceeded quota: compute-quota, requested: ..., used: ..., limited: ...
```

### Libérer des ressources et voir l’effet
```bash
# Réduire des deployments pour libérer des ressources\ noc scale deployment demo-nores --replicas=0

# Vérifier les pods restants\ noc get pods

# Vérifier le quota après coup\ noc describe resourcequota compute-quota
```

### À retenir
- ResourceQuota = **budget** par namespace.
- En cas de dépassement → l’API refuse la création/scale.
- Les champs `Used` sont recalculés à chaque création/suppression/scale de pod.

---

## S2.B6 – Synthèse Semaine 2

### À savoir par cœur (version examen)

**Labels / selectors**
```bash
oc get pods --show-labels
oc get pods -L app,env,tier,owner
oc get pods -l app=httpd-demo,env=dev,tier=frontend
```

**Annotations**
```bash
oc annotate deploy httpd-demo description="..." --overwrite
oc annotate svc httpd-demo support-contact="..." --overwrite
# Lecture via\ noc describe deploy httpd-demo
oc describe svc httpd-demo
```

**LimitRange**
- YAML `kind: LimitRange`, type `Container`.
- `defaultRequest` + `default` injectés sur les **nouveaux** pods sans resources.

**ResourceQuota**
- YAML `kind: ResourceQuota`.
- `oc describe resourcequota` pour voir `Used` vs `Hard`.
- Erreur `Forbidden (exceeded quota)` en cas de dépassement.

---

Fin du récap **Semaine 1 & 2**.  
Ce document sert de **polycopié EX280** pour tes labs CLI sur `ex280-lab02`.  
Tu peux l’enrichir avec tes propres notes (exemples d’erreurs, sorties réelles, captures).


