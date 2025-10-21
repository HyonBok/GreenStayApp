class rest_exception implements Exception {
  final String message;
  rest_exception(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsException extends rest_exception {
  InvalidCredentialsException() : super('Usuário ou senha inválidos.');
}

class ServerErrorException extends rest_exception {
  ServerErrorException([String? msg]) : super(msg ?? 'Erro interno no servidor.');
}
