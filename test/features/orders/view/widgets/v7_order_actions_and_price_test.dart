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

  testWidgets('price card shows relevant costs and highlights one total', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: V7OrderPricePanel(
            cleaningAndTravelPrice: '150 ل.س',
            addonsTotal: null,
            materialsPrice: '55 ل.س',
            specializedPrice: '30 ل.س',
            total: '235 ل.س',
            finalPrice: true,
          ),
        ),
      ),
    );
    expect(find.text('ملخص السعر'), findsOneWidget);
    expect(find.text('الإجمالي'), findsOneWidget);
    expect(find.text('خدمة التنظيف والتنقل'), findsOneWidget);
    expect(find.text('150 ل.س'), findsOneWidget);
    expect(find.text('150 ل.س + 0 ل.س'), findsNothing);
    expect(find.text('مواد التنظيف'), findsOneWidget);
    expect(find.text('الخدمات المتخصصة'), findsOneWidget);
    expect(find.text('رسوم التنقل'), findsNothing);
    expect(find.text('الدفع نقداً'), findsNothing);
    expect(find.byKey(const Key('order_price_total_card')), findsOneWidget);
    expect(find.text('235 ل.س'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'cleaning plus travel is one numeric amount, not a sum of labels',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: V7OrderPricePanel(
              cleaningAndTravelPrice: '170 ل.س',
              addonsTotal: null,
              total: '170 ل.س',
            ),
          ),
        ),
      );
      expect(find.text('170 ل.س'), findsNWidgets(2));
      expect(find.text('150 ل.س + 20 ل.س'), findsNothing);
      expect(find.text('رسوم التنقل'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('non-itemized extras stay visible without invented categories', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: V7OrderPricePanel(
              cleaningAndTravelPrice: '170 ل.س',
              addonsTotal: '50 ل.س',
              total: '220 ل.س',
            ),
          ),
        ),
      ),
    );
    expect(find.text('الإضافات'), findsOneWidget);
    expect(find.text('50 ل.س'), findsOneWidget);
    expect(find.text('220 ل.س'), findsOneWidget);
    expect(find.text('مواد التنظيف'), findsNothing);
    expect(find.text('الخدمات المتخصصة'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hourly order price remains explicitly provisional', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: V7OrderPricePanel(
            cleaningAndTravelPrice: '150 SYP',
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
