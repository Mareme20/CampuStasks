# Déploiement

## Préparation
Installer Docker. Créer `.env` sur le serveur.

```env
DOCKERHUB_USERNAME=mon-compte
APP_VERSION=1.0.0
POSTGRES_DB=campus_tasks
POSTGRES_USER=campus
POSTGRES_PASSWORD=mot_de_passe_fort
JWT_SECRET=secret_long_et_aleatoire
```

## Lancement
```bash
docker compose -f deployment/compose.prod.yaml pull
docker compose -f deployment/compose.prod.yaml up -d
docker compose ps
docker compose logs -f api
```

PostgreSQL n'est pas publié sur Internet. Utiliser un reverse proxy Nginx/Caddy pour HTTPS.

## Mise à jour
Changer `APP_VERSION` vers une image précise puis :
```bash
docker compose -f deployment/compose.prod.yaml pull
docker compose -f deployment/compose.prod.yaml up -d
```

## Rollback
Revenir à une image précédente en tenant compte des éventuelles migrations de schéma.

## Sauvegarde
```bash
docker exec campus-tasks-postgres pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > backup.sql
```
