import 'package:common_package/helpers/typedef.dart';

class RegisterParams with Params {
  final String name;
  final String email;
  final String phone;
  final String password;

  RegisterParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  BodyMap getBody() => {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      };
}
