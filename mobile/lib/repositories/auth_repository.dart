import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';

/// Repository responsable de l'authentification côté mobile.
/// Il envoie les requêtes de connexion/inscription et sauvegarde le token JWT
/// localement pour les futures requêtes authentifiées.
class AuthRepository {
  final ApiClient api;
  final TokenStorage storage;

  AuthRepository(this.api, this.storage);

  /// Authentifie l'utilisateur via son email et mot de passe, puis stocke le JWT.
  Future<void> login(String email, String password) async {
    final response = await api.send('POST', '/auth/login', body: {
      'email': email,
      'password': password,
    });
    await storage.save(response['token']);
  }

  /// Inscrit un nouvel utilisateur puis stocke son JWT retourné par l'API.
  Future<void> register(String name, String email, String password) async {
    final response = await api.send('POST', '/auth/register', body: {
      'nom': name,
      'email': email,
      'password': password,
    });
    await storage.save(response['token']);
  }

  /// Déconnecte l'utilisateur en supprimant son jeton du stockage sécurisé.
  Future<void> logout() => storage.clear();

  /// Vérifie si un jeton d'authentification valide est présent en local.
  Future<bool> logged() => storage.read().then((token) => token != null);
}
