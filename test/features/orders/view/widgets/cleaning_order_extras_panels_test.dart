import 'package:dllni_user_app/core/models/cleaning_service_extras.dart';
import 'package:dllni_user_app/features/orders/view/widgets/cleaning_order_extras_panels.dart';
import 'package:dllni_user_app/features/orders/view/widgets/v7_order_detail_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const material = CleaningMaterialLineModel(
    materialTypeId: 1,
    name: 'منظف أرضيات',
    quantity: 0.1,
    unit: 'لتر',
    totalPrice: 1.8,
  );
  const service = CleaningSpecialServiceLineModel(
    specialServiceId: 2,
    name: 'تنظيف الثلاجة من الداخل',
    quantity: 1,
    totalPrice: 70,
    items: [
      CleaningSpecialServiceItemLineModel(
        quantity: 1,
        notes: 'نظف الأرفف',
        totalPrice: 70,
      ),
    ],
  );

  Future<void> pump(
    WidgetTester tester, {
    List<CleaningMaterialLineModel> materials = const [],
    List<CleaningSpecialServiceLineModel> specialServices = const [],
    CleaningOpenTimeModel? openTime,
  }) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: buildCleaningOrderExtrasPanels(
                  materials: materials,
                  specialServices: specialServices,
                  openTime: openTime,
                  currency: 'SYP',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'materials appear in their own panel, without specialized header',
    (tester) async {
      await pump(tester, materials: [material]);
      expect(find.byType(V7OrderPanel), findsOneWidget);
      expect(find.text('مواد التنظيف'), findsOneWidget);
      expect(find.text('منظف أرضيات'), findsOneWidget);
      expect(find.text('الخدمات المتخصصة'), findsNothing);
      expect(find.text('تفاصيل الخدمات الإضافية'), findsNothing);
      expect(
        find.byKey(const ValueKey('order-materials-panel')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('special services appear in their own panel with item details', (
    tester,
  ) async {
    await pump(tester, specialServices: [service]);
    expect(find.byType(V7OrderPanel), findsOneWidget);
    expect(find.text('الخدمات المتخصصة'), findsOneWidget);
    expect(find.text('تنظيف الثلاجة من الداخل'), findsOneWidget);
    expect(find.text('مواد التنظيف'), findsNothing);
    expect(
      find.byKey(const ValueKey('order-special-services-panel')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'specialized order summary shows only service and dirtiness, with matching icon',
    (tester) async {
      await pump(
        tester,
        specialServices: const [
          CleaningSpecialServiceLineModel(
            name: 'تنظيف الفرن من الداخل',
            quantity: 4,
            pricingUnit: 'piece',
            dirtinessLevel: 'light',
            totalPrice: 340,
          ),
        ],
      );
      expect(find.text('تنظيف الفرن من الداخل'), findsOneWidget);
      expect(find.text('مستوى الاتساخ: اتساخ بسيط'), findsOneWidget);
      expect(find.byIcon(Icons.kitchen_outlined), findsOneWidget);
      expect(find.textContaining('piece'), findsNothing);
      expect(find.textContaining('340'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('both categories render as two separate cards', (tester) async {
    await pump(tester, materials: [material], specialServices: [service]);
    expect(find.byType(V7OrderPanel), findsNWidgets(2));
    expect(find.byKey(const ValueKey('order-materials-panel')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('order-special-services-panel')),
      findsOneWidget,
    );
    expect(find.text('منظف أرضيات'), findsOneWidget);
    expect(find.text('تنظيف الثلاجة من الداخل'), findsOneWidget);
    expect(find.text('الخدمات والمواد الإضافية'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('omits empty cards and keeps hourly work independent', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byType(V7OrderPanel), findsNothing);
    await pump(
      tester,
      openTime: const CleaningOpenTimeModel(workerCount: 2, hourlyRate: 20),
    );
    expect(find.byType(V7OrderPanel), findsOneWidget);
    expect(find.text('تفاصيل العمل بالساعة'), findsOneWidget);
    expect(find.text('مواد التنظيف'), findsNothing);
    expect(find.text('الخدمات المتخصصة'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
