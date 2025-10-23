import 'package:flutter/material.dart';
import 'package:green_stay/src/models/plant_model.dart';
import 'package:green_stay/src/repositories/plant_repository.dart';
import 'package:green_stay/src/widget/login_widget.dart';
import 'package:green_stay/src/widget/plants_info_widget.dart';

class PlantsPage extends StatefulWidget {
  final int user;

  const PlantsPage({super.key, required this.user});

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  final PlantRepository _repository = PlantRepository();
  late Future<List<PlantModel>> _plantsFuture;

  @override
  void initState() {
    super.initState();
    _plantsFuture = _fetchPlants();
  }

  Future<List<PlantModel>> _fetchPlants() {
    return _repository.fetchPlantsByUser(widget.user);
  }

  void _reloadPlants() {
    setState(() {
      _plantsFuture = _fetchPlants();
    });
  }

  Future<void> _onRefresh() async {
    _reloadPlants();
    await _plantsFuture;
  }

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
      body: FutureBuilder<List<PlantModel>>(
        future: _plantsFuture,
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
                    Text(
                      'Não foi possível carregar as plantas.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reloadPlants,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final plants = snapshot.data ?? [];

          if (plants.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Nenhuma planta cadastrada para este usuário.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                final plantName =
                    plant.nome.isEmpty ? 'Planta ${plant.id}' : plant.nome;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading:
                        const Icon(Icons.local_florist, color: Colors.green),
                    title: Text(plantName),
                    subtitle: Text(
                      'Cliente: ${plant.clientDisplayName}\nEspécie: ${plant.especieDisplay}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlantsInfoPage(
                            user: widget.user,
                            plant: plant,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
