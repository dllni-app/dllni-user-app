import 'package:dllni_user_app/features/orders/view/widgets/cleaning_orders_feedback_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('load error offers a working retry without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 680);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    var retryCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: CleaningOrdersFeedbackState(
                kind: CleaningOrdersFeedbackKind.loadError,
                message: 'تحقق من الاتصال بالإنترنت',
                onRetry: () => retryCalls++,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('تعذر تحميل طلبات التنظيف'), findsOneWidget);
    expect(find.text('تحقق من الاتصال بالإنترنت'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cleaning_orders_retry')));
    expect(retryCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state explains booking history without false action', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CleaningOrdersFeedbackState(
            kind: CleaningOrdersFeedbackKind.historyEmpty,
          ),
        ),
      ),
    );
    expect(find.text('لا توجد طلبات سابقة'), findsOneWidget);
    expect(find.byKey(const Key('cleaning_orders_retry')), findsNothing);
  });
}
