import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:dllni_user_app/features/orders/view/widgets/cleaning_lifecycle_timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('compact lifecycle keeps current stage visible and expands', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
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
              padding: EdgeInsets.all(12),
              child: CleaningLifecycleTimelineWidget(
                status: CleaningBookingStatus.workerAssigned,
                forceTravelling: true,
                compact: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('مسار الطلب'), findsOneWidget);
    expect(find.text('الفريق في الطريق إلى موقع الخدمة.'), findsOneWidget);
    expect(find.text('تجهيز الفريق والوصول'), findsOneWidget);
    expect(find.text('اكتمل الطلب'), findsNothing);
    expect(find.textContaining('عرض جميع المراحل'), findsOneWidget);

    await tester.tap(find.text('تجهيز الفريق والوصول').first);
    await tester.pumpAndSettle();
    expect(find.text('اكتمل الطلب'), findsOneWidget);
    expect(find.text('البحث عن العمال'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelled status remains explicit without expand controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CleaningLifecycleTimelineWidget(
            status: CleaningBookingStatus.cancelled,
            compact: true,
          ),
        ),
      ),
    );
    expect(find.textContaining('تم إلغاء هذا الطلب'), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNothing);
  });
}
