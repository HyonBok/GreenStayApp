class PlantInfoModel {
  final int id;
  final int luminosidade;
  final int temperatura;
  final int umidade;
  final String data;
  final int plantaId;

  PlantInfoModel({
    required this.id,
    required this.luminosidade,
    required this.temperatura,
    required this.umidade,
    required this.data,
    required this.plantaId,
  });

  factory PlantInfoModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return PlantInfoModel(
      id: parseInt(json['ID'] ?? json['id']),
      luminosidade: parseInt(json['Luminosidade'] ?? json['luminosidade']),
      temperatura: parseInt(json['Temperatura'] ?? json['temperatura']),
      umidade: parseInt(json['Umidade'] ?? json['umidade']),
      data: parseString(json['Data'] ?? json['data']),
      plantaId: parseInt(json['Planta'] ?? json['planta'] ?? json['plantaId']),
    );
  }

  DateTime? get parsedDate => DateTime.tryParse(data);

  String get formattedDate {
    if (data.isEmpty) {
      return 'Data não informada';
    }

    final parsed = DateTime.tryParse(data);
    if (parsed == null) {
      return data;
    }

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    final datePart =
        '${twoDigits(parsed.day)}/${twoDigits(parsed.month)}/${parsed.year}';
    final timePart = '${twoDigits(parsed.hour)}:${twoDigits(parsed.minute)}';

    return '$datePart $timePart';
  }
}
