```mermaid
classDiagram
direction LR

class Cluster { nom }
class Master
class Infra
class Node
class Serveur {
  hostname
  IP
}

Serveur <|-- Master
Serveur <|-- Infra
Serveur <|-- Node

Cluster *-- "1..3" Master : contient
Cluster *-- "1..*" Node : contient
Cluster *-- "1..*" Infra : contient

class Projet {
  nom_namespace
  ressources_allouees
}
Cluster *-- "1..*" Projet : héberge

class Produit { nom }
class Environnement
Projet --> Produit : est_associe_a
Projet --> Environnement : est_associe_a

class ConfigMap { MapCleValeur }
class DeploymentConfig
class Pod { port }
class Conteneur
class Service {
  ip
  port
}
class Route
class NomDNSApplicatif
class NomDNSTechnique
class VIP

Projet *-- "0..n" Service
Projet *-- "0..n" Route
Projet *-- "1..*" ConfigMap
Projet *-- "1..*" DeploymentConfig
Projet *-- "0..n" Pod

Node "1" <-- "0..n" Pod : s_execute_sur
Pod --> "0..n" ConfigMap : utilise
DeploymentConfig --> "1..n" Pod : decrit
Service --> "0..n" Pod : pointe_vers
Route --> Service : expose
Route *-- NomDNSApplicatif
NomDNSApplicatif .. NomDNSTechnique : alias
Route .. VIP : pointe_vers

note for Service "exemple : personnes-physiques-backend"
note for NomDNSApplicatif "<service>.<env>.<produit>.apps.maif.local"
note for NomDNSTechnique "*.apps.<nom_cluster>.maif.local"
