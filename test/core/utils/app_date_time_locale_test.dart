import 'package:dllni_user_app/core/utils/app_date_time_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting(AppDateTimeLocale.intlLocale);
  });

  test('formats dates in English even when default locale is Arabic', () {
    final previousLocale = Intl.defaultLocale;
    Intl.defaultLocale = 'ar';

    final formatted = AppDateTimeLocale.dateFormat(
      'd MMM yyyy',
    ).format(DateTime(2026, 5, 29));

    expect(formatted, '29 May 2026');
    Intl.defaultLocale = previousLocale;
  });

  test(
    'formats numbers with English separators when default locale is Arabic',
    () {
      final previousLocale = Intl.defaultLocale;
      Intl.defaultLocale = 'ar';

      final formatted = AppDateTimeLocale.decimalPattern().format(1234567);

      expect(formatted, '1,234,567');
      Intl.defaultLocale = previousLocale;
    },
  );
}
