# LAB-00-01 – Révision EX280 en mode “warm-up”

- **Bloc** : Prérequis
- **Durée cible** : 45 min
- **Objectif** : se remettre en main OpenShift admin de base (EX280).

## 1. Objectifs pédagogiques

- Créer un projet de travail.
- Déployer une app stateless simple.
- L’exposer via Service + Route.
- Ajouter ConfigMap, Secret, probes, ressources, PVC.

## 2. Énoncé (mode examen)

1. Crée un projet `ex380-warmup`.
2. Déploie une application HTTP simple depuis une image UBI ou nginx.
3. Expose-la via un Service et une Route accessible depuis ton poste.
4. Externalise un paramètre de configuration via ConfigMap et une donnée sensible via Secret.
5. Ajoute des probes (liveness/readiness) et des ressources (requests/limits).
6. Monte un PVC de 1Gi en `ReadWriteOnce` et vérifie la persistance d’un fichier.

## 3. Implémentation pas à pas

### 3.1. Projet et déploiement

```bash
oc new-project ex380-warmup

oc new-app --name=http-demo   --image=registry.access.redhat.com/ubi8/httpd-24

oc expose svc/http-demo
```

### 3.2. ConfigMap + Secret

```bash
oc create configmap http-config   --from-literal=APP_MESSAGE="Hello EX380"

oc create secret generic http-secret   --from-literal=APP_PASSWORD="S3cret-EX380"
```

Patch du déploiement pour injecter variables d’environnement :

```bash
oc set env deploy/http-demo   --from=configmap/http-config   --from=secret/http-secret
```

### 3.3. Probes et ressources

```bash
oc set probe deploy/http-demo   --liveness --get-url=http://:8080/ --initial-delay-seconds=10 --timeout-seconds=1

oc set probe deploy/http-demo   --readiness --get-url=http://:8080/ --initial-delay-seconds=5 --timeout-seconds=1

oc set resources deploy/http-demo   --requests=cpu=100m,memory=128Mi   --limits=cpu=500m,memory=256Mi
```

### 3.4. PVC + persistance

```bash
cat <<'EOF' | oc apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: http-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
```

Patch du déploiement :

```bash
oc set volume deploy/http-demo   --add --name=http-storage   --mount-path=/var/www/html/data   --claim-name=http-pvc
```

## 4. Vérifications

```bash
oc get pods
oc get route http-demo -o wide
curl -k http://$(oc get route http-demo -o jsonpath='{.spec.host}')
```

## 5. Points clés

- Réflexes EX280 (projet, app, route, config, secret, PVC).
- Base solide pour les labs avancés EX380.
