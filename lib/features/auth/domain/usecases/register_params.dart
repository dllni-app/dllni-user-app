import 'package:common_package/helpers/typedef.dart';

class RegisterParams with Params {
  final String name;
  final String phone;
  final String password;

  RegisterParams({required this.name, required this.phone, required this.password});

  @override
  BodyMap getBody() => {'name': name, 'phone': phone, 'password': password};
}
