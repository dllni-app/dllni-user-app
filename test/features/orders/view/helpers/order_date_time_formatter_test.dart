import 'package:dllni_user_app/features/orders/view/helpers/order_date_time_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatOrderDateTime', () {
    test('formats order time as yyyy-MM-dd hh:mm a', () {
      expect(
        formatOrderDateTime('2026-08-08T15:21:11'),
        '2026-08-08 03:21 PM',
      );
    });

    test('returns dash for missing values', () {
      expect(formatOrderDateTime(null), '-');
      expect(formatOrderDateTime(''), '-');
    });

    test('keeps an unparseable value instead of hiding it', () {
      expect(formatOrderDateTime('unknown'), 'unknown');
    });
  });
}
