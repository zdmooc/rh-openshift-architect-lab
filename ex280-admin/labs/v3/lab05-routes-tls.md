# Lab 05 — Routes & TLS: edge/reencrypt/passthrough, certificats, sécuriser le trafic


## Objectifs EX280 couverts
- Créer/éditer des routes externes
- Exposer des applications à l’accès externe
- Sécuriser trafic externe et interne avec certificats TLS

## Prérequis
```bash
export LAB=05
export NS=ex280-lab${LAB}-zidane
oc new-project "$NS"
```

## Tâches
### 1) Déployer une appli HTTP simple
```bash
oc new-app --name=httpd --image=registry.access.redhat.com/ubi9/httpd-24
oc rollout status deploy/httpd
oc expose svc/httpd
oc get route httpd
```

### 2) Route “edge” (TLS terminé au routeur)
Générer un certificat auto-signé (local) :
```bash
openssl req -x509 -newkey rsa:2048 -nodes -keyout tls.key -out tls.crt -days 365   -subj "/CN=httpd.${NS}.apps.example.invalid"
```
Appliquer sur la route (edge) :
```bash
oc patch route httpd --type merge -p '{
  "spec":{
    "tls":{
      "termination":"edge",
      "certificate":"'$(awk '{printf "%s\n",$0}' tls.crt)'",
      "key":"'$(awk '{printf "%s\n",$0}' tls.key)'",
      "insecureEdgeTerminationPolicy":"Redirect"
    }
  }
}'
oc get route httpd -o yaml | sed -n '1,120p'
```

Test (selon ton cluster, l’URL réelle est `.spec.host`) :
```bash
HOST=$(oc get route httpd -o jsonpath='{.spec.host}')
echo "$HOST"
curl -kI "https://$HOST" | head
curl -I  "http://$HOST" | head
```

### 3) Route “passthrough” (TLS de bout en bout, SNI)
> Utile pour applis qui terminent TLS elles-mêmes (ex: services TLS natifs).  
Dans un environnement local, tu peux surtout pratiquer la config de la route.

Exemple (générique) :
```bash
oc create route passthrough tls-app --service=httpd --port=8080
oc patch route tls-app --type merge -p '{"spec":{"tls":{"termination":"passthrough"}}}'
oc get route tls-app -o yaml | sed -n '1,120p'
```

### 4) Route “reencrypt” (TLS au routeur + TLS vers le service)
> Demande un **certificat de destination** (CA) côté routeur pour vérifier le service backend.
Dans un environnement d’entraînement, tu peux pratiquer :
- création d’un secret `destination-ca`
- patch `spec.tls.destinationCACertificate`

## Vérifications
- `oc get route` montre la route `httpd` en TLS edge.
- HTTP redirige vers HTTPS (Redirect).
- `curl -kI https://$HOST` renvoie 200/30x cohérent.

## Nettoyage
```bash
oc delete project "$NS"
rm -f tls.key tls.crt
```
