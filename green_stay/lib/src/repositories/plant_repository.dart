import 'dart:convert';
import 'dart:developer';
import 'package:green_stay/src/exceptions/rest_exception.dart';
import 'package:green_stay/src/models/plant_model.dart';
import 'package:http/http.dart';

class PlantRepository {
  final Client _client;

  PlantRepository({Client? client}) : _client = client ?? Client();

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
}