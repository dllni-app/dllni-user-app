import 'package:dllni_user_app/core/themes/app_theme.dart';
import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:dllni_user_app/features/orders/view/widgets/cleaning_lifecycle_timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('progress timeline retains stages in narrow RTL layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.forSection('cleaning'),
        home: const Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: CleaningLifecycleTimelineWidget(
                status: CleaningBookingStatus.workerAssigned,
                forceTravelling: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('مسار الطلب'), findsOneWidget);
    expect(find.text('الفريق في الطريق إلى موقع الخدمة.'), findsOneWidget);
    expect(find.text('اكتمل الطلب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelled booking remains a danger state, not section accent', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.forSection('cleaning'),
        home: const Scaffold(
          body: CleaningLifecycleTimelineWidget(
            status: CleaningBookingStatus.cancelled,
          ),
        ),
      ),
    );
    expect(find.textContaining('تم إلغاء هذا الطلب'), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    expect(SharedPlatformColors.danger, isNot(SharedPlatformColors.cleaning));
  });

  test('timeline actions preserve business state meanings', () {
    expect(
      cleaningLifecyclePrimaryAction(
        CleaningBookingStatus.awaitingStartVerification,
      ).kind,
      CleaningLifecycleActionKind.verifyStart,
    );
    expect(
      cleaningLifecyclePrimaryAction(CleaningBookingStatus.inProgress).kind,
      CleaningLifecycleActionKind.followProgress,
    );
    expect(
      cleaningLifecyclePrimaryAction(CleaningBookingStatus.completed).kind,
      CleaningLifecycleActionKind.rateService,
    );
  });
}
