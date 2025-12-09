Voici un fichier Markdown prêt à l’emploi.

# Taints & Tolerations — Guide concis

But: contrôler où les pods s’exécutent.  
Principe: **taint** sur le nœud = répulsion. **toleration** sur le pod = exception autorisée.

---

## 1) Vocabulaire

- **Taint**: clé=valeur + effet. Ex: `role=ingress:NoSchedule`.
- **Effets**:
  - `NoSchedule`: pas de nouveaux pods sans tolérance.
  - `PreferNoSchedule`: évite si possible.
  - `NoExecute`: éjection des pods non tolérés + bloque les nouveaux.
- **Toleration** (côté pod):
  - `key`, `operator` (`Equal` ou `Exists`), `value`, `effect`, `tolerationSeconds` (pour `NoExecute`).

---

## 2) Schéma conceptuel

```mermaid
flowchart TB

subgraph N1[Node N1]
  T1[Taint: role=ingress:NoSchedule]
end

subgraph N2[Node N2]
  T2[Pas de taint]
end

subgraph P[Pods]
  PA[Pod A<br/>sans toleration]
  PB[Pod B<br/>toleration: role=ingress]
end

PA -.X.- N1:::blocked
PA --> N2

PB --> N1
PB --> N2

classDef blocked stroke:#f00,stroke-width:2px,color:#f00;


Lecture:

N1 a un taint role=ingress:NoSchedule.

Pod A ne tolère pas → rejeté de N1.

Pod B tolère → admissible sur N1 et N2.

3) Taints vs Labels (attraction vs répulsion)
flowchart LR
subgraph Nodes
  A[Node label: node-role=infra]
  B[Node label: node-role=worker]
end

subgraph Policies
  L[Label/Selector = attraction]
  T[Taint = répulsion]
end

L --> A
L --> B
T -. bloque .- A


Labels/Selectors/Affinity choisissent des cibles préférées.

Taints/Tolerations interdisent par défaut, sauf exception.

4) Commandes clés (oc)
# Lister taints et labels d’un nœud
oc describe node <node> | egrep "Taints|Labels"

# Poser un taint (ex: réserver ingress)
oc taint node <node> role=ingress:NoSchedule

# Retirer un taint
oc taint node <node> role-  # le tiret final supprime la clé 'role'

# Marquer infra via label (facilite selectors/affinity)
oc label node <node> node-role.kubernetes.io/infra="true" --overwrite

# Vérifier le scheduling récent
oc get events -A --sort-by=.lastTimestamp | tail -n 50

5) Exemples YAML
5.1 Pod avec toleration (NoSchedule)
apiVersion: v1
kind: Pod
metadata:
  name: app-on-ingress
spec:
  tolerations:
    - key: "role"
      operator: "Equal"
      value: "ingress"
      effect: "NoSchedule"
  containers:
    - name: app
      image: registry.k8s.io/pause:3.9

5.2 Pod tolère NoExecute (éviction temporisée)
apiVersion: v1
kind: Pod
metadata:
  name: keep-during-disruption
spec:
  tolerations:
    - key: "role"
      operator: "Exists"
      effect: "NoExecute"
      tolerationSeconds: 300  # reste max 5 min avant éviction
  containers:
    - name: app
      image: registry.k8s.io/pause:3.9

5.3 Cibler des nœuds via labels (nodeSelector + tolerations)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      nodeSelector:
        node-role.kubernetes.io/infra: "true"
      tolerations:
        - key: "role"
          operator: "Equal"
          value: "ingress"
          effect: "NoSchedule"
      containers:
        - name: nginx
          image: nginx:1.27

5.4 Affinity/Anti-affinity (préférence et contraintes)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: node-role.kubernetes.io/worker
                    operator: In
                    values: ["true"]
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 50
              preference:
                matchExpressions:
                  - key: topology.kubernetes.io/zone
                    operator: In
                    values: ["zone-a"]
      containers:
        - name: api
          image: registry.k8s.io/pause:3.9

6) Cas d’usage

Nœuds Ingress/Infra: taint role=ingress:NoSchedule; seules les workloads infra déclarent la tolérance.

Nœuds stockage: taint storage=dedicated:NoSchedule; seuls drivers/DB tolèrent.

Dégradations temporaires: NoExecute côté nœud force l’éviction des pods non tolérés.

7) Débogage rapide
# Voir pourquoi un pod ne schedule pas
oc describe pod <pod> | egrep -i "Tolerations|Taints|Events|nodeAffinity"

# Vérifier matching des tolerations
oc get pod <pod> -o jsonpath='{.spec.tolerations}{"\n"}'

# Lister tous les taints sur tous les nœuds
oc get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"  "}{.spec.taints}{"\n"}{end}'

8) Bonnes pratiques

Réserver les nœuds “techniques” par taints.

Toujours combiner labels/affinity (où aller) + tolerations (où autorisé).

Documenter les clés standard: role=ingress, role=infra, storage=dedicated, etc.

Nettoyer les taints obsolètes (oc taint node <node> key-).

Tester le comportement avec un petit Deployment avant généralisation.


::contentReference[oaicite:0]{index=0}
