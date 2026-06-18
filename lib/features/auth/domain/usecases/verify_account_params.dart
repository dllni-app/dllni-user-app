import 'package:common_package/common_package.dart';

class VerifyAccountParams with Params {
  final String phone;
  final String otp;

  VerifyAccountParams({required this.phone, required this.otp});

  @override
  BodyMap getBody() {
    final body = <String, dynamic>{'phone': phone, 'otp': otp};
    FcmTokenHelper.appendToBody(body);
    return body;
  }
}
