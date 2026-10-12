import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/cl_main/view/helpers/v6_booking_quote_guard.dart';

void main() {
  test('current unchanged authoritative quote can be approved', () {
    expect(
      V6BookingQuoteGuard.canSubmit(
        confirmedTotal: 125000,
        currentTotal: 125000,
        estimateRefreshing: false,
        estimateFailed: false,
      ),
      isTrue,
    );
  });
  test('any repricing invalidates previous approval', () {
    expect(
      V6BookingQuoteGuard.canSubmit(
        confirmedTotal: 125000,
        currentTotal: 128500,
        estimateRefreshing: false,
        estimateFailed: false,
      ),
      isFalse,
    );
  });
  test('loading, failed, or missing quotes always block sending', () {
    for (final data in <(num?, num?, bool, bool)>[
      (120000, 120000, true, false),
      (120000, 120000, false, true),
      (null, 120000, false, false),
      (120000, null, false, false),
      (double.nan, 120000, false, false),
    ]) {
      expect(
        V6BookingQuoteGuard.canSubmit(
          confirmedTotal: data.$1,
          currentTotal: data.$2,
          estimateRefreshing: data.$3,
          estimateFailed: data.$4,
        ),
        isFalse,
      );
    }
  });
}
