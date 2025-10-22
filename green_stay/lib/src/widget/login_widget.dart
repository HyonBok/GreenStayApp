import 'package:flutter/material.dart';
import 'package:green_stay/src/widget/plants_widget.dart';
import 'package:green_stay/src/controllers/login_controller.dart';
import 'package:green_stay/src/repositories/login_repository.dart';
import 'package:green_stay/src/states/login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = LoginController(LoginRepository());
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder<LoginState>(
        valueListenable: _controller,
        builder: (context, state, _) {
          // Se login for bem-sucedido → redireciona
          if (state.status == LoginStatus.success) {
            Future.microtask(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlantsPage(user: _controller.user!),
                  ),
                );
              });
            });
          }

          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                if (state.status == LoginStatus.loading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      _controller.login(
                        _nameController.text,
                        _passwordController.text,
                      );
                    },
                    child: const Text('Login'),
                  ),
                const SizedBox(height: 20),
                Text(state.message),
              ],
            ),
          );
        },
      ),
    );
  }
}
