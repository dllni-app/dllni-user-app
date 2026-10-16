import 'package:dllni_user_app/features/cl_main/view/widgets/cl_booking_confirmation_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> openSheet(
    WidgetTester tester, {
    String? acknowledgement,
    ValueChanged<bool>? onResult,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                final accepted = await showClBookingConfirmationSheet(
                  context: context,
                  title: 'تأكيد طلب التنظيف',
                  total: 1200,
                  currency: 'SYP',
                  icon: Icons.cleaning_services_outlined,
                  acknowledgement: acknowledgement,
                );
                onResult?.call(accepted);
              },
              child: const Text('افتح التأكيد'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('افتح التأكيد'));
    await tester.pumpAndSettle();
  }

  testWidgets('review returns false and confirmation shows cash payment', (
    tester,
  ) async {
    bool? result;
    await openSheet(tester, onResult: (value) => result = value);
    expect(find.text('تأكيد طلب التنظيف'), findsOneWidget);
    expect(find.text('الإجمالي: 1200 SYP'), findsOneWidget);
    expect(find.text('الدفع نقداً عند إتمام الخدمة.'), findsOneWidget);
    expect(find.byKey(const Key('confirm_send_booking')), findsOneWidget);
    await tester.tap(find.byKey(const Key('review_booking_details')));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('property pledge requires explicit approval', (tester) async {
    bool? result;
    await openSheet(
      tester,
      acknowledgement: 'أتعهد بحماية ممتلكاتي طوال الخدمة',
      onResult: (value) => result = value,
    );
    FilledButton confirm = tester.widget(
      find.byKey(const Key('confirm_send_booking')),
    );
    expect(confirm.onPressed, isNull);
    await tester.tap(find.byKey(const Key('booking_property_consent')));
    await tester.pumpAndSettle();
    confirm = tester.widget(find.byKey(const Key('confirm_send_booking')));
    expect(confirm.onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('confirm_send_booking')));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('hourly sheet distinguishes expected price from final billing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => OutlinedButton(
              onPressed: () => showClBookingConfirmationSheet(
                context: context,
                title: 'تأكيد طلب عامل بالساعة',
                total: 185.5,
                currency: 'SYP',
                icon: Icons.schedule_outlined,
                priceLabel: 'الإجمالي المتوقع',
                paymentNote:
                    'الدفع نقداً عند إتمام الخدمة، حسب مدة العمل الفعلية.',
              ),
              child: const Text('افتح'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('افتح'));
    await tester.pumpAndSettle();
    expect(find.text('الإجمالي المتوقع: 185.50 SYP'), findsOneWidget);
    expect(find.textContaining('حسب مدة العمل الفعلية'), findsOneWidget);
    expect(find.byKey(const Key('booking_property_consent')), findsNothing);
  });
}
