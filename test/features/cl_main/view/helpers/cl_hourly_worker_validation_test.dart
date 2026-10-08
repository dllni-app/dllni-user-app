import 'package:dllni_user_app/core/utils/cleaning_date_time_ui_format.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/cl_main/view/helpers/cl_hourly_worker_validation.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_hourly_worker_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClHourlyWorkerValidation.description', () {
    test('rejects empty and whitespace-only descriptions', () {
      expect(ClHourlyWorkerValidation.description(null), 'وصف العمل مطلوب.');
      expect(ClHourlyWorkerValidation.description('   '), 'وصف العمل مطلوب.');
    });

    test('rejects descriptions shorter than twenty characters', () {
      expect(
        ClHourlyWorkerValidation.description('مساعدة في المنزل'),
        'يجب أن يحتوي الوصف على 20 حرفاً على الأقل.',
      );
    });

    test('accepts twenty characters and trims only for validation', () {
      const value = '  تنظيف وترتيب غرفة النوم  ';

      expect(ClHourlyWorkerValidation.description(value), isNull);
      expect(value.trim().length, greaterThanOrEqualTo(20));
    });

    test('keeps the API payload trimmed after validation', () {
      const value = '  تنظيف وترتيب غرفة النوم  ';
      final params = CreateCleaningOrderParams.hourlyWorker(
        addressId: 10,
        scheduledDate: '2026-10-09',
        scheduledTime: '09:00',
        workerCount: 1,
        expectedMaxMinutes: 120,
        notes: value,
      );

      final body = params.getBody();
      final details = body['propertyDetails'] as Map<String, dynamic>;
      expect(details['notes'], value.trim());
    });
  });

  test('formats the hourly appointment in Arabic', () {
    final date = DateTime(2026, 10, 9);

    expect(
      CleaningDateTimeUiFormat.scheduleLabel(date),
      'الجمعة، 9 تشرين الأول 2026',
    );
    expect(CleaningDateTimeUiFormat.time('09:00'), '09:00 صباحاً');
  });

  testWidgets('keeps hourly price text on the right and amount on the left', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            width: 360,
            child: ClHourlyWorkerPriceRow(
              label: 'سعر الساعة للعامل',
              amount: 200,
              currency: 'SYP',
            ),
          ),
        ),
      ),
    );

    final labelPosition = tester.getTopLeft(find.text('سعر الساعة للعامل'));
    final amountPosition = tester.getTopLeft(find.text('200 SYP'));
    expect(labelPosition.dx, greaterThan(amountPosition.dx));
  });

  testWidgets('appointment tile is a tappable 48dp-plus target', (
    WidgetTester tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: ClHourlyWorkerAppointmentTile(
              label: 'التاريخ',
              value: 'الجمعة، 9 تشرين الأول 2026',
              icon: Icons.calendar_month_outlined,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(ClHourlyWorkerAppointmentTile)).height,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(find.text('التاريخ'));
    expect(tapped, isTrue);
  });
}
