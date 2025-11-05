import 'dart:convert';

import 'package:green_stay/src/exceptions/rest_exception.dart';
import 'package:green_stay/src/models/client_model.dart';
import 'package:http/http.dart' as http;

class ClientRepository {
  final http.Client _client;

  ClientRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<ClientModel>> fetchClientsByUser(int userId) async {
    final url = Uri.parse('https://greenstayapp.onrender.com/clientes/usuario/$userId');

    try {
      final response = await _client.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => ClientModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList();
        }
        throw ServerErrorException('Resposta inesperada do servidor.');
      }

      throw ServerErrorException(
        'Erro ao carregar clientes (código ${response.statusCode}).',
      );
    } catch (e) {
      throw ServerErrorException('Erro ao conectar ao servidor: $e');
    }
  }
}
