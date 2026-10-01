import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:dllni_user_app/features/orders/view/widgets/cleaning_lifecycle_timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lifecycle primary action follows booking state', () {
    expect(
      cleaningLifecyclePrimaryAction(CleaningBookingStatus.pending).kind,
      CleaningLifecycleActionKind.refreshSearch,
    );
    expect(
      cleaningLifecyclePrimaryAction(
        CleaningBookingStatus.awaitingStartVerification,
      ).kind,
      CleaningLifecycleActionKind.verifyStart,
    );
    expect(
      cleaningLifecyclePrimaryAction(
        CleaningBookingStatus.awaitingCustomerCompletion,
      ).kind,
      CleaningLifecycleActionKind.completionDecision,
    );
    expect(
      cleaningLifecyclePrimaryAction(CleaningBookingStatus.completed).kind,
      CleaningLifecycleActionKind.rateService,
    );
    expect(
      cleaningLifecyclePrimaryAction(CleaningBookingStatus.cancelled).kind,
      CleaningLifecycleActionKind.none,
    );
  });

  test('lifecycle stage index advances without skipping gates', () {
    expect(cleaningLifecycleStageIndex(CleaningBookingStatus.pending), 0);
    expect(
      cleaningLifecycleStageIndex(CleaningBookingStatus.workerAssigned),
      1,
    );
    expect(
      cleaningLifecycleStageIndex(
        CleaningBookingStatus.awaitingStartVerification,
      ),
      2,
    );
    expect(cleaningLifecycleStageIndex(CleaningBookingStatus.inProgress), 3);
    expect(
      cleaningLifecycleStageIndex(
        CleaningBookingStatus.awaitingCustomerCompletion,
      ),
      4,
    );
    expect(cleaningLifecycleStageIndex(CleaningBookingStatus.completed), 5);
  });

  testWidgets('timeline renders status text on a narrow phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(8),
              child: CleaningLifecycleTimelineWidget(
                status: CleaningBookingStatus.pending,
                acceptedWorkers: 1,
                requiredWorkers: 2,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('مسار الطلب'), findsOneWidget);
    expect(find.text('البحث عن العمال'), findsOneWidget);
    expect(find.textContaining('1 من 2 عامل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
