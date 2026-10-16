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
    expect(find.textContaining('المرحلة الحالية'), findsOneWidget);
    expect(find.text('تم استلام الطلب'), findsOneWidget);
    // Property room counts belong in the separate room-details section,
    // not inside the user-facing tasks card.
    expect(find.text('المهام المطلوبة'), findsNothing);
    expect(find.text('غرف النوم'), findsNothing);
    expect(find.text('الحمامات'), findsNothing);
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

  testWidgets('disputed order does not invent worker arrival or completion', (
    tester,
  ) async {
    await render(
      tester,
      CleaningOrderDetailModel(
        id: 45,
        status: CleaningBookingStatus.underDispute,
      ),
    );
    expect(
      find.byKey(const Key('cleaning_order_dispute_timeline')),
      findsOneWidget,
    );
    expect(find.text('مراجعة المشكلة'), findsOneWidget);
    expect(find.textContaining('ستظهر التحديثات بعد مراجعتها'), findsOneWidget);
    expect(find.text('بدء تنفيذ الخدمة'), findsNothing);
    expect(find.text('اكتمال الطلب'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  final lifecycleCases =
      <({String status, String label, String? travelling, String? arrived})>[
        (
          status: CleaningBookingStatus.workerAssigned,
          label: 'مقدم الخدمة في الطريق',
          travelling: '2026-10-12T10:00:00',
          arrived: null,
        ),
        (
          status: CleaningBookingStatus.workerAssigned,
          label: 'وصل مقدم الخدمة',
          travelling: '2026-10-12T10:00:00',
          arrived: '2026-10-12T10:30:00',
        ),
        (
          status: CleaningBookingStatus.awaitingStartVerification,
          label: 'التحقق من رمز الأمان',
          travelling: null,
          arrived: null,
        ),
        (
          status: CleaningBookingStatus.awaitingWorkerStartConfirmation,
          label: 'بانتظار بدء العمل',
          travelling: null,
          arrived: null,
        ),
        (
          status: CleaningBookingStatus.inProgress,
          label: 'الخدمة قيد التنفيذ',
          travelling: null,
          arrived: null,
        ),
        (
          status: CleaningBookingStatus.timeExtensionRequested,
          label: 'طلب التمديد قيد المعالجة',
          travelling: null,
          arrived: null,
        ),
      ];
  for (final scenario in lifecycleCases) {
    testWidgets('timeline honors backend state: ${scenario.label}', (
      tester,
    ) async {
      await render(
        tester,
        CleaningOrderDetailModel(
          id: 60,
          status: scenario.status,
          startedTravelAt: scenario.travelling,
          arrivedAt: scenario.arrived,
        ),
      );
      expect(find.text(scenario.label), findsOneWidget);
      expect(find.textContaining('المرحلة الحالية'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('partial acceptance never says the entire team accepted', (
    tester,
  ) async {
    await render(
      tester,
      CleaningOrderDetailModel(
        id: 61,
        status: CleaningBookingStatus.pending,
        workerAcceptance: CleaningWorkerAcceptanceModel(
          required: 3,
          accepted: 1,
          remaining: 2,
          isFulfilled: false,
        ),
      ),
    );
    expect(find.text('بانتظار اكتمال الفريق'), findsOneWidget);
    expect(find.text('وصل مقدم الخدمة'), findsNothing);
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
