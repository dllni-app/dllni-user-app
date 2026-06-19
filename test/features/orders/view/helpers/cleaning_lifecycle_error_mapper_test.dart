import 'package:common_package/helpers/error_handler.dart';
import 'package:dllni_user_app/features/orders/view/helpers/cleaning_lifecycle_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningLifecycleErrorMapper', () {
    test('maps verification failures by status code 429/403/422', () {
      const fallback = 'server-message';

      final tooMany = CleaningLifecycleErrorMapper.mapVerificationFailure(
        const ServerFailure(message: fallback, statusCode: 429),
      );
      final forbidden = CleaningLifecycleErrorMapper.mapVerificationFailure(
        const ServerFailure(message: fallback, statusCode: 403),
      );
      final invalid = CleaningLifecycleErrorMapper.mapVerificationFailure(
        const ServerFailure(message: fallback, statusCode: 422),
      );

      expect(tooMany, isNot(fallback));
      expect(forbidden, isNot(fallback));
      expect(invalid, isNot(fallback));
    });

    test('keeps verification fallback message for unknown status', () {
      const fallback = 'generic-server-message';
      final mapped = CleaningLifecycleErrorMapper.mapVerificationFailure(
        const ServerFailure(message: fallback, statusCode: 500),
      );

      expect(mapped, fallback);
    });

    test('maps lifecycle action failures for 403/429 and custom 422', () {
      const fallback = 'base-error';
      const invalidState = 'invalid-state-message';

      final forbidden = CleaningLifecycleErrorMapper.mapLifecycleActionFailure(
        const ServerFailure(message: fallback, statusCode: 403),
      );
      final tooMany = CleaningLifecycleErrorMapper.mapLifecycleActionFailure(
        const ServerFailure(message: fallback, statusCode: 429),
      );
      final invalid = CleaningLifecycleErrorMapper.mapLifecycleActionFailure(
        const ServerFailure(message: fallback, statusCode: 422),
        invalidStateMessage: invalidState,
      );

      expect(forbidden, isNot(fallback));
      expect(tooMany, isNot(fallback));
      expect(invalid, invalidState);
    });

    test('keeps lifecycle action fallback message for unknown status', () {
      const fallback = 'unknown-lifecycle';
      final mapped = CleaningLifecycleErrorMapper.mapLifecycleActionFailure(
        const ServerFailure(message: fallback, statusCode: 500),
      );

      expect(mapped, fallback);
    });

    test('maps cancel failure 422 to localized Arabic message', () {
      const rawMessage = 'Order cannot be cancelled in current status.';
      final mapped = CleaningLifecycleErrorMapper.mapCancelFailure(
        const ServerFailure(message: rawMessage, statusCode: 422),
      );

      expect(mapped, 'لا يمكن إلغاء الطلب في حالته الحالية.');
      expect(mapped, isNot(rawMessage));
    });

    test('maps cancel failure message without status code by content', () {
      const rawMessage = 'Order cannot be cancelled in current status.';
      final mapped = CleaningLifecycleErrorMapper.mapCancelFailureMessage(
        rawMessage,
      );

      expect(mapped, 'لا يمكن إلغاء الطلب في حالته الحالية.');
    });

    test('does not surface raw translation keys', () {
      final mapped = CleaningLifecycleErrorMapper.mapVerificationFailure(
        const ServerFailure(
          message: 'errorMessage.noInternetError',
          statusCode: 500,
        ),
      );

      expect(mapped, isNot(contains('errorMessage')));
      expect(mapped, isNot('errorMessage.noInternetError'));
    });
  });
}
