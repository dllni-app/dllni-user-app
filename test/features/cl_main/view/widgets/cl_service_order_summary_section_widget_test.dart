import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_order_summary_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSummary({bool? isPricingFinal = false, double total = 1300}) {
    return MaterialApp(
      home: Scaffold(
        body: ClServiceOrderSummarySectionWidget(
          basePrice: 1000,
          travelFee: 120,
          addonsTotal: 80,
          totalPrice: total,
          adminMargin: 100,
          isPricingFinal: isPricingFinal,
          currency: 'SYP',
        ),
      ),
    );
  }

  testWidgets(
    'customer sees final total only and no internal financial breakdown',
    (tester) async {
      await tester.pumpWidget(buildSummary());
      expect(find.byKey(const Key('price_total_card')), findsOneWidget);
      expect(find.text('السعر الإجمالي للطلب'), findsOneWidget);
      expect(find.textContaining('1,300'), findsOneWidget);
      for (final internalLabel in <String>[
        'قيمة الخدمة',
        'رسوم التنقل',
        'مواد التنظيف',
        'الخدمات المتخصصة',
        'هامش الإدارة',
        'الحد الأدنى لإجمالي الطلب هو',
      ]) {
        expect(find.textContaining(internalLabel), findsNothing);
      }
      expect(find.textContaining('120'), findsNothing);
      expect(find.textContaining('80'), findsNothing);
    },
  );

  testWidgets('does not add transport or admin margin twice', (tester) async {
    await tester.pumpWidget(buildSummary(total: 1500));
    expect(find.textContaining('1,500'), findsOneWidget);
    expect(find.textContaining('1,875'), findsNothing);
  });

  testWidgets('clarifies provisional price but not final price', (
    tester,
  ) async {
    await tester.pumpWidget(buildSummary(isPricingFinal: false));
    expect(find.textContaining('السعر تقديري'), findsOneWidget);
    await tester.pumpWidget(buildSummary(isPricingFinal: true));
    expect(find.textContaining('السعر تقديري'), findsNothing);
  });

  testWidgets('keeps scheduling separate from the total card', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ClServiceOrderSummarySectionWidget(
            basePrice: 500,
            travelFee: 0,
            addonsTotal: 0,
            totalPrice: 500,
            currency: 'SYP',
            scheduleDayLabel: 'الخميس',
            scheduleDateLabel: '2026-10-15',
            scheduleTimeRange: '09:00 - 11:00',
          ),
        ),
      ),
    );
    expect(find.text('موعد الخدمة'), findsOneWidget);
    expect(find.textContaining('2026-10-15'), findsOneWidget);
    expect(find.text('السعر الإجمالي للطلب'), findsOneWidget);
  });
}
