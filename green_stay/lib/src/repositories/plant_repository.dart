import 'dart:convert';
import 'dart:io';

import 'package:green_stay/src/exceptions/rest_exception.dart';
import 'package:green_stay/src/models/plant_create_model.dart';
import 'package:green_stay/src/models/plant_identification_model.dart';
import 'package:green_stay/src/models/plant_model.dart';
import 'package:http/http.dart' as http;

class PlantRepository {
  final http.Client _client;

  PlantRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PlantModel>> fetchPlantsByUser(int userId) async {
    final url = Uri.parse('http://10.0.2.2:8000/plantas/usuario/$userId');

    try {
      final response = await _client.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => PlantModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList();
        }
        throw ServerErrorException('Resposta inesperada do servidor.');
      } else {
        throw ServerErrorException(
          'Erro ao carregar plantas (código ${response.statusCode}).',
        );
      }
    } catch (e) {
      throw ServerErrorException('Erro ao conectar ao servidor: $e');
    }
  }

  Future<void> createPlant(PlantCreateModel plant) async {
    final url = Uri.parse('http://10.0.2.2:8000/plantas');

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(plant.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw ServerErrorException(
        'Erro ao cadastrar planta (código ${response.statusCode}).',
      );
    } catch (e) {
      throw ServerErrorException('Erro ao conectar ao servidor: $e');
    }
  }

  Future<PlantIdentificationModel> identifyPlant(File imageFile) async {
    final url = Uri.parse('http://10.0.2.2:8000/imagem');

    try {
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return PlantIdentificationModel.fromJson(decoded);
        }
        throw ServerErrorException('Resposta inesperada do servidor.');
      }

      throw ServerErrorException(
        'Erro ao identificar planta (código ${response.statusCode}).',
      );
    } catch (e) {
      throw ServerErrorException('Erro ao identificar a planta: $e');
    }
  }
}