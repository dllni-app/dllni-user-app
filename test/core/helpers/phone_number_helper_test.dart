import 'package:dllni_user_app/core/helpers/phone_number_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

void main() {
  group('phone_number_helper', () {
    test('formatPhoneForApi returns Syrian E.164 for local input', () {
      final value = formatPhoneForApi(
        PhoneNumber(isoCode: 'SY', phoneNumber: '0998765432'),
      );

      expect(value, '+963998765432');
    });

    test('formatPhoneForApi returns null for non-Syrian number', () {
      final value = formatPhoneForApi(
        PhoneNumber(isoCode: 'US', phoneNumber: '+12025550123'),
      );

      expect(value, isNull);
    });

    test('validatePhoneNumber accepts valid Syrian mobile number', () async {
      final error = await validatePhoneNumber(
        PhoneNumber(isoCode: 'SY', phoneNumber: '+963912345678'),
      );

      expect(error, isNull);
    });

    test('validatePhoneNumber rejects non-Syrian number', () async {
      final error = await validatePhoneNumber(
        PhoneNumber(isoCode: 'US', phoneNumber: '+12025550123'),
      );

      expect(error, 'رقم جوال سوري غير صالح');
    });

    test('parseInitialPhone returns null for non-Syrian stored number', () async {
      final parsed = await parseInitialPhone('+12025550123');

      expect(parsed, isNull);
    });
  });
}
