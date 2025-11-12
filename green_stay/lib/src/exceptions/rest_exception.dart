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

class DuplicateUserException extends RestException {
  DuplicateUserException()
      : super('Já existe um usuário cadastrado com esse nome.');
}

class ClientHasPlantsException extends RestException {
  final int plantCount;

  ClientHasPlantsException(this.plantCount)
      : super(
            plantCount == 1
                ? 'Este cliente possui 1 planta vinculada.'
                : 'Este cliente possui $plantCount plantas vinculadas.',
          );
}
