import 'dart:convert';
import 'dart:typed_data';

class PlantModel {
  final int id;
  final String nome;
  final String especie;
  final String? clienteNome;
  final int? clienteId;
  final int? umidadeIdeal;
  final int? luminosidadeIdeal;
  final int? temperaturaIdeal;
  final String? imagemBase64;

  PlantModel({
    required this.id,
    required this.nome,
    required this.especie,
    required this.clienteNome,
    required this.clienteId,
    required this.umidadeIdeal,
    required this.luminosidadeIdeal,
    required this.temperaturaIdeal,
    required this.imagemBase64,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    String? parseNullableString(dynamic value) {
      if (value == null) return null;
      final text = value.toString();
      return text.isEmpty ? null : text;
    }

    return PlantModel(
      id: parseInt(json['ID'] ?? json['id']),
      nome: parseString(json['NomePlanta'] ?? json['Nome'] ?? json['nome']),
      especie: parseString(json['Especie'] ?? json['especie']),
      clienteNome: parseNullableString(json['NomeCliente'] ?? json['clienteNome']),
      clienteId: parseNullableInt(json['Cliente'] ?? json['cliente'] ?? json['clienteId']),
      umidadeIdeal: parseNullableInt(json['UmidadeIdeal'] ?? json['umidadeIdeal']),
      luminosidadeIdeal: parseNullableInt(json['LuminosidadeIdeal'] ?? json['luminosidadeIdeal']),
      temperaturaIdeal: parseNullableInt(json['TemperaturaIdeal'] ?? json['temperaturaIdeal']),
      imagemBase64: parseNullableString(json['Imagem64'] ?? json['imagem64']),
    );
  }

  String get clientDisplayName {
    if (clienteNome != null && clienteNome!.isNotEmpty) {
      return clienteNome!;
    }
    return 'Cliente desconhecido';
  }

  String get especieDisplay => especie.isEmpty ? 'Não informada' : especie;

  Uint8List? get imageBytes {
    final base64 = imagemBase64;
    if (base64 == null || base64.isEmpty) {
      return null;
    }
    try {
      return base64Decode(base64);
    } catch (_) {
      return null;
    }
  }
}