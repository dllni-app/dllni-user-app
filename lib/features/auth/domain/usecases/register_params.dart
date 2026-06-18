import 'package:common_package/common_package.dart';

class RegisterParams with Params {
  final String name;
  final String phone;
  final String password;

  RegisterParams({required this.name, required this.phone, required this.password});

  @override
  BodyMap getBody() {
    final body = <String, dynamic>{
      'name': name,
      'phone': phone,
      'password': password,
    };
    FcmTokenHelper.appendToBody(body);
    return body;
  }
}
