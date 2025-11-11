import 'package:flutter/material.dart';
import 'package:green_stay/src/exceptions/rest_exception.dart';
import 'package:green_stay/src/models/client_model.dart';
import 'package:green_stay/src/repositories/client_repository.dart';

class ClientManagementPage extends StatefulWidget {
  final int userId;

  const ClientManagementPage({super.key, required this.userId});

  @override
  State<ClientManagementPage> createState() => _ClientManagementPageState();
}

class _ClientManagementPageState extends State<ClientManagementPage> {
  final ClientRepository _repository = ClientRepository();
  late Future<List<ClientModel>> _clientsFuture;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _clientsFuture = _repository.fetchClientsByUser(widget.userId);
  }

  Future<void> _reloadClients() async {
    setState(() {
      _clientsFuture = _repository.fetchClientsByUser(widget.userId);
    });
  }

  Future<void> _createClient() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    bool isSaving = false;

    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: !isSaving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> submit() async {
              if (isSaving) return;
              if (!formKey.currentState!.validate()) {
                return;
              }

              setStateDialog(() => isSaving = true);

              try {
                await _repository.createClient(
                  name: nameController.text.trim(),
                  userId: widget.userId,
                );

                if (mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
                setStateDialog(() => isSaving = false);
              }
            }

            return AlertDialog(
              title: const Text('Novo cliente'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome do cliente'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do cliente';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: isSaving ? null : submit,
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Criar'),
                ),
              ],
            );
          },
        );
      },
    );

    final createdName = nameController.text;
    nameController.dispose();

    if (created == true) {
      setState(() {
        _hasChanges = true;
      });
      await _reloadClients();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cliente "$createdName" criado com sucesso.')),
        );
      }
    }
  }

  Future<void> _deleteClient(ClientModel client) async {
    try {
      await _repository.deleteClient(client.id);
      if (!mounted) return;

      setState(() {
        _hasChanges = true;
      });
      await _reloadClients();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente "${client.nome}" excluído.')),
      );
    } on ClientHasPlantsException catch (e) {
      final confirmCascade = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final suffix = e.plantCount == 1 ? 'planta vinculada.' : 'plantas vinculadas.';
          return AlertDialog(
            title: const Text('Excluir cliente'),
            content: Text(
              'Este cliente possui ${e.plantCount} $suffix\nDeseja excluir o cliente e todas as plantas vinculadas?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Excluir tudo'),
              ),
            ],
          );
        },
      );

      if (confirmCascade == true) {
        try {
          await _repository.deleteClient(client.id, cascade: true);
          if (!mounted) return;

          setState(() {
            _hasChanges = true;
          });
          await _reloadClients();
          final plantLabel =
              e.plantCount == 1 ? '1 planta' : '${e.plantCount} plantas';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cliente "${client.nome}" e $plantLabel removidos.',
              ),
            ),
          );
        } catch (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget _buildClientList(List<ClientModel> clients) {
    if (clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Nenhum cliente cadastrado ainda.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _createClient,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Cadastrar primeiro cliente'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(client.nome),
            subtitle: Text('ID: ${client.id}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Excluir cliente',
              onPressed: () => _deleteClient(client),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_hasChanges);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clientes'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_hasChanges),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createClient,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Novo cliente'),
        ),
        body: FutureBuilder<List<ClientModel>>(
          future: _clientsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Não foi possível carregar os clientes.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _reloadClients,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final clients = snapshot.data ?? [];
            return RefreshIndicator(
              onRefresh: _reloadClients,
              child: clients.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        _buildClientList(clients),
                      ],
                    )
                  : _buildClientList(clients),
            );
          },
        ),
      ),
    );
  }
}
