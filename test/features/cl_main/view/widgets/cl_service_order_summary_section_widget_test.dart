import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_order_summary_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _buildWidget({required bool? isPricingFinal}) {
    return MaterialApp(
      home: Scaffold(
        body: ClServiceOrderSummarySectionWidget(
          basePrice: 1000,
          travelFee: 120,
          addonsTotal: 80,
          totalPrice: 1300,
          distanceKm: 2.5,
          adminMargin: 100,
          isPricingFinal: isPricingFinal,
          currency: 'SYP',
        ),
      ),
    );
  }

  testWidgets(
    'folds admin margin into service price, keeps pure travel fee',
    (tester) async {
      await tester.pumpWidget(_buildWidget(isPricingFinal: false));

      expect(find.text('قيمة الخدمة'), findsOneWidget);
      expect(find.text('رسوم التنقل'), findsOneWidget);
      expect(find.text('المسافة'), findsOneWidget);
      expect(find.text('الإجمالي'), findsOneWidget);
      expect(find.text('هامش الإدارة'), findsNothing);
      // Service = basePrice (1000) + adminMargin (100).
      expect(find.textContaining('1,100'), findsOneWidget);
      // Pure travel fee only (120), not folded with admin margin (220).
      expect(find.textContaining('120'), findsOneWidget);
      expect(find.textContaining('220'), findsNothing);
    },
  );

  testWidgets('shows provisional warning when pricing is not final', (
    tester,
  ) async {
    await tester.pumpWidget(_buildWidget(isPricingFinal: false));

    expect(
      find.text(
        'السعر المعروض تقديري وغير نهائي، وسيتم اضافة رسوم التنقل بعد قبول مقدم الخدمة للطلب.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('hides provisional warning when pricing is final', (
    tester,
  ) async {
    await tester.pumpWidget(_buildWidget(isPricingFinal: true));

    expect(
      find.text(
        'السعر المعروض تقديري وغير نهائي، وسيتم اضافة رسوم التنقل بعد قبول مقدم الخدمة للطلب.',
      ),
      findsNothing,
    );
  });
}
