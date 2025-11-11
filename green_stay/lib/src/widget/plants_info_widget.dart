import 'dart:math' as math;

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
    final imageBytes = widget.plant.imageBytes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_florist,
                        color: Colors.green,
                        size: 48,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
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
                  if (widget.plant.umidadeIdeal != null ||
                      widget.plant.luminosidadeIdeal != null ||
                      widget.plant.temperaturaIdeal != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Valores ideais registrados: '
                      '${widget.plant.umidadeIdeal != null ? 'Umidade ${widget.plant.umidadeIdeal}% ' : ''}'
                      '${widget.plant.luminosidadeIdeal != null ? 'Luminosidade ${widget.plant.luminosidadeIdeal} lux ' : ''}'
                      '${widget.plant.temperaturaIdeal != null ? 'Temperatura ${widget.plant.temperaturaIdeal}°C' : ''}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBar({
    required String label,
    required int actual,
    required String unit,
    required double defaultMax,
    int? ideal,
  }) {
    final values = <double>[actual.toDouble(), defaultMax];
    if (ideal != null) {
      values.add(ideal.toDouble());
    }
    final safeMaxValue = values.reduce(math.max).clamp(1, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text('${actual.toString()}$unit'),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final actualFactor = (actual / safeMaxValue).clamp(0.0, 1.0);
            final idealFactor = ideal != null ? (ideal / safeMaxValue).clamp(0.0, 1.0) : null;

            return SizedBox(
              height: 28,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    width: barWidth,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    width: barWidth * actualFactor,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  if (idealFactor != null)
                    Positioned(
                      left: math.max(0, barWidth * idealFactor - 1),
                      child: Container(
                        width: 2,
                        height: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        if (ideal != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Ideal: $ideal$unit',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildLatestMeasurementCard(PlantInfoModel info) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Última medição',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              info.formattedDate,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            _buildMetricBar(
              label: 'Umidade',
              actual: info.umidade,
              ideal: widget.plant.umidadeIdeal,
              unit: '%',
              defaultMax: 100,
            ),
            const SizedBox(height: 16),
            _buildMetricBar(
              label: 'Luminosidade',
              actual: info.luminosidade,
              ideal: widget.plant.luminosidadeIdeal,
              unit: ' lux',
              defaultMax: 1000,
            ),
            const SizedBox(height: 16),
            _buildMetricBar(
              label: 'Temperatura',
              actual: info.temperatura,
              ideal: widget.plant.temperaturaIdeal,
              unit: '°C',
              defaultMax: 50,
            ),
            const SizedBox(height: 8),
            Text(
              'A barra mostra a medição mais recente e a linha indica o valor ideal informado.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
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

          final latest = plantInfo.first;
          final history = plantInfo.skip(1).toList();

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildPlantHeader(),
                const SizedBox(height: 16),
                _buildLatestMeasurementCard(latest),
                const SizedBox(height: 16),
                if (history.isNotEmpty) ...[
                  Text(
                    'Histórico recente',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...history.map(_buildInfoCard),
                ] else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Ainda não há mais medições além da última leitura.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
