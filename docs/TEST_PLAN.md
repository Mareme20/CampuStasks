# Plan de tests

| ID | Vérification | Attendu |
|---|---|---|
| T01 | Inscription | Compte créé |
| T02 | Connexion | JWT |
| T03 | Matière | CRUD fonctionnel |
| T04 | Tâche | CRUD fonctionnel |
| T05 | Filtre | Résultats corrects |
| T06 | Compte A → données B | Accès refusé |
| T07 | Redémarrage Docker | Données conservées |
| T08 | APK | API distante joignable |
| T09 | PR | CI verte |
| T10 | Tag v1.0.0 | Image publiée |

Preuves : Swagger, comptes A/B, Docker Compose, logs, GitHub Actions, Docker Hub et APK.
