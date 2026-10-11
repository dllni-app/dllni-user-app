import 'package:dllni_user_app/features/cl_main/view/widgets/cl_booking_review_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in <double>[320, 390]) {
    testWidgets('V7 booking review shows customer choices on RTL $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                child: ClBookingReviewOverview(
                  service: 'تنظيف عادي',
                  address: 'المنزل، حلب',
                  workerLabel: '2',
                  materialsRequested: true,
                  recurring: false,
                  services: ['تنظيف الزجاج', 'تنظيف الفرن'],
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('راجع تفاصيل الحجز'), findsOneWidget);
      expect(find.text('تنظيف عادي'), findsOneWidget);
      expect(find.text('المنزل، حلب'), findsOneWidget);
      expect(find.text('تنظيف الزجاج'), findsOneWidget);
      expect(find.text('إحضار مواد التنظيف'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
