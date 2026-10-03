# Architecture

## Backend
`api` → `service` (interfaces) / `service.impl` (implémentations) → `repository` → PostgreSQL.  
`domain` contient les entités et enums. `security` centralise JWT et l'identité authentifiée. `exception` centralise les réponses d'erreur.

## Mobile
`core` : réseau, configuration, stockage.  
`models` : modèles.  
`repositories` : accès API.  
`screens` : interface.

## Principes
- séparation des responsabilités et découplage (DIP - SOLID via interfaces de services) ;
- DTO ;
- validation ;
- isolation par utilisateur ;
- configuration externalisée ;
- conteneur non root ;
- PostgreSQL persistant.
