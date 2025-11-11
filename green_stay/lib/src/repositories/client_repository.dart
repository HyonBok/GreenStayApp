import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:green_stay/src/exceptions/rest_exception.dart';
import 'package:green_stay/src/models/client_model.dart';
import 'package:http/http.dart' as http;

class ClientRepository {
  final http.Client _client;
  late final String _baseUrl;

  ClientRepository({http.Client? client})
      : _client = client ?? http.Client() {
    _baseUrl = kDebugMode
        ? 'http://10.0.2.2:8000'
        : 'https://greenstayapp.onrender.com';
  }

  Future<List<ClientModel>> fetchClientsByUser(int userId) async {
    final url = Uri.parse('$_baseUrl/clientes/usuario/$userId');

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

  Future<ClientModel> createClient({
    required String name,
    required int userId,
  }) async {
    final url = Uri.parse('$_baseUrl/clientes');

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nome': name,
          'usuarioId': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ClientModel.fromJson(decoded);
        }
        throw ServerErrorException('Resposta inesperada ao criar cliente.');
      }

      throw ServerErrorException(
        'Erro ao criar cliente (código ${response.statusCode}).',
      );
    } catch (e) {
      if (e is RestException) {
        rethrow;
      }
      throw ServerErrorException('Erro ao criar cliente: $e');
    }
  }

  Future<void> deleteClient(int clientId, {bool cascade = false}) async {
    final url = Uri.parse('$_baseUrl/clientes/$clientId?cascade=$cascade');

    try {
      final response = await _client.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return;
      }

      if (response.statusCode == 404) {
        throw ServerErrorException('Cliente não encontrado.');
      }

      if (response.statusCode == 409) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final detail = decoded['detail'];
            if (detail is Map<String, dynamic>) {
              final code = detail['code']?.toString();
              final plantCount = detail['plantCount'];
              if (code == 'CLIENT_HAS_PLANTS') {
                final count = plantCount is int
                    ? plantCount
                    : int.tryParse(plantCount?.toString() ?? '') ?? 0;
                throw ClientHasPlantsException(count);
              }
            }
          }
        } catch (_) {
          // Ignored – caso a resposta não seja parseável, cai no erro genérico abaixo.
        }
      }

      throw ServerErrorException(
        'Erro ao excluir cliente (código ${response.statusCode}).',
      );
    } catch (e) {
      if (e is RestException) {
        rethrow;
      }
      throw ServerErrorException('Erro ao excluir cliente: $e');
    }
  }
}
