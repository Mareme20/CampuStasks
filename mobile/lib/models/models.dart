/// Énumération du statut d'une tâche côté client mobile.
enum TaskStatus { aFaire, enCours, terminee }

/// Énumération du niveau de priorité d'une tâche côté client mobile.
enum Priority { basse, moyenne, haute }

/// Convertit une chaîne de caractères reçue du backend en enum [TaskStatus].
TaskStatus statusFrom(String s) => {
      'A_FAIRE': TaskStatus.aFaire,
      'EN_COURS': TaskStatus.enCours,
      'TERMINEE': TaskStatus.terminee,
    }[s] ??
    TaskStatus.aFaire;

/// Convertit une chaîne de caractères reçue du backend en enum [Priority].
Priority priorityFrom(String s) => {
      'BASSE': Priority.basse,
      'MOYENNE': Priority.moyenne,
      'HAUTE': Priority.haute,
    }[s] ??
    Priority.moyenne;

/// Convertit un enum [TaskStatus] en chaîne attendue par l'API REST.
String statusTo(TaskStatus s) => {
      TaskStatus.aFaire: 'A_FAIRE',
      TaskStatus.enCours: 'EN_COURS',
      TaskStatus.terminee: 'TERMINEE',
    }[s]!;

/// Convertit un enum [Priority] en chaîne attendue par l'API REST.
String priorityTo(Priority p) => {
      Priority.basse: 'BASSE',
      Priority.moyenne: 'MOYENNE',
      Priority.haute: 'HAUTE',
    }[p]!;

/// Modèle représentant une matière académique sur l'application mobile.
class Subject {
  final int id;
  final String nom;
  final String? description;
  final int nombreTaches;
  final DateTime? dateCreation;

  Subject({
    required this.id,
    required this.nom,
    this.description,
    required this.nombreTaches,
    this.dateCreation,
  });

  /// Construit un objet [Subject] à partir d'une réponse JSON.
  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'] as int,
        nom: json['nom'] as String,
        description: json['description'] as String?,
        nombreTaches: (json['nombreTaches'] as num?)?.toInt() ?? 0,
        dateCreation: json['dateCreation'] != null
            ? DateTime.tryParse(json['dateCreation'] as String)
            : null,
      );
}

/// Modèle représentant une tâche étudiante sur l'application mobile.
class Task {
  final int id;
  final String titre;
  final String? description;
  final int subjectId;
  final String subjectNom;
  final DateTime dateLimite;
  final Priority priorite;
  final TaskStatus statut;
  final DateTime? dateCreation;

  Task({
    required this.id,
    required this.titre,
    this.description,
    required this.subjectId,
    required this.subjectNom,
    required this.dateLimite,
    required this.priorite,
    required this.statut,
    this.dateCreation,
  });

  /// Construit un objet [Task] à partir d'une réponse JSON de l'API.
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as int,
        titre: json['titre'] as String,
        description: json['description'] as String?,
        subjectId: json['subjectId'] as int,
        subjectNom: json['subjectNom'] as String? ?? '',
        dateLimite: DateTime.parse(json['dateLimite'] as String),
        priorite: priorityFrom(json['priorite'] as String),
        statut: statusFrom(json['statut'] as String),
        dateCreation: json['dateCreation'] != null
            ? DateTime.tryParse(json['dateCreation'] as String)
            : null,
      );

  Task copyWith({
    int? id,
    String? titre,
    String? description,
    int? subjectId,
    String? subjectNom,
    DateTime? dateLimite,
    Priority? priorite,
    TaskStatus? statut,
    DateTime? dateCreation,
  }) {
    return Task(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      subjectNom: subjectNom ?? this.subjectNom,
      dateLimite: dateLimite ?? this.dateLimite,
      priorite: priorite ?? this.priorite,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}

/// Modèle représentant la synthèse consolidée du tableau de bord.
class DashboardResponse {
  final int aFaire;
  final int enCours;
  final int terminees;
  final List<Task> prochainesEcheances;
  final List<Task> enRetard;

  DashboardResponse({
    required this.aFaire,
    required this.enCours,
    required this.terminees,
    required this.prochainesEcheances,
    required this.enRetard,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) =>
      DashboardResponse(
        aFaire: (json['aFaire'] as num?)?.toInt() ?? 0,
        enCours: (json['enCours'] as num?)?.toInt() ?? 0,
        terminees: (json['terminees'] as num?)?.toInt() ?? 0,
        prochainesEcheances: (json['prochainesEcheances'] as List<dynamic>? ?? [])
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList(),
        enRetard: (json['enRetard'] as List<dynamic>? ?? [])
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
