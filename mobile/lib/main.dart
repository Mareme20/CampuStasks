import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'repositories/auth_repository.dart';
import 'repositories/health_repository.dart';
import 'repositories/task_repository.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

/// Point d'entrée de l'application mobile CampusTasks.
/// Il initialise le stockage local du token, le client HTTP et les repositories
/// utilisés par les écrans d'authentification et de gestion des tâches.
void main() {
  final storage = TokenStorage();
  final api = ApiClient(storage);
  final auth = AuthRepository(api, storage);
  final tasks = TaskRepository(api);
  final health = HealthRepository(api);

  runApp(App(auth: auth, tasks: tasks, health: health));
}

/// Composant racine de l'application.
/// Il décide d'afficher l'écran d'accueil ou l'écran de connexion selon
/// la présence d'un token de session valide stocké localement.
class App extends StatelessWidget {
  final AuthRepository auth;
  final TaskRepository tasks;
  final HealthRepository health;

  const App({
    super.key,
    required this.auth,
    required this.tasks,
    required this.health,
  });

  Future<bool> _boot() async {
    try {
      await health.ping();
      return await auth.logged();
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusTasks',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: FutureBuilder<bool>(
        future: _boot(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return snapshot.data == true
              ? HomeScreen(auth: auth, tasks: tasks)
              : LoginScreen(auth: auth, tasks: tasks);
        },
      ),
    );
  }
} 