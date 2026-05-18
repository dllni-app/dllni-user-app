import 'package:dllni_user_app/core/realtime/cleaning_realtime_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningRealtimeContract', () {
    test('normalizes security-code issued aliases to awaiting-start event', () {
      expect(
        CleaningRealtimeContract.normalizeEventName('SecurityCodeIssued'),
        CleaningRealtimeContract.awaitingStartVerification,
      );
      expect(
        CleaningRealtimeContract.normalizeEventName(
          'cleaning_order.security_code_issued',
        ),
        CleaningRealtimeContract.awaitingStartVerification,
      );
    });

    test('identifies security-code reissue raw events only', () {
      expect(
        CleaningRealtimeContract.isSecurityCodeReissuedEvent(
          'SecurityCodeIssued',
        ),
        isTrue,
      );
      expect(
        CleaningRealtimeContract.isSecurityCodeReissuedEvent(
          'cleaning_order.security_code_issued',
        ),
        isTrue,
      );
      expect(
        CleaningRealtimeContract.isSecurityCodeReissuedEvent(
          CleaningRealtimeContract.awaitingStartVerification,
        ),
        isFalse,
      );
    });
  });
}
