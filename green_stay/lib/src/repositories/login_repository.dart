import 'dart:convert';
import 'package:green_stay/src/exceptions/rest_exception.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class LoginRepository {
  final http.Client _client;
  late final String _baseUrl;

  LoginRepository({http.Client? client})
      : _client = client ?? http.Client() {
    _baseUrl = kDebugMode
        ? 'http://10.0.2.2:8000'
        : 'https://greenstayapp.onrender.com';
  }

  Future<int> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/login/');

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': username,
        'senha': password,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final user = body['user'];
      return user['id'];
    } else {
      if (response.statusCode == 401) {
        throw InvalidCredentialsException();
      } else {
        throw ServerErrorException(response.body);
      }
    }
  }

  Future<void> register(String username, String password) async {
    final url = Uri.parse('$_baseUrl/usuarios');

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': username,
          'senha': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      if (response.statusCode == 409) {
        throw DuplicateUserException();
      }

      throw ServerErrorException(
        'Erro ao registrar usuário (código ${response.statusCode}).',
      );
    } catch (e) {
      if (e is RestException) {
        rethrow;
      }
      throw ServerErrorException('Erro ao registrar usuário: $e');
    }
  }
}
