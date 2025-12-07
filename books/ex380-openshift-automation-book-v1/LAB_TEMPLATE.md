# LAB TEMPLATE – EX380

- **Code lab** : LAB-XX
- **Bloc EX380** : (Auth / OADP / Partitioning / Scheduling / GitOps / Monitoring / Logging)
- **Durée cible** : 45–90 min
- **Cluster** : ocp4-lab (ou crc, ou ROSA/ARO)
- **Contrainte** : CLI-first, pas d’UI Web sauf mention contraire

## 1. Objectifs pédagogiques

À la fin du lab, tu seras capable de :

1. …
2. …
3. …

## 2. Pré-requis

- Cluster OpenShift 4.14+ accessible.
- `oc` configuré et authentifié avec un compte admin.
- Projet de travail si nécessaire : `ex380-<bloc>-lab`.

## 3. Énoncé (vue “type examen”)

1. …
2. …
3. …

> Pendant la partie “examen”, ne pas regarder la correction détaillée ci-dessous.

## 4. Plan d’attaque (checklist)

- [ ] Étape 1 – …
- [ ] Étape 2 – …
- [ ] Étape 3 – …
- [ ] Vérifications finales.

## 5. Implémentation pas à pas (avec commandes)

### 5.1. Préparation

```bash
oc whoami
oc get nodes
oc new-project ex380-demo || oc project ex380-demo
```

### 5.2. Étapes principales

_Détailler ici les commandes `oc`, YAML, CR, etc._

### 5.3. Vérifications

```bash
oc get all -n ex380-demo
```

## 6. Nettoyage

```bash
oc delete project ex380-demo
```

## 7. Points clés à retenir

- …
- …
- …

## 8. Variante “hard mode”

- Variante A : refaire le lab uniquement avec des manifests YAML + `oc apply -f`.
- Variante B : automatiser une partie avec un script Bash ou un playbook Ansible.
