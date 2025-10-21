import 'package:flutter/material.dart';
import 'package:green_stay/src/repositories/login_repository.dart';
import 'package:green_stay/src/states/login_state.dart';

class LoginController extends ValueNotifier<LoginState> {
  final LoginRepository _repository;
  int? user; 

  LoginController(this._repository) : super(LoginState.initial());

  Future<void> login(String username, String password) async {
    value = LoginState.loading();

    try {
      user = await _repository.login(username, password);
      value = LoginState.success("Login realizado com sucesso!");
    } catch (e) {
      value = LoginState.error(e.toString());
    }
  }
}