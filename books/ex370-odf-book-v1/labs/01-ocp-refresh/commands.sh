#!/usr/bin/env bash
set -euo pipefail

echo "=== Contexte courant ==="
oc whoami
oc config get-contexts

echo "=== Projets ==="
oc projects

echo "=== Création projet de labo ==="
oc new-project ex370-lab01 || oc project ex370-lab01

echo "=== Déploiement appli de test ==="
oc create deployment hello --image=registry.access.redhat.com/ubi8/ubi --dry-run=client -o yaml | oc apply -f -
oc expose deployment hello --port=8080 --dry-run=client -o yaml | oc apply -f -
oc expose svc/hello

echo "=== Ressources dans le projet ==="
oc get all -n ex370-lab01

echo "=== Events ==="
oc get events -n ex370-lab01 | tail -n 20
