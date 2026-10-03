import '../core/network/api_client.dart';

/// Repository de vérification de disponibilité de l'API backend.
/// Consomme le endpoint public /health pour savoir si le service est disponible.
class HealthRepository {
  final ApiClient api;

  HealthRepository(this.api);

  /// Vérifie la disponibilité du backend.
  Future<String> ping() async {
    final response = await api.send('GET', '/health');

    if (response is String) {
      return response.trim();
    }

    if (response is Map<String, dynamic>) {
      return (response['status'] ?? response['message'] ?? 'ok').toString();
    }

    return 'ok';
  }
}
