part of 'auth_bloc.dart';

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final LoginParams params;

  LoginEvent({required this.params});
}
