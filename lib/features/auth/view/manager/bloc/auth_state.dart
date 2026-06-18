part of 'auth_bloc.dart';

class AuthState {
  final BlocStatus? loginStatus;
  final String? errorMessage;
  final LoginResponseModel? loginResult;

  final BlocStatus? registerStatus;
  final String? registerErrorMessage;
  final RegisterResponseModel? registerResult;

  final BlocStatus? verifyAccountStatus;
  final String? verifyAccountErrorMessage;
  final LoginResponseModel? verifyAccountResult;

  AuthState({
    this.loginStatus,
    this.errorMessage,
    this.loginResult,
    this.registerStatus,
    this.registerErrorMessage,
    this.registerResult,
    this.verifyAccountStatus,
    this.verifyAccountErrorMessage,
    this.verifyAccountResult,
  });
}
