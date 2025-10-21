class PlantModel {
  final int id;
  final String nome;
  final String especie;
  final String? clienteNome;

  PlantModel({
    required this.id,
    required this.nome,
    required this.especie,
    required this.clienteNome,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return PlantModel(
      id: parseInt(json['ID']),
      nome: parseString(json['NomePlanta']),
      especie: parseString(json['Especie']),
      //clienteId: parseInt(json['Cliente'] ?? json['cliente'] ?? json['clienteId'] ?? json['ID_1'],),
      clienteNome: parseString(json['NomeCliente']),
    );
  }

  String get clientDisplayName {
    if (clienteNome != null && clienteNome!.isNotEmpty) {
      return clienteNome!;
    }
    return 'Cliente desconhecido';
  }

  String get especieDisplay => especie.isEmpty ? 'Não informada' : especie;
}