import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service de stockage sécurisé du jeton d'authentification (JWT) sur le terminal mobile.
/// Utilise le trousseau sécurisé (Keystore sur Android / Keychain sur iOS).
class TokenStorage {
  static const _key = 'access_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Sauvegarde le token JWT dans le stockage sécurisé.
  Future<void> save(String token) => _storage.write(key: _key, value: token);

  /// Lit le token JWT actuellement stocké, ou null s'il n'existe pas.
  Future<String?> read() => _storage.read(key: _key);

  /// Supprime le token JWT lors de la déconnexion de l'étudiant.
  Future<void> clear() => _storage.delete(key: _key);
}
