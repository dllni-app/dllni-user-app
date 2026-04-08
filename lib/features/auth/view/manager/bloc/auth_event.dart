part of 'auth_bloc.dart';

abstract class AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String phone;
  final String password;

  LoginSubmittedEvent({required this.phone, required this.password});
}
