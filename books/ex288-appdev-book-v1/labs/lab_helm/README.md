# lab_helm – IBM ODM Developer Edition sur OpenShift CRC

## Prérequis
- OpenShift CRC démarré, `oc login` effectué (cluster admin recommandé).
- `helm` installé.
- Ressources CRC suffisantes (idéal: 10–12 Go RAM alloués à la VM).

## Installation
```bash
cd lab_helm
bash install.sh
bash verify.sh

https://odm-dev.<votre-domaine-apps>

Sur CRC, le domaine ressemble à apps-crc.testing.

Paramètres clés dans values.yaml

license: accept obligatoire.

service.enableRoute: true pour exposer via Route.

service.hostname injecté automatiquement par install.sh si vide.

serviceAccountName: odm-dev-sa + SCC anyuid appliquée par le script.

Désinstallation
bash uninstall.sh

Notes

Cette édition est destinée au développement. Non supportée pour la production.

Les images et tags par défaut du chart IBM sont utilisés; inutile de les surcharger.


---

### Utilisation
1) Créez un dossier local `lab_helm/` et placez **ces 4 fichiers** dedans.  
2) Ouvrez un terminal, puis:
```bash
cd lab_helm
bash install.sh
bash verify.sh


Ouvrez l’URL de la Route affichée.

Voici les URLs. Remplace <HOST> par l’hôte de ta Route OpenShift.

Decision Center : https://<HOST>/decisioncenter. 
IBM

Decision Server Console (RES) : https://<HOST>/res. 
IBM

Decision Runner : https://<HOST>/DecisionRunner. 
community.ibm.com

Decision Service REST v1 : https://<HOST>/DecisionService/rest/v1/<ruleset_path>. 
IBM

Decision Service SOAP/HTDS (WSDL) : https://<HOST>/DecisionService/ws/<ruleset_path>?wsdl. 
IBM

Récupérer l’hôte de la Route créée par le chart :

oc -n lab-helm get route -o jsonpath='{range .items[*]}{.spec.host}{"\n"}{end}'