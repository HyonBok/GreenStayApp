import 'package:flutter/material.dart';
import 'package:green_stay/src/models/plant_info_model.dart';
import 'package:green_stay/src/models/plant_model.dart';
import 'package:green_stay/src/repositories/plant_info_repository.dart';

class PlantsInfoPage extends StatefulWidget {
  final int user;
  final PlantModel plant;

  const PlantsInfoPage({super.key, required this.user, required this.plant});

  @override
  State<PlantsInfoPage> createState() => _PlantsInfoPageState();
}

class _PlantsInfoPageState extends State<PlantsInfoPage> {
  final PlantInfoRepository _repository = PlantInfoRepository();
  late Future<List<PlantInfoModel>> _plantInfoFuture;

  @override
  void initState() {
    super.initState();
    _plantInfoFuture = _fetchPlantInfo();
  }

  Future<List<PlantInfoModel>> _fetchPlantInfo() {
    return _repository.fetchPlantInfoByPlant(widget.plant.id);
  }

  void _reloadPlantInfo() {
    setState(() {
      _plantInfoFuture = _fetchPlantInfo();
    });
  }

  Future<void> _onRefresh() async {
    _reloadPlantInfo();
    await _plantInfoFuture;
  }

  String get _plantTitle =>
      widget.plant.nome.isEmpty ? 'Planta ${widget.plant.id}' : widget.plant.nome;

  Widget _buildPlantHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _plantTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Espécie: ${widget.plant.especieDisplay}'),
            Text('Cliente: ${widget.plant.clientDisplayName}'),
            Text('Usuário ID: ${widget.user}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(PlantInfoModel info) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.analytics, color: Colors.blueAccent),
        title: Text('Registro ${info.id}'),
        subtitle: Text(
          'Data: ${info.formattedDate}\n'
          'Luminosidade: ${info.luminosidade}\n'
          'Temperatura: ${info.temperatura}\n'
          'Umidade: ${info.umidade}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planta - Detalhes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<PlantInfoModel>>(
        future: _plantInfoFuture,
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
                      'Não foi possível carregar as informações da planta.',
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
                      onPressed: _reloadPlantInfo,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final plantInfo = snapshot.data ?? [];

          if (plantInfo.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildPlantHeader(),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Nenhuma informação registrada para esta planta.',
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
              itemCount: plantInfo.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildPlantHeader();
                }
                final info = plantInfo[index - 1];
                return _buildInfoCard(info);
              },
            ),
          );
        },
      ),
    );
  }
}
