import 'package:dllni_user_app/features/home/view/widgets/cleaning_home_widgets.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cleaning home status labels stay human readable', () {
    expect(
      cleaningHomeStatusLabel(CleaningBookingStatus.pending),
      'جاري البحث عن عمال',
    );
    expect(
      cleaningHomeStatusLabel(CleaningBookingStatus.inProgress),
      'التنظيف جارٍ',
    );
    expect(
      cleaningHomeStatusLabel(CleaningBookingStatus.awaitingCustomerCompletion),
      'بانتظار تأكيدك',
    );
  });

  testWidgets('active booking card renders at narrow phone width', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final order = CleaningOrderModel(
      id: 41,
      bookingNumber: 'CL-41',
      status: CleaningBookingStatus.workerAssigned,
      propertyType: 'apartment',
      scheduledDate: '2026-10-02',
      scheduledTime: '09:00',
      locationName: 'المنزل',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(8),
              child: CleaningHomeActiveBookingCard(order: order, onTap: () {}),
            ),
          ),
        ),
      ),
    );

    expect(find.text('طلب تنظيف'), findsOneWidget);
    expect(find.text('تم تعيين الفريق'), findsOneWidget);
    expect(find.text('متابعة الطلب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state distinguishes first use', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: CleaningHomeEmptyBookingCard(
              isAuthenticated: false,
              onBookTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('ابدأ أول طلب تنظيف'), findsOneWidget);
    expect(find.text('احجز تنظيفاً'), findsOneWidget);
  });
}
