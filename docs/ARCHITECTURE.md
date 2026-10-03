# Architecture

## Backend
`api` → `service` → `repository` → PostgreSQL.  
`domain` contient les entités et enums. `security` centralise JWT et l'identité authentifiée. `exception` centralise les réponses d'erreur.

## Mobile
`core` : réseau, configuration, stockage.  
`models` : modèles.  
`repositories` : accès API.  
`screens` : interface.

## Principes
- séparation des responsabilités ;
- DTO ;
- validation ;
- isolation par utilisateur ;
- configuration externalisée ;
- conteneur non root ;
- PostgreSQL persistant.
