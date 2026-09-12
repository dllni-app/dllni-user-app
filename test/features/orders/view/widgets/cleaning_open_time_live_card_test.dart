import 'package:dllni_user_app/core/models/cleaning_service_extras.dart';
import 'package:dllni_user_app/features/orders/view/widgets/cleaning_open_time_live_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('requires selecting a child session before time actions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: CleaningOpenTimeLiveCard(
                orderId: 42,
                initialValue: CleaningOpenTimeModel(
                  isMultiSession: true,
                  sessionsCount: 2,
                  isPricingFinal: false,
                  serverNow: DateTime(2026, 9, 12, 10),
                  ceilingEndsAt: DateTime(2026, 9, 12, 13),
                  liveAmount: 250,
                  currency: 'SYP',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.text(
        'اختر الجلسة المطلوبة من قائمة جلسات الوقت المفتوح لإرسال تمديد أو طلب إنهاء.',
      ),
      findsOneWidget,
    );
    expect(find.text('طلب تمديد'), findsNothing);
    expect(find.text('طلب إنهاء'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps actions available inside a selected session', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: CleaningOpenTimeLiveCard(
                orderId: 42,
                sessionId: 4201,
                initialValue: CleaningOpenTimeModel(
                  isMultiSession: false,
                  isPricingFinal: false,
                  serverNow: DateTime(2026, 9, 12, 10),
                  ceilingEndsAt: DateTime(2026, 9, 12, 13),
                  extensionOptions: const <int>[30],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('طلب تمديد'), findsOneWidget);
    expect(find.text('طلب إنهاء'), findsOneWidget);
    expect(tester.getSize(find.text('طلب تمديد')).height, greaterThan(0));
  });
}
