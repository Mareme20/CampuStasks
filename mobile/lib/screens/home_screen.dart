import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../repositories/auth_repository.dart';
import '../repositories/task_repository.dart';
import 'login_screen.dart';

/// Écran principal de l'application CampusTasks.
/// Intègre l'ensemble des fonctionnalités backend :
/// - Gestion complète des tâches (création, consultation, filtrage par statut/matière, modification, suppression, changement de statut)
/// - Gestion complète des matières (création, consultation, modification, suppression simple ou forcée)
/// - Tableau de bord consolidé (statistiques, tâches en retard et prochaines échéances)
class HomeScreen extends StatefulWidget {
  final AuthRepository auth;
  final TaskRepository tasks;

  const HomeScreen({
    super.key,
    required this.auth,
    required this.tasks,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0; // 0: Tâches, 1: Matières, 2: Tableau de bord

  // États pour l'onglet Tâches
  late Future<List<Task>> _tasksFuture;
  List<Subject> _subjects = [];
  TaskStatus? _selectedStatus;
  int? _selectedSubjectId;

  // États pour l'onglet Matières
  late Future<List<Subject>> _subjectsFuture;

  // États pour l'onglet Dashboard
  late Future<DashboardResponse> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _tasksFuture = widget.tasks.tasks(
        status: _selectedStatus,
        subjectId: _selectedSubjectId,
      );
      _subjectsFuture = widget.tasks.subjects();
      _dashboardFuture = widget.tasks.dashboard();
    });

