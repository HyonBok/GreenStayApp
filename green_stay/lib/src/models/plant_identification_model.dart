class PlantIdentificationModel {
  final String? nomePopular;
  final String? nomeCientifico;
  final String? especie;
  final double? umidadeIdeal;
  final double? luminosidadeIdeal;
  final double? temperaturaIdeal;
  final double? confianca;

  PlantIdentificationModel({
    this.nomePopular,
    this.nomeCientifico,
    this.especie,
    this.umidadeIdeal,
    this.luminosidadeIdeal,
    this.temperaturaIdeal,
    this.confianca,
  });

  factory PlantIdentificationModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    String? parseNullableString(dynamic value) {
      if (value == null) return null;
      if (value is String && value.trim().isEmpty) return null;
      return value.toString();
    }

    return PlantIdentificationModel(
      nomePopular: parseNullableString(json['nome_popular']),
      nomeCientifico: parseNullableString(json['nome_cientifico']),
      especie: parseNullableString(json['especie']),
      umidadeIdeal: parseDouble(json['umidade_ideal']),
      luminosidadeIdeal: parseDouble(json['luminosidade_ideal']),
      temperaturaIdeal: parseDouble(json['temperatura_ideal']),
      confianca: parseDouble(json['confianca']),
    );
  }
}
