# Lab 01 — Build S2I depuis Git

## Remplace l'URL Git
sed -i 's#REPLACE_WITH_YOUR_REPO_URL#https://github.com/zdmooc/openshift-ex288.git#g' manifests/bc-is.yaml

## Appliquer
oc apply -n ex288 -f manifests/bc-is.yaml

## Lancer un build
oc start-build ex288 -n ex288 --follow

## Vérif
oc get is,bc,build -n ex288
