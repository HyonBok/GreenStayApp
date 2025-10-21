enum LoginStatus { initial, loading, success, error }

class LoginState {
  final LoginStatus status;
  final String message;

  LoginState({required this.status, required this.message});

  factory LoginState.initial() => LoginState(status: LoginStatus.initial, message: '');
  factory LoginState.loading() => LoginState(status: LoginStatus.loading, message: 'Carregando...');
  factory LoginState.success(String msg) => LoginState(status: LoginStatus.success, message: msg);
  factory LoginState.error(String msg) => LoginState(status: LoginStatus.error, message: msg);
}
