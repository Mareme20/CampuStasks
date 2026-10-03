import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../repositories/auth_repository.dart';
import '../repositories/task_repository.dart';
import 'login_screen.dart';

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
  late Future<List<Task>> _future;
  List<Subject> _subjects = [];
  TaskStatus? _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = widget.tasks.tasks(status: _status);
    widget.tasks.subjects().then((value) {
      if (mounted) {
        setState(() => _subjects = value);
      }
    });
  }

  Future<void> _addSubject() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nouvelle matière'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  return;
                }
                await widget.tasks.addSubject(controller.text.trim());
                if (context.mounted) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(_load);
    }
  }

  Future<void> _addTask() async {
    if (_subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Créez d’abord une matière.')),
      );
      return;
    }

    final titleController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nouvelle tâche'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Titre'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  return;
                }
                await widget.tasks.addTask(
                  titleController.text.trim(),
                  ' ',
                  _subjects.first.id,
                  DateTime.now().add(const Duration(days: 1)),
                  Priority.moyenne,
                );
                if (context.mounted) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(_load);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusTasks'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Tâche'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_load);
        },
        child: FutureBuilder<List<Task>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Erreur : ${snapshot.error}'),
                  ),
                ],
              );
            }

            final data = snapshot.data ?? const <Task>[];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mes tâches',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: _addSubject,
                      icon: const Icon(Icons.menu_book),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Toutes'),
                      selected: _status == null,
                      onSelected: (_) {
                        setState(() {
                          _status = null;
                          _load();
                        });
                      },
                    ),
                    ...TaskStatus.values.map(
                      (status) => FilterChip(
                        label: Text(status.name),
                        selected: _status == status,
                        onSelected: (_) {
                          setState(() {
                            _status = status;
                            _load();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (data.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Aucune tâche à afficher.'),
                    ),
                  ),
                ...data.map(
                  (task) => Card(
                    child: ListTile(
                      title: Text(task.titre),
                      subtitle: Text(
                        '${task.subjectNom} • ${DateFormat('dd/MM/yyyy HH:mm').format(task.dateLimite)}',
                      ),
                      leading: const Icon(Icons.task_alt),
                      trailing: Text(task.priorite.name),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
