import 'package:dllni_user_app/features/orders/view/widgets/v7_order_detail_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in <double>[320, 390]) {
    testWidgets('V7 order-detail status cards render RTL at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      var actionCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: V7OrderDetailScaffold(
              heading: 'تفاصيل الطلب',
              onRefresh: () async {},
              primaryAction: FilledButton(
                onPressed: () => actionCount++,
                child: const Text('متابعة الطلب'),
              ),
              sections: const [
                V7OrderStatusHero(
                  title: 'تنظيف المنزل',
                  statusLabel: 'بانتظار عامل',
                  reference: '#42',
                  message: 'سنعلمك عند قبول الطلب.',
                ),
                V7OrderPanel(
                  title: 'موعد الخدمة وموقعها',
                  child: V7OrderInfoRow(
                    label: 'التاريخ',
                    value: '11 تشرين الأول 2026',
                  ),
                ),
                V7OrderPricePanel(
                  basePrice: null,
                  travelFee: null,
                  addonsTotal: null,
                  total: null,
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('بانتظار عامل'), findsOneWidget);
      expect(find.text('11 تشرين الأول 2026'), findsOneWidget);
      expect(find.text('سيتم تحديد التكلفة'), findsOneWidget);
      expect(find.text('الدفع نقداً'), findsOneWidget);
      await tester.tap(find.text('متابعة الطلب'));
      expect(actionCount, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('worker portrait fallback is neutral', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: V7OrderWorkerPanel(name: 'مقدم الخدمة')),
      ),
    );
    expect(find.text('مقدم الخدمة'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed state uses semantic status', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: V7OrderStatusHero(
            title: 'تنظيف المنزل',
            statusLabel: 'مكتمل',
            message: 'اكتملت الخدمة',
            tone: V7OrderTone.success,
          ),
        ),
      ),
    );
    expect(find.text('مكتمل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
