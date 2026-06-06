import 'package:dllni_user_app/features/profile/domain/usecases/update_account_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateAccountParams body', () {
    test('includes non-empty email', () {
      final params = UpdateAccountParams(
        name: 'Ahmad',
        email: 'ahmad@example.com',
        phone: '+963912345678',
      );

      final body = params.getBody();
      expect(body['name'], 'Ahmad');
      expect(body['email'], 'ahmad@example.com');
      expect(body['phone'], '+963912345678');
    });

    test('includes empty email when cleared', () {
      final params = UpdateAccountParams(
        name: 'Ahmad',
        email: '',
        phone: '+963912345678',
      );

      final body = params.getBody();
      expect(body['email'], '');
    });
  });
}
