import 'package:common_package/helpers/error_handler.dart';
import 'package:dllni_user_app/features/orders/view/helpers/cleaning_lifecycle_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningLifecycleErrorMapper.mapCancelFailure', () {
    test('maps 422 invalid state to Arabic message', () {
      final message = CleaningLifecycleErrorMapper.mapCancelFailure(
        ServerFailure(
          message: 'Order cannot be cancelled in current status.',
          statusCode: 422,
        ),
      );

      expect(message, 'لا يمكن إلغاء الطلب في حالته الحالية.');
      expect(message.contains('Order cannot'), isFalse);
    });

    test('maps 403 to Arabic permission message', () {
      final message = CleaningLifecycleErrorMapper.mapCancelFailure(
        ServerFailure(message: 'Forbidden', statusCode: 403),
      );

      expect(message, 'لا تملك صلاحية تنفيذ هذا الإجراء على الطلب.');
    });

    test('maps 429 to Arabic retry message', () {
      final message = CleaningLifecycleErrorMapper.mapCancelFailure(
        ServerFailure(message: 'Too Many Requests', statusCode: 429),
      );

      expect(message, 'الطلبات كثيرة حالياً، حاول بعد قليل.');
    });
  });

  group('CleaningLifecycleErrorMapper.mapVerificationFailure', () {
    test('maps raw no internet key to Arabic message', () {
      final message = CleaningLifecycleErrorMapper.mapVerificationFailure(
        ServerFailure(message: 'errorMessage.noInternetError'),
      );

      expect(message, 'لا يوجد اتصال بالإنترنت. تحقق من الاتصال وحاول مرة أخرى.');
      expect(message.contains('errorMessage.'), isFalse);
    });

    test('maps invalid code message to Arabic text', () {
      final message = CleaningLifecycleErrorMapper.mapVerificationFailure(
        ServerFailure(message: 'Invalid verification code', statusCode: 422),
      );

      expect(message, 'رمز الوصول غير صحيح. تحقق من الرمز وحاول مرة أخرى.');
    });
  });
}
