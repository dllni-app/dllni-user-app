import 'package:dllni_user_app/features/orders/view/helpers/cleaning_security_code_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatCleaningSecurityCodeDateTime uses yy-MM-dd HH:mm a', () {
    final formatted = formatCleaningSecurityCodeDateTime(
      '2026-05-17T14:30:00.000Z',
    );
    expect(formatted, isNotEmpty);
    expect(formatted.contains('26-05-17'), isTrue);
  });

  test('formatCleaningBookingLabel prefers booking number', () {
    expect(
      formatCleaningBookingLabel(bookingId: 11, bookingNumber: 'CL-11'),
      'CL-11',
    );
    expect(formatCleaningBookingLabel(bookingId: 11), '#11');
  });
}
