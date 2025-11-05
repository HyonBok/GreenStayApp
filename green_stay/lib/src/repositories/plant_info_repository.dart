import 'dart:convert';

import 'package:green_stay/src/exceptions/rest_exception.dart';
import 'package:green_stay/src/models/plant_info_model.dart';
import 'package:http/http.dart';

class PlantInfoRepository {
  final Client _client;

  PlantInfoRepository({Client? client}) : _client = client ?? Client();

  Future<List<PlantInfoModel>> fetchPlantInfoByPlant(int plantId) async {
    final url = Uri.parse('https://greenstayapp.onrender.com/plantas-info/planta/$plantId');

    try {
      final response = await _client.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => PlantInfoModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList();
        }
        throw ServerErrorException('Resposta inesperada do servidor.');
      } else {
        throw ServerErrorException(
          'Erro ao carregar informações da planta (código ${response.statusCode}).',
        );
      }
    } catch (e) {
      throw ServerErrorException('Erro ao conectar ao servidor: $e');
    }
  }
}
