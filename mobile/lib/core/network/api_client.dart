import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../storage/token_storage.dart';

/// Exception personnalisée levée lors d'un échec de requête HTTP vers l'API REST.
class ApiException implements Exception {
  /// Code de statut HTTP renvoyé par l'API (ex: 400, 401, 404, 409).
  final int status;

  /// Message d'erreur explicatif renvoyé par le backend.
  final String message;

  ApiException(this.status, this.message);

  @override
  String toString() => message;
}

/// Client HTTP centralisé pour les échanges avec l'API REST CampusTasks.
/// Gère l'injection automatique du token JWT dans l'en-tête Authorization
/// et la désérialisation des réponses JSON.
class ApiClient {
  final TokenStorage storage;

  ApiClient(this.storage);

  /// Envoie une requête HTTP (GET, POST, PUT, DELETE) vers l'endpoint spécifié.
  Future<dynamic> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    // Récupère le jeton JWT si disponible pour les routes authentifiées
    final token = await storage.read();
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path').replace(queryParameters: query);

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    late http.Response response;
    final payload = body == null ? null : jsonEncode(body);

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers, body: payload);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers, body: payload);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw ArgumentError('Méthode HTTP non supportée : $method');
    }

    // Gestion des codes d'erreur HTTP (>= 300)
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Une erreur est survenue lors de la communication avec le serveur.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('message')) {
          message = decoded['message'] as String;
        }
      } catch (_) {
        // En cas de body non-JSON (ex: erreur Nginx / 502 Bad Gateway)
      }
      throw ApiException(response.statusCode, message);
    }

    if (response.body.isEmpty) {
      return {};
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  /// Exécute une requête GET et retourne le résultat sous forme de liste dynamique.
  Future<List<dynamic>> list(String path, {Map<String, String>? query}) async {
    final result = await send('GET', path, query: query);
    return List<dynamic>.from(result as List);
  }
}
