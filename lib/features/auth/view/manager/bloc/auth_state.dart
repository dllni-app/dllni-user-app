part of 'auth_bloc.dart';

class AuthState {
  final BlocStatus? loginStatus;
  final String? errorMessage;
  final LoginResponseModel? loginResult;

  AuthState({
    this.loginStatus,
    this.errorMessage,
    this.loginResult,
  });
}
