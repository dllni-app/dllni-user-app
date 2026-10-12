import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/core/widgets/design_system/design_system.dart';

void main() {
  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('responsive RTL at ${width.toInt()}dp and 200% text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: AppPageScaffold(
              header: const AppPageHeader(title: 'إعداد طلب تنظيف المنزل'),
              bottomAction: AppActionButton(
                label: 'متابعة الحجز',
                onPressed: () {},
              ),
              child: const Column(
                children: [
                  AppSectionHeading(
                    title: 'اختر مساحة المنزل',
                    description: 'يمكنك تعديل التفاصيل قبل تأكيد الطلب',
                  ),
                  SizedBox(height: 12),
                  AppChoiceTile(
                    title: 'تنظيف المنزل الكامل',
                    description: 'تشمل الخدمة الغرف والمطبخ والحمامات',
                    selected: true,
                    onTap: null,
                  ),
                  SizedBox(height: 12),
                  AppOrderCard(
                    title: 'تنظيف المنزل الكامل',
                    reference: 'CLN-USER-2026-0000001',
                    status: 'جاري تأكيد طلبك',
                    scheduleLabel: 'الثلاثاء، 20 أكتوبر 2026',
                    section: AppSection.cleaning,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('متابعة الحجز'), findsOneWidget);
    });
  }
}