    widget.tasks.subjects().then((value) {
      if (mounted) {
        setState(() => _subjects = value);
      }
    });
  }

  Future<void> _logout() async {
    await widget.auth.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(auth: widget.auth, tasks: widget.tasks),
      ),
    );
  }

  // ===========================================================================
  // GESTION DES TÂCHES (CRUD COMPLET)
  // ===========================================================================

  Future<void> _openTaskDialog([Task? task]) async {
    if (_subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez d’abord créer au moins une matière.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final isEdit = task != null;
    final titleController = TextEditingController(text: task?.titre ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    int selectedSubject = task?.subjectId ?? _subjects.first.id;
    DateTime selectedDate = task?.dateLimite ?? DateTime.now().add(const Duration(days: 1));
    Priority selectedPriority = task?.priorite ?? Priority.moyenne;
    TaskStatus selectedStatus = task?.statut ?? TaskStatus.aFaire;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Modifier la tâche' : 'Nouvelle tâche'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description (facultative)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _subjects.any((s) => s.id == selectedSubject)
                          ? selectedSubject
                          : _subjects.first.id,
                      decoration: const InputDecoration(
                        labelText: 'Matière *',
                        border: OutlineInputBorder(),
                      ),
                      items: _subjects.map((s) {
                        return DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(s.nom),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedSubject = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      title: const Text('Date d’échéance *'),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                        );
                        if (pickedDate != null && context.mounted) {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                          );
                          setDialogState(() {
                            selectedDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime?.hour ?? 23,
                              pickedTime?.minute ?? 59,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Priority>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priorité *',
                        border: OutlineInputBorder(),
                      ),
                      items: Priority.values.map((p) {
                        return DropdownMenuItem<Priority>(
                          value: p,
                          child: Text(
                            p == Priority.haute
                                ? 'Haute'
                                : p == Priority.moyenne
                                    ? 'Moyenne'
                                    : 'Basse',
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedPriority = val);
                        }
                      },
                    ),
                    if (isEdit) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TaskStatus>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Statut *',
                          border: OutlineInputBorder(),
                        ),
                        items: TaskStatus.values.map((s) {
                          return DropdownMenuItem<TaskStatus>(
                            value: s,
                            child: Text(
                              s == TaskStatus.terminee
                                  ? 'Terminée'
                                  : s == TaskStatus.enCours
                                      ? 'En cours'
                                      : 'À faire',
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedStatus = val);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    final messenger = ScaffoldMessenger.maybeOf(context);
                    final navigator = Navigator.of(context);

                    try {
                      if (isEdit) {
                        await widget.tasks.updateTask(
                          task.id,
                          title: title,
                          description: descController.text.trim(),
                          subjectId: selectedSubject,
                          dueDate: selectedDate,
                          priority: selectedPriority,
                          status: selectedStatus,
                        );
                      } else {
                        await widget.tasks.addTask(
                          title: title,
                          description: descController.text.trim(),
                          subjectId: selectedSubject,
                          dueDate: selectedDate,
                          priority: selectedPriority,
                          status: selectedStatus,
                        );
                      }
                      if (!mounted) return;
                      navigator.pop(true);
                    } catch (e) {
                      if (!mounted) return;
                      messenger?.showSnackBar(
                        SnackBar(
                          content: Text('Erreur : $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(isEdit ? 'Mettre à jour' : 'Créer'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      _load();
    }
  }

  Future<void> _updateTaskStatus(Task task, TaskStatus newStatus) async {
    try {
      await widget.tasks.updateTask(
        task.id,
        title: task.titre,
        description: task.description,
        subjectId: task.subjectId,
        dueDate: task.dateLimite,
        priority: task.priorite,
        status: newStatus,
      );
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == TaskStatus.terminee
                  ? 'Tâche marquée comme terminée !'
                  : 'Statut de la tâche mis à jour.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmDeleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: Text('Voulez-vous vraiment supprimer "${task.titre}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.tasks.deleteTask(task.id);
        _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tâche supprimée avec succès.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // ===========================================================================
  // GESTION DES MATIÈRES (CRUD COMPLET)
  // ===========================================================================

  Future<void> _openSubjectDialog([Subject? subject]) async {
    final isEdit = subject != null;
    final nameController = TextEditingController(text: subject?.nom ?? '');
    final descController = TextEditingController(text: subject?.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEdit ? 'Modifier la matière' : 'Nouvelle matière'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la matière *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (facultative)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final messenger = ScaffoldMessenger.maybeOf(context);
                final navigator = Navigator.of(context);

                try {
                  if (isEdit) {
                    await widget.tasks.updateSubject(
                      subject.id,
                      name,
                      description: descController.text.trim(),
                    );
                  } else {
                    await widget.tasks.addSubject(
                      name,
                      description: descController.text.trim(),
                    );
                  }
                  if (!mounted) return;
                  navigator.pop(true);
                } catch (e) {
                  if (!mounted) return;
                  messenger?.showSnackBar(
                    SnackBar(
                      content: Text('Erreur : $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(isEdit ? 'Mettre à jour' : 'Créer'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _load();
    }
  }

  Future<void> _confirmDeleteSubject(Subject subject) async {
    bool force = false;
    final hasTasks = subject.nombreTaches > 0;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Supprimer la matière'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Voulez-vous supprimer la matière "${subject.nom}" ?'),
                  if (hasTasks) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade600),
                      ),
                      child: Text(
                        'Attention : cette matière contient ${subject.nombreTaches} tâche(s).',
                        style: TextStyle(color: Colors.amber.shade900),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Forcer la suppression en cascade'),
                      subtitle: const Text('Supprime aussi les tâches liées.'),
                      value: force,
                      onChanged: (v) {
                        setDialogState(() => force = v ?? false);
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Supprimer'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      try {
        await widget.tasks.deleteSubject(subject.id, force: force);
        _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Matière supprimée avec succès.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // ===========================================================================
  // WIDGETS DES ONGLETS
  // ===========================================================================

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.haute:
        return Colors.red.shade600;
      case Priority.moyenne:
        return Colors.amber.shade800;
      case Priority.basse:
        return Colors.green.shade600;
    }
  }

  String _priorityLabel(Priority p) {
    switch (p) {
      case Priority.haute:
        return 'Haute';
      case Priority.moyenne:
        return 'Moyenne';
      case Priority.basse:
        return 'Basse';
    }
  }

  Widget _buildTasksTab() {
    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mes tâches',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (_subjects.isNotEmpty)
                DropdownButton<int?>(
                  hint: const Text('Toutes matières'),
                  value: _selectedSubjectId,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.filter_list),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Toutes matières'),
                    ),
                    ..._subjects.map(
                      (s) => DropdownMenuItem<int?>(
                        value: s.id,
                        child: Text(s.nom),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedSubjectId = val;
                      _tasksFuture = widget.tasks.tasks(
                        status: _selectedStatus,
                        subjectId: _selectedSubjectId,
                      );
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Toutes'),
                  selected: _selectedStatus == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = null;
                      _tasksFuture = widget.tasks.tasks(
                        status: null,
                        subjectId: _selectedSubjectId,
                      );
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('À faire'),
                  selected: _selectedStatus == TaskStatus.aFaire,
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = TaskStatus.aFaire;
                      _tasksFuture = widget.tasks.tasks(
                        status: TaskStatus.aFaire,
                        subjectId: _selectedSubjectId,
                      );
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('En cours'),
                  selected: _selectedStatus == TaskStatus.enCours,
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = TaskStatus.enCours;
                      _tasksFuture = widget.tasks.tasks(
                        status: TaskStatus.enCours,
                        subjectId: _selectedSubjectId,
                      );
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Terminées'),
                  selected: _selectedStatus == TaskStatus.terminee,
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = TaskStatus.terminee;
                      _tasksFuture = widget.tasks.tasks(
                        status: TaskStatus.terminee,
                        subjectId: _selectedSubjectId,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Task>>(
            future: _tasksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Erreur : ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              final tasks = snapshot.data ?? [];
              if (tasks.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Aucune tâche correspondante.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: tasks.map((task) {
                  final isDone = task.statut == TaskStatus.terminee;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 1.5,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: IconButton(
                        icon: Icon(
                          isDone
                              ? Icons.check_circle
                              : task.statut == TaskStatus.enCours
                                  ? Icons.timelapse
                                  : Icons.radio_button_unchecked,
                          color: isDone
                              ? Colors.green
                              : task.statut == TaskStatus.enCours
                                  ? Colors.blue
                                  : Colors.grey,
                        ),
                        onPressed: () {
                          // Bascule cyclique : À faire -> En cours -> Terminée -> À faire
                          final nextStatus = task.statut == TaskStatus.aFaire
                              ? TaskStatus.enCours
                              : task.statut == TaskStatus.enCours
                                  ? TaskStatus.terminee
                                  : TaskStatus.aFaire;
                          _updateTaskStatus(task, nextStatus);
                        },
                      ),
                      title: Text(
                        task.titre,
                        style: TextStyle(
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description != null && task.description!.trim().isNotEmpty) ...[
                            Text(
                              task.description!,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  task.subjectNom,
                                  style: TextStyle(
                                    color: Colors.indigo.shade800,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _priorityColor(task.priorite).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _priorityLabel(task.priorite),
                                  style: TextStyle(
                                    color: _priorityColor(task.priorite),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                DateFormat('dd/MM HH:mm').format(task.dateLimite),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (val) {
                          if (val == 'edit') {
                            _openTaskDialog(task);
                          } else if (val == 'delete') {
                            _confirmDeleteTask(task);
                          } else if (val == 'aFaire') {
                            _updateTaskStatus(task, TaskStatus.aFaire);
                          } else if (val == 'enCours') {
                            _updateTaskStatus(task, TaskStatus.enCours);
                          } else if (val == 'terminee') {
                            _updateTaskStatus(task, TaskStatus.terminee);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Modifier'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'aFaire',
                            child: Text('Passer à : À faire'),
                          ),
                          const PopupMenuItem(
                            value: 'enCours',
                            child: Text('Passer à : En cours'),
                          ),
                          const PopupMenuItem(
                            value: 'terminee',
                            child: Text('Passer à : Terminée'),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Supprimer', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsTab() {
    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: FutureBuilder<List<Subject>>(
        future: _subjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Erreur : ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final subjects = snapshot.data ?? [];
          if (subjects.isEmpty) {
            return const Center(
              child: Text(
                'Aucune matière pour le moment.\nCréez-en une avec le bouton ci-dessous.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final s = subjects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1.5,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(
                      s.nom.isNotEmpty ? s.nom[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Colors.indigo.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    s.nom,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (s.description != null && s.description!.isNotEmpty)
                        Text(s.description!),
                      const SizedBox(height: 4),
                      Text(
                        '${s.nombreTaches} tâche(s) associée(s)',
                        style: TextStyle(
                          color: s.nombreTaches > 0 ? Colors.indigo : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _openSubjectDialog(s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _confirmDeleteSubject(s),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: FutureBuilder<DashboardResponse>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Erreur : ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final dash = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Tableau de bord',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'À faire',
                      dash.aFaire.toString(),
                      Colors.orange,
                      Icons.pending_actions,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      'En cours',
                      dash.enCours.toString(),
                      Colors.blue,
                      Icons.timelapse,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      'Terminées',
                      dash.terminees.toString(),
                      Colors.green,
                      Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Section En Retard
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    'Tâches en retard (${dash.enRetard.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (dash.enRetard.isEmpty)
                Card(
                  color: Colors.green.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.sentiment_very_satisfied, color: Colors.green),
                        SizedBox(width: 12),
                        Text('Aucune tâche en retard ! Bravo 🎉'),
                      ],
                    ),
                  ),
                )
              else
                ...dash.enRetard.map((t) => Card(
                      color: Colors.red.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.error, color: Colors.red),
                        title: Text(t.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${t.subjectNom} • Échéance : ${DateFormat('dd/MM/yyyy HH:mm').format(t.dateLimite)}',
                        ),
                        trailing: FilledButton.tonal(
                          onPressed: () => _updateTaskStatus(t, TaskStatus.terminee),
                          child: const Text('Terminer'),
                        ),
                      ),
                    )),
              const SizedBox(height: 24),
              // Section Prochaines Échéances
              Row(
                children: [
                  const Icon(Icons.upcoming, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    'Prochaines échéances (${dash.prochainesEcheances.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (dash.prochainesEcheances.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Aucune échéance à venir.'),
                  ),
                )
              else
                ...dash.prochainesEcheances.map((t) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.schedule, color: Colors.indigo),
                        title: Text(t.titre),
                        subtitle: Text(
                          '${t.subjectNom} • ${DateFormat('dd/MM/yyyy HH:mm').format(t.dateLimite)}',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _priorityColor(t.priorite).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _priorityLabel(t.priorite),
                            style: TextStyle(
                              color: _priorityColor(t.priorite),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusTasks'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Se déconnecter',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildTasksTab(),
          _buildSubjectsTab(),
          _buildDashboardTab(),
        ],
      ),
      floatingActionButton: _currentTab == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                if (_currentTab == 0) {
                  _openTaskDialog();
                } else {
                  _openSubjectDialog();
                }
              },
              icon: const Icon(Icons.add),
              label: Text(_currentTab == 0 ? 'Tâche' : 'Matière'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (idx) {
          setState(() {
            _currentTab = idx;
            _load();
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box),
            label: 'Tâches',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Matières',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
        ],
      ),
    );
  }
}
