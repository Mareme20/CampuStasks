import '../core/network/api_client.dart';
import '../models/models.dart';

/// Repository de gestion des matières et des tâches.
/// Il centralise les appels API de lecture et de création liés au planning
/// de l'utilisateur connecté.
class TaskRepository {
  final ApiClient api;

  TaskRepository(this.api);

  /// Récupère la liste de toutes les matières de l'utilisateur.
  Future<List<Subject>> subjects() async {
    return (await api.list('/subjects')).map((e) => Subject.fromJson(e)).toList();
  }

  /// Récupère les tâches de l'utilisateur, avec filtres optionnels par matière et par statut.
  Future<List<Task>> tasks({int? subjectId, TaskStatus? status}) async {
    final query = <String, String>{};
    if (subjectId != null) query['subjectId'] = '$subjectId';
    if (status != null) query['statut'] = statusTo(status);

    return (await api.list('/tasks', query: query)).map((e) => Task.fromJson(e)).toList();
  }

  /// Crée une nouvelle matière avec le nom et la description spécifiés.
  Future<Subject> addSubject(String name, {String? description}) async {
    final res = await api.send('POST', '/subjects', body: {
      'nom': name,
      'description': description ?? '',
    });
    return Subject.fromJson(res as Map<String, dynamic>);
  }

  /// Met à jour une matière existante.
  Future<Subject> updateSubject(int id, String name, {String? description}) async {
    final res = await api.send('PUT', '/subjects/$id', body: {
      'nom': name,
      'description': description ?? '',
    });
    return Subject.fromJson(res as Map<String, dynamic>);
  }

  /// Supprime une matière. Si force=true, supprime également ses tâches associées.
  Future<void> deleteSubject(int id, {bool force = false}) =>
      api.send('DELETE', '/subjects/$id', query: force ? {'force': 'true'} : null);

  /// Crée une nouvelle tâche rattachée à une matière donnée.
  Future<Task> addTask({
    required String title,
    String? description,
    required int subjectId,
    required DateTime dueDate,
    required Priority priority,
    TaskStatus status = TaskStatus.aFaire,
  }) async {
    final res = await api.send('POST', '/tasks', body: {
      'titre': title,
      'description': description ?? '',
      'subjectId': subjectId,
      'dateLimite': dueDate.toIso8601String(),
      'priorite': priorityTo(priority),
      'statut': statusTo(status),
    });
    return Task.fromJson(res as Map<String, dynamic>);
  }

  /// Met à jour une tâche existante.
  Future<Task> updateTask(
    int id, {
    required String title,
    String? description,
    required int subjectId,
    required DateTime dueDate,
    required Priority priority,
    required TaskStatus status,
  }) async {
    final res = await api.send('PUT', '/tasks/$id', body: {
      'titre': title,
      'description': description ?? '',
      'subjectId': subjectId,
      'dateLimite': dueDate.toIso8601String(),
      'priorite': priorityTo(priority),
      'statut': statusTo(status),
    });
    return Task.fromJson(res as Map<String, dynamic>);
  }

  /// Supprime une tâche.
  Future<void> deleteTask(int id) => api.send('DELETE', '/tasks/$id');

  /// Récupère la synthèse consolidée du tableau de bord.
  Future<DashboardResponse> dashboard() async {
    final res = await api.send('GET', '/dashboard');
    return DashboardResponse.fromJson(res as Map<String, dynamic>);
  }
}
