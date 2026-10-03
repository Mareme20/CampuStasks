# Android

Générer les fichiers Android officiels avec :

```bash
flutter create --platforms=android .
```

Ajouter Internet dans `android/app/src/main/AndroidManifest.xml`.

APK de test :
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.sn/api/v1
```

Pour la signature réelle, créer le keystore hors dépôt et configurer `key.properties`.
Ne jamais publier la clé de signature.
