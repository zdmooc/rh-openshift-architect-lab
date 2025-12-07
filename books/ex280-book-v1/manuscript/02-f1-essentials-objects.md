# Chapitre 1 - Objets essentiels : modèle mental

## But
Savoir ce que tu manipules (et pourquoi) : Pod, Deployment, Service, Route, ConfigMap, Secret.

![Figure 2 - Objets de base et rôle de chacun](resources/images/fig-01-overview.svg)


## Concepts
- Deployment gère le cycle de vie ; Pods sont éphémères
- Service donne un point d’accès stable
- Route expose hors cluster (HTTP/HTTPS)
- ConfigMap/Secret externalisent config et credentials

## Schéma “de bout en bout”
![Figure 3 - Du manifeste au pod prêt](resources/images/fig-03-deploy-workflow.svg)


## Vérifications
```bash
oc get deploy,rs,pod,svc,route
oc describe pod <pod>
```






