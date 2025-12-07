# Chapitre 0 - Pourquoi OpenShift et comment raisonner “projet/namespace”

## But
Comprendre le modèle OpenShift pour ne jamais “se perdre” pendant les labs et l’examen.

## Concepts
- Cluster / API / contexte `oc`
- Project = Namespace (avec des politiques OpenShift)
- Workloads, Services, Routes

![Figure 1 - Vue d’ensemble : du compte utilisateur jusqu’à l’accès externe](resources/images/fig-01-overview.svg)


## Commandes (réflexes)
```bash
oc whoami
oc project
oc projects
oc get nodes
oc api-resources --namespaced=true
```

## À retenir
- Vérifier son **projet courant** avant toute action.



