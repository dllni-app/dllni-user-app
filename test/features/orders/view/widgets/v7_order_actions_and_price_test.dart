import 'package:dllni_user_app/features/orders/view/widgets/v7_order_detail_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'cancel action stays visible with long details and a primary action',
    (tester) async {
      tester.view.physicalSize = const Size(390, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: V7OrderDetailScaffold(
            heading: 'تفاصيل الطلب',
            sections: const [SizedBox(height: 2100)],
            onRefresh: () async {},
            primaryAction: const SizedBox(
              height: 48,
              child: Center(child: Text('تحديث حالة الطلب')),
            ),
            secondaryAction: OutlinedButton(
              key: const Key('visible_cancel_button'),
              onPressed: () {},
              child: const Text('إلغاء الطلب'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('visible_cancel_button')), findsOneWidget);
      expect(find.text('إلغاء الطلب'), findsOneWidget);
      expect(tester.getBottomLeft(find.text('إلغاء الطلب')).dy, lessThan(780));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('price card matches booking summary and highlights total', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: V7OrderPricePanel(
            basePrice: '150 ل.س',
            addonsTotal: null,
            materialsPrice: '55 ل.س',
            specializedPrice: '30 ل.س',
            travelFee: '0 ل.س',
            total: '235 ل.س',
            finalPrice: true,
          ),
        ),
      ),
    );
    expect(find.text('ملخص السعر'), findsOneWidget);
    expect(find.text('الإجمالي'), findsOneWidget);
    expect(find.text('مواد التنظيف'), findsOneWidget);
    expect(find.text('الخدمات المتخصصة'), findsOneWidget);
    expect(find.byKey(const Key('order_price_total_card')), findsOneWidget);
    expect(find.text('235 ل.س'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hourly order price remains explicitly provisional', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: V7OrderPricePanel(
            basePrice: '150 SYP',
            travelFee: null,
            addonsTotal: null,
            total: '150 SYP',
            finalPrice: false,
            totalLabel: 'الإجمالي المتوقع',
            pendingNote: 'الفاتورة النهائية بحسب مدة العمل الفعلية.',
          ),
        ),
      ),
    );
    expect(find.text('الإجمالي المتوقع'), findsOneWidget);
    expect(
      find.text('الفاتورة النهائية بحسب مدة العمل الفعلية.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('order_price_total_card')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
