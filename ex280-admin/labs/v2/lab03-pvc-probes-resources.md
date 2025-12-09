# Lab03 — PVC, Probes, Resources & (option) PV manuel

## Objectif

- Créer un PVC.
- Monter le PVC dans un pod httpd.
- Configurer requests/limits CPU/mémoire.
- Ajouter liveness/readiness probes.
- (Option) Créer un PV manuel (hostPath) pour comprendre le binding.

## Pré-requis

- Lab02 OK.

---

## Partie A — PVC + Deployment + Probes

### Step A1 — Projet

    oc get project ex280-lab03-pvc-zidane || oc new-project ex280-lab03-pvc-zidane
    oc project ex280-lab03-pvc-zidane

### Step A2 — PVC

    cat << 'YAML' | oc apply -f -
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: web-pvc
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
    YAML

    oc get pvc
    oc describe pvc web-pvc

### Step A3 — Deployment avec PVC + probes + ressources

    cat << 'YAML' | oc apply -f -
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web-pvc
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: web-pvc
      template:
        metadata:
          labels:
            app: web-pvc
        spec:
          containers:
          - name: httpd
            image: registry.access.redhat.com/ubi8/httpd-24
            ports:
            - containerPort: 8080
            resources:
              requests:
                cpu: "100m"
                memory: "128Mi"
              limits:
                cpu: "200m"
                memory: "256Mi"
            livenessProbe:
              httpGet:
                path: /
                port: 8080
              initialDelaySeconds: 10
              periodSeconds: 10
            readinessProbe:
              httpGet:
                path: /
                port: 8080
              initialDelaySeconds: 5
              periodSeconds: 5
            volumeMounts:
            - name: web-data
              mountPath: /var/www/html
          volumes:
          - name: web-data
            persistentVolumeClaim:
              claimName: web-pvc
    YAML

    oc get pods
    oc describe pod -l app=web-pvc

---

## Partie B — (Option) PV manuel (hostPath) pour CRC

> À utiliser si tu veux comprendre le lien PV/PVC. Peut casser si les permissions hostPath sont mauvaises.

### Step B1 — Créer un PV hostPath (sur CRC)

    cat << 'YAML' | oc apply -f -
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: ex280-lab03-pv-manual
    spec:
      capacity:
        storage: 1Gi
      accessModes:
        - ReadWriteOnce
      hostPath:
        path: /mnt/ex280-lab03-pv-manual
      persistentVolumeReclaimPolicy: Delete
    YAML

    oc get pv
    oc describe pv ex280-lab03-pv-manual

### Step B2 — Lier le PVC au PV

    # Ajuster le PVC si besoin pour matcher la storageClass / mode
    oc describe pvc web-pvc

    # Vérifier que le PVC passe à Bound sur le PV manuel
    oc get pvc
    oc describe pvc web-pvc

---

## Vérifications

    oc get pvc
    oc describe pvc web-pvc
    oc get pods
    oc describe pod -l app=web-pvc
    oc logs -l app=web-pvc || true

Critères :

- PVC `web-pvc` en `Bound`
- Pod `web-pvc` en `Running`
- Pas de redémarrages répétés (probes OK)

---

## Cleanup (optionnel)

    oc delete project ex280-lab03-pvc-zidane --ignore-not-found
    # Si PV manuel créé :
    # oc delete pv ex280-lab03-pv-manual --ignore-not-found

---

## Pièges fréquents

- PVC `Pending` → `oc describe pvc web-pvc`
- Probes trop agressives → augmenter `initialDelaySeconds`
- PV hostPath : attention aux permissions sur le nœud
