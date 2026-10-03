# API REST

Base : `/api/v1`

- POST `/auth/register`
- POST `/auth/login`
- GET/POST/PUT/DELETE `/subjects`
- GET/POST/PUT/DELETE `/tasks`
- GET `/dashboard`

Routes protégées : `Authorization: Bearer <JWT>`.

Les ressources sont toujours recherchées avec `ownerId` afin d'assurer l'isolation entre étudiants.
