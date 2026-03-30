part of 'auth_bloc.dart';

class AuthState {
  BlocStatus? loginStatus;
  LoginModel? login;
  String? errorMessage;

  AuthState({this.errorMessage, this.login, this.loginStatus});

  AuthState copyWith({String? errorMessage, LoginModel? login, BlocStatus? loginStatus}) =>
      AuthState(errorMessage: errorMessage ?? this.errorMessage, login: login ?? this.login, loginStatus: loginStatus ?? this.loginStatus);
}
