# CampusTasks — Projet Licence 3

Application mobile de gestion des tâches étudiantes — Flutter / Spring Boot / PostgreSQL / Docker.

## Démarrage

```bash
cp .env.example .env
docker compose -f deployment/compose.yaml up -d --build
```

API : http://localhost:8080  
Swagger : http://localhost:8080/swagger-ui.html

## Backend
```bash
cd backend
mvn test
mvn spring-boot:run
```

## Mobile
```bash
cd mobile
flutter pub get
flutter analyze
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

## CI/CD
Pull Request : tests Maven + analyse Flutter.  
Tag `v1.0.0` : build et publication Docker Hub.

Secrets GitHub requis : `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`.

## Important
Ne jamais versionner `.env`, secrets, tokens, keystore Android ou mots de passe.
Consulter `docs/DELIVERABLES_CHECKLIST.md` avant la soutenance.
