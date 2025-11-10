import 'package:flutter/material.dart';
import 'package:green_stay/src/models/plant_model.dart';
import 'package:green_stay/src/repositories/plant_repository.dart';

class ManageActivePlantsPage extends StatefulWidget {
  final int user;

  const ManageActivePlantsPage({super.key, required this.user});

  @override
  State<ManageActivePlantsPage> createState() => _ManageActivePlantsPageState();
}

class _ManageActivePlantsPageState extends State<ManageActivePlantsPage> {
  final PlantRepository _repository = PlantRepository();
  final List<int> _modules = const [1, 2];

  bool _isLoading = true;
  final Map<int, bool> _updatingModule = {};
  List<PlantModel> _plants = [];
  final Map<int, int?> _selectedPlantByModule = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final plants = await _repository.fetchPlantsByUser(widget.user);
      final Map<int, int?> moduleSelections = {};

      for (final moduleId in _modules) {
        final activePlantId = await _repository.fetchActivePlantId(moduleId);
        moduleSelections[moduleId] = activePlantId;
      }

      if (!mounted) return;

      setState(() {
        _plants = plants;
        _selectedPlantByModule
          ..clear()
          ..addAll(moduleSelections);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar os módulos ativos: $e'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onSelectPlant({
    required int moduleId,
    required int? plantId,
  }) async {
    if (plantId == null) {
      return;
    }

    final previousSelection = _selectedPlantByModule[moduleId];

    setState(() {
      _selectedPlantByModule[moduleId] = plantId;
      _updatingModule[moduleId] = true;
    });

    try {
      await _repository.activatePlant(
        plantId: plantId,
        moduleId: moduleId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Planta definida como ativa no módulo $moduleId.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _selectedPlantByModule[moduleId] = previousSelection;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao ativar planta no módulo $moduleId: $e'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _updatingModule[moduleId] = false;
      });
    }
  }

  Widget _buildModuleCard(int moduleId) {
    final isUpdating = _updatingModule[moduleId] ?? false;
    final selectedPlantId = _selectedPlantByModule[moduleId];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Módulo $moduleId',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _plants.any((p) => p.id == selectedPlantId)
                  ? selectedPlantId
                  : null,
              items: _plants
                  .map(
                    (plant) => DropdownMenuItem<int>(
                      value: plant.id,
                      child: Text(
                        plant.nome.isEmpty
                            ? 'Planta ${plant.id}'
                            : plant.nome,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isUpdating
                  ? null
                  : (value) => _onSelectPlant(
                        moduleId: moduleId,
                        plantId: value,
                      ),
              decoration: const InputDecoration(
                labelText: 'Selecione a planta ativa',
                border: OutlineInputBorder(),
              ),
            ),
            if (isUpdating) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar plantas ativas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plants.isEmpty
              ? RefreshIndicator(
                  onRefresh: _loadInitialData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'Nenhuma planta cadastrada disponível para ativação.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadInitialData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Escolha quais plantas estão ativas em cada módulo.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      for (final moduleId in _modules) _buildModuleCard(moduleId),
                    ],
                  ),
                ),
    );
  }
}
