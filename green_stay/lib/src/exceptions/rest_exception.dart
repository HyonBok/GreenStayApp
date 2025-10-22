class RestException implements Exception {
  final String message;
  RestException(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsException extends RestException {
  InvalidCredentialsException() : super('Usuário ou senha inválidos.');
}

class ServerErrorException extends RestException {
  ServerErrorException([String? msg]) : super(msg ?? 'Erro interno no servidor.');
}
