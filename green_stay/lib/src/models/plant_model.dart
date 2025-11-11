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

    String? parseImage(Map<String, dynamic> map) {
      final candidates = [
        map['Imagem64'],
        map['imagem64'],
        map['imagem'],
        map['Imagem'],
        map['imagemBase64'],
        map['ImagemBase64'],
        map['base64'],
        map['Base64'],
      ];

      for (final candidate in candidates) {
        final parsed = parseNullableString(candidate);
        if (parsed != null) {
          return parsed;
        }
      }
      return null;
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
      imagemBase64: parseImage(json),
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
      final cleaned = base64.contains(',')
          ? base64.substring(base64.lastIndexOf(',') + 1)
          : base64;
      final normalized = cleaned.replaceAll(RegExp(r'\s'), '');
      return base64Decode(normalized);
    } catch (_) {
      return null;
    }
  }
}