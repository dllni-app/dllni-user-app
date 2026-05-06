import 'package:common_package/helpers/typedef.dart';

class LoginParams with Params {
  final String phone;
  final String password;

  LoginParams({required this.phone, required this.password});

  @override
  BodyMap getBody() => {
        'phone': phone,
        'password': password,
        'module': 'user'
      };
}
