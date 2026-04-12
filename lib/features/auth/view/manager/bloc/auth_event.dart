part of 'auth_bloc.dart';

abstract class AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String phone;
  final String password;

  LoginSubmittedEvent({required this.phone, required this.password});
}

class RegisterSubmittedEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;

  RegisterSubmittedEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
}
