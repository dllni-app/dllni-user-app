import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/view/widgets/v7_order_progress_and_tasks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> render(
    WidgetTester tester,
    CleaningOrderDetailModel order,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  V7OrderLifecyclePanel(order: order),
                  V7OrderServicesPanel(order: order),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('searching order never implies worker accepted or work started', (
    tester,
  ) async {
    await render(
      tester,
      CleaningOrderDetailModel(
        id: 31,
        status: CleaningBookingStatus.pending,
        propertyDetails: CleaningPropertyDetailsModel(
          bedrooms: 2,
          bathrooms: 1,
        ),
      ),
    );
    expect(find.text('سجل الطلب'), findsOneWidget);
    expect(find.text('المرحلة الحالية'), findsOneWidget);
    expect(find.text('تم استلام الطلب'), findsOneWidget);
    expect(find.text('المهام المطلوبة'), findsOneWidget);
    expect(find.text('غرف النوم'), findsOneWidget);
    expect(find.text('الحمامات'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelled order has no invented work progression', (
    tester,
  ) async {
    await render(
      tester,
      CleaningOrderDetailModel(id: 32, status: CleaningBookingStatus.cancelled),
    );
    expect(find.text('تم إلغاء الطلب'), findsOneWidget);
    expect(find.text('بدء تنفيذ الخدمة'), findsNothing);
    expect(find.text('المهام المطلوبة'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('real service line items display without placeholder jobs', (
    tester,
  ) async {
    await render(
      tester,
      CleaningOrderDetailModel(
        id: 33,
        status: CleaningBookingStatus.awaitingCustomerCompletion,
        services: [
          CleaningOrderLineItemModel(name: 'تنظيف النوافذ', quantity: 2),
        ],
        addons: [CleaningOrderLineItemModel(name: 'كي الملابس', quantity: 1)],
      ),
    );
    expect(find.text('تنظيف النوافذ'), findsOneWidget);
    expect(find.text('كي الملابس'), findsOneWidget);
    expect(find.text('مراجعة الإنجاز'), findsOneWidget);
    expect(find.text('×2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
