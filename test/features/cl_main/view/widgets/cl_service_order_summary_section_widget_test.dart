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

  testWidgets('folds admin margin into travel fee and hides admin margin row', (
    tester,
  ) async {
    await tester.pumpWidget(_buildWidget(isPricingFinal: false));

    expect(find.text('المسافة'), findsOneWidget);
    expect(find.text('هامش الإدارة'), findsNothing);
    expect(find.text('رسوم التنقل'), findsOneWidget);
    // 120 travel + 100 admin margin
    expect(find.textContaining('220'), findsOneWidget);
  });

  testWidgets('shows provisional warning when pricing is not final', (
    tester,
  ) async {
    await tester.pumpWidget(_buildWidget(isPricingFinal: false));

    expect(
      find.text(
        'السعر المعروض تقديري وغير نهائي، وسيتم تأكيد السعر النهائي بعد قبول مقدم الخدمة للطلب.',
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
        'السعر المعروض تقديري وغير نهائي، وسيتم تأكيد السعر النهائي بعد قبول مقدم الخدمة للطلب.',
      ),
      findsNothing,
    );
  });
}
