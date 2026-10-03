import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';
import '../repositories/task_repository.dart';
import 'home_screen.dart';

/// Écran d'authentification de l'application.
/// Il permet à l'utilisateur de se connecter ou de créer un compte
/// avant d'accéder à la gestion des matières et des tâches.
class LoginScreen extends StatefulWidget {
  final AuthRepository auth;
  final TaskRepository tasks;

  const LoginScreen({
    super.key,
    required this.auth,
    required this.tasks,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _registerMode = false;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (_registerMode && name.isEmpty)) {
      setState(() => _error = 'Tous les champs requis doivent être remplis.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_registerMode) {
        await widget.auth.register(name, email, password);
      } else {
        await widget.auth.login(email, password);
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(auth: widget.auth, tasks: widget.tasks),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'CampusTasks',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Gestion des tâches étudiantes'),
                    const SizedBox(height: 24),
                    if (_registerMode)
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nom complet'),
                      ),
                    if (_registerMode) const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: Text(
                        _registerMode ? 'Créer mon compte' : 'Se connecter',
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _registerMode = !_registerMode),
                      child: Text(
                        _registerMode ? 'J’ai déjà un compte' : 'Créer un compte',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
