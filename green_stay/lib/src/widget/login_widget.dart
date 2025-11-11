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
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _openRegisterDialog,
                  child: const Text('Criar nova conta'),
                ),
                const SizedBox(height: 12),
                Text(state.message),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openRegisterDialog() async {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController(text: _nameController.text);
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isSubmitting = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> submit() async {
              if (isSubmitting) return;
              if (!formKey.currentState!.validate()) {
                return;
              }

              setStateDialog(() => isSubmitting = true);

              try {
                await _controller.register(
                  usernameController.text.trim(),
                  passwordController.text,
                );
                if (context.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
                setStateDialog(() => isSubmitting = false);
              }
            }

            return AlertDialog(
              title: const Text('Criar conta'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(labelText: 'Nome do usuário'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe um nome de usuário';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(labelText: 'Senha'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe uma senha';
                          }
                          if (value.length < 4) {
                            return 'A senha deve ter pelo menos 4 caracteres';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: confirmPasswordController,
                        decoration: const InputDecoration(labelText: 'Confirmar senha'),
                        obscureText: true,
                        validator: (value) {
                          if (value != passwordController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: isSubmitting ? null : submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Criar conta'),
                ),
              ],
            );
          },
        );
      },
    );

    final createdUsername = usernameController.text;

    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    if (result == true && mounted) {
      _nameController.text = createdUsername;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
      );
    }
  }
}
