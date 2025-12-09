# Lab 03 — ConfigMaps & Secrets: création, montage (env/volume), mise à jour


## Objectifs EX280 couverts
- Créer et utiliser des secrets
- Créer et utiliser des configuration maps
- Appliquer des secrets pour gérer des infos sensibles

## Prérequis
```bash
export LAB=03
export NS=ex280-lab${LAB}-zidane
oc new-project "$NS"
```

## Tâches
### 1) ConfigMap depuis literals + fichier
```bash
oc create configmap app-config   --from-literal=APP_MODE=dev   --from-literal=APP_COLOR=blue
oc get cm app-config -o yaml | sed -n '1,120p'
```

Créer un fichier local `message.txt` :
```bash
echo "Bonjour EX280" > message.txt
oc create configmap app-message --from-file=message.txt
oc get cm app-message -o yaml | sed -n '1,120p'
```

### 2) Secret (generic) + vérification
```bash
oc create secret generic app-secret   --from-literal=DB_USER=odmuser   --from-literal=DB_PASS='devsecops'
oc get secret app-secret -o yaml | sed -n '1,80p'
```

### 3) Utiliser ConfigMap/Secret via variables d’environnement
Déployer un pod qui expose ses env :
```bash
cat <<'YAML' | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: env-printer
spec:
  containers:
  - name: env-printer
    image: registry.access.redhat.com/ubi9/ubi-minimal
    command: ["/bin/sh","-c"]
    args:
      - |
        echo "== ENV ==";
        env | sort;
        sleep 3600
    envFrom:
      - configMapRef:
          name: app-config
      - secretRef:
          name: app-secret
YAML
oc wait --for=condition=Ready pod/env-printer --timeout=120s
oc logs env-printer | head -n 60
```

### 4) Monter ConfigMap comme volume
```bash
cat <<'YAML' | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cm-volume
spec:
  containers:
  - name: cm-volume
    image: registry.access.redhat.com/ubi9/ubi-minimal
    command: ["/bin/sh","-c"]
    args:
      - |
        echo "== FILE ==";
        cat /etc/config/message.txt;
        sleep 3600
    volumeMounts:
      - name: cfg
        mountPath: /etc/config
  volumes:
    - name: cfg
      configMap:
        name: app-message
YAML
oc wait --for=condition=Ready pod/cm-volume --timeout=120s
oc logs cm-volume
```

### 5) Mise à jour: patcher la ConfigMap et observer
```bash
oc patch cm app-config --type merge -p '{"data":{"APP_COLOR":"green"}}'
oc exec env-printer -- sh -c 'echo $APP_COLOR'
```
> Selon la façon dont l’application lit les env, il peut être nécessaire de redéployer le pod pour refléter le changement (env = injecté au démarrage).  
> Pour un volume ConfigMap, la mise à jour peut se propager (avec délai).

## Vérifications
- `env-printer` contient bien les clés de `app-config` et `app-secret`.
- `cm-volume` lit le fichier depuis le volume ConfigMap.

## Nettoyage
```bash
oc delete project "$NS"
```
