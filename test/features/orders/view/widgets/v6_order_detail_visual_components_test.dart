import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/orders/view/widgets/v7_order_detail_components.dart';
import 'package:dllni_user_app/features/profile/view/widgets/section_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'order status panel shows customer status without internal details',
    (tester) async {
      tester.view.physicalSize = const Size(640, 1280);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: V7OrderStatusHero(
                title: 'طلب تنظيف',
                statusLabel: 'جارٍ البحث عن عامل مناسب',
                message: 'سنخبرك عند قبول أحد العمال للطلب.',
                reference: 'رقم الطلب #123456789',
              ),
            ),
          ),
        ),
      );

      expect(find.text('طلب تنظيف'), findsOneWidget);
      expect(find.text('جارٍ البحث عن عامل مناسب'), findsOneWidget);
      expect(find.textContaining('نطاق البحث'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('account navigation row remains actionable with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.65),
            ),
            child: SectionCard(
              containerColor: const Color(0xFFEEF2F9),
              image: const Icon(Icons.location_on_outlined),
              title: 'العناوين المحفوظة',
              subtitle: 'أضف أو عدل عنوان الخدمة للزيارات القادمة',
              onTap: () => opened = true,
            ),
          ),
        ),
      ),
    );
    expect(find.text('العناوين المحفوظة'), findsOneWidget);
    await tester.tap(find.text('العناوين المحفوظة'));
    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
  });
}
