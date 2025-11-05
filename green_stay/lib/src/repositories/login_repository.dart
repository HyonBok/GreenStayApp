import 'dart:convert';
import 'package:green_stay/src/exceptions/rest_exception.dart';
import 'package:http/http.dart';

class LoginRepository {
  final cliente = Client();

  Future<int> login(String username, String password) async {
    final url = Uri.parse('https://greenstayapp.onrender.com/login/');

    final response = await cliente.post(
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
}
