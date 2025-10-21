import 'package:flutter/material.dart';
import 'package:green_stay/src/widget/login_widget.dart';

class PlantsPage extends StatefulWidget {
  final int user;

  const PlantsPage({super.key, required this.user});

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  final List<Map<String, String>> plants = [
    {'cliente': 'Cliente A', 'planta': 'Planta 1'},
    {'cliente': 'Cliente B', 'planta': 'Planta 2'},
    {'cliente': 'Cliente C', 'planta': 'Planta 3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // volta para a tela de login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final item = plants[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.local_florist, color: Colors.green),
              title: Text(item['planta']!),
              subtitle: Text('Cliente: ${item['cliente']}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selecionou ${item['planta']}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
