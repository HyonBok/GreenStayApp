import 'package:flutter/material.dart';
import 'package:green_stay/src/widget/plants_widget.dart';

class PlantsInfoPage extends StatefulWidget {
  final int user;

  const PlantsInfoPage({super.key, required this.user});

  @override
  State<PlantsInfoPage> createState() => _PlantsInfoPageState();
}

class _PlantsInfoPageState extends State<PlantsInfoPage> {
  final List<Map<String, String>> plantsDetails = [
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planta - Detalhes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // volta para a tela de login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PlantsPage(user: widget.user)),
            );
          },
        ),
      ),
    );
  }
}