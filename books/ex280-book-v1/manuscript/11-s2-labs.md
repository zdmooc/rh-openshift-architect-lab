# Semaine 2 - Labels, annotations, LimitRange, ResourceQuota

## S2.B1 - Labels & selectors

**But** : organiser les ressources et filtrer efficacement.

### Concepts
- **Label** = paire clé/valeur utilisée pour :
  - organiser les ressources
  - sélectionner des objets (`-l`, selectors de Services/Deployments)
- Exemples : `app=httpd-demo`, `env=dev`, `tier=frontend`, `owner=zidane`.

### Commandes
```bash
# Vérifier les labels existants
#  get deploy httpd-demo --show-labels
oc get pods --show-labels
oc get svc httpd-demo --show-labels

# Ajouter des labels métier au Deployment
#  label deploy httpd-demo env=dev tier=frontend owner=zidane --overwrite

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

# Vérifier le selector du Service
#  describe svc httpd-demo
```

### À retenir
- `oc label` pour ajouter/modifier des labels (`--overwrite`).
- Les labels du **template de pod** (`spec.template.metadata.labels`) sont ceux qui comptent pour les nouveaux pods.

---

## S2.B2 - Annotations (documentation des objets)

**But** : documenter les ressources (rôle, contact, ticket, etc.).

### Concepts
- **Annotation** = métadonnée libre (non utilisée pour le routage ou les selectors).
- Utile pour : description, contact support, lien vers doc, ticket Jira, etc.

### Commandes
```bash
# Ajouter des annotations
#  annotate deploy httpd-demo description="Frontend httpd pour EX280" --overwrite
oc annotate svc httpd-demo support-contact="zidane.djamal@example.com" --overwrite

# Vérifier via describe
#  describe deploy httpd-demo | sed -n '1,25p'
oc describe svc httpd-demo
```

### À retenir
- `oc annotate` pour les annotations.
- Lecture surtout via `oc describe`.

---

## S2.B3 - Listes & filtres avancés (-l, -L, --field-selector)

**But** : naviguer dans un projet chargé uniquement via CLI.

### Concepts
- `-L` = afficher des labels en colonnes.
- `-l` = filtrer sur les labels.
- `--field-selector` = filtrer sur des champs internes (status.phase, metadata.name, etc.).

### Commandes
```bash
# Afficher les labels en colonnes
#  get pods -L app,env,tier,owner
oc get svc  -L app,env,tier,owner

# Filtres par labels
#  get pods -l app=httpd-demo
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

## S2.B4 - LimitRange : defaults CPU / mémoire

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
# Créer le LimitRange
#  apply -f limitrange-basic.yaml
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
# Créer un Deployment SANS resources
#  create deployment demo-nores \
  --image=registry.access.redhat.com/ubi8/httpd-24

# Vérifier les pods
#  get pods -l app=demo-nores

# Voir les ressources injectées
#  describe pod -l app=demo-nores | sed -n '/Limits:/,/Environment:/p'
```

### À retenir
- LimitRange n’agit que sur les **nouveaux** pods sans resources déclarées.
- Il injecte les valeurs `defaultRequest` (requests) et `default` (limits).

---

## S2.B5 - ResourceQuota : budget CPU / mémoire / pods

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
# Créer le quota
#  apply -f resourcequota-basic.yaml
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
# Tentative de création d’un pod supplémentaire
#  run quota-test \
  --image=registry.access.redhat.com/ubi8/httpd-24 \
  --restart=Never
```

Erreur typique :
```text
Error from server (Forbidden): pods "quota-test" is forbidden: exceeded quota: compute-quota, requested: ..., used: ..., limited: ...
```

### Libérer des ressources et voir l’effet
```bash
# Réduire des deployments pour libérer des ressources
#  scale deployment demo-nores --replicas=0

# Vérifier les pods restants
#  get pods

# Vérifier le quota après coup
#  describe resourcequota compute-quota
```

### À retenir
- ResourceQuota = **budget** par namespace.
- En cas de dépassement → l’API refuse la création/scale.
- Les champs `Used` sont recalculés à chaque création/suppression/scale de pod.

---

## S2.B6 - Synthèse Semaine 2

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
# Lecture via
#  describe deploy httpd-demo
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







