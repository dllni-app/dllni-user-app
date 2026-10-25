import 'package:dllni_user_app/features/auth/data/models/login_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OTP bearer token can be returned without embedded user identity', () {
    final result = LoginResponseModel.fromJson({'token': 'bearer-value'});

    expect(result.token, 'bearer-value');
    expect(result.data, isNull);
  });

  test('authenticated /me resolves the real user identity', () {
    final response = CurrentUserModel.fromJson({
      'user': {
        'id': 42,
        'name': 'اسم المستخدم الحقيقي',
        'phone': '0999888777',
      },
    });

    expect(response.user?.id, 42);
    expect(response.user?.name, 'اسم المستخدم الحقيقي');
    expect(response.user?.phone, '0999888777');
  });
}
