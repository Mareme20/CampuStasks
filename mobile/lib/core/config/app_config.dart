import 'dart:io';

/// Configuration globale de l'application mobile.
/// Permet de définir l'URL de base de l'API backend, configurable au moment
/// de la compilation via `--dart-define=API_BASE_URL=...`.
class AppConfig {
  /// URL de base des endpoints de l'API REST CampusTasks.
  ///
  /// Sur Android Emulator, le backend Docker est accessible via 10.0.2.2.
  /// Sur les autres environnements (simulator iOS / localhost desktop), on garde
  /// l'hôte local standard.
  static String get apiBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    return configured.isEmpty ? defaultLocalApiBaseUrl : configured;
  }

  static String get defaultLocalApiBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8081/api/v1';
    }
    return 'http://localhost:8081/api/v1';
  }
}
