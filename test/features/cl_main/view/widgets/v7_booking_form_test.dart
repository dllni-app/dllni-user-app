import 'dart:io';

import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_service_schedule_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_worker_count_selector_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/home_details_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('booking steps separate details from final submission', () {
    final source = File(
      'lib/features/cl_main/view/screens/cl_main_service_schedule_screen.dart',
    ).readAsStringSync();
    expect(source, contains('if (_scheduleStep == 0)'));
    expect(source, contains('if (_scheduleStep == 1)'));
    expect(source, contains('if (_scheduleStep == 2)'));
    expect(source, contains('currentStep: _scheduleStep + 4'));
    expect(source, contains('totalSteps: 8'));
    final initialStepSource = File(
      'lib/features/cl_main/view/screens/cl_main_home_description_screen.dart',
    ).readAsStringSync();
    expect(initialStepSource, contains('ClBookingPencilHeader('));
    expect(initialStepSource, contains('step: _currentStep'));
    expect(initialStepSource, isNot(contains('totalSteps: 9')));
    expect(source, contains('primaryLabel: _scheduleStep == 4'));
    expect(source, contains('تأكيد وإرسال الطلب'));
    expect(ClMainServiceScheduleScreen, isNotNull);
    expect(source, contains('void _advanceSchedule(ClMainState state)'));
    expect(source, contains('_onSubmitPressed(state);'));
    expect(source, contains('_scheduleScrollController.jumpTo(0)'));
  });

  testWidgets('workers form is text-only and counter respects limits', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    int count = 1;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: StatefulBuilder(
              builder: (context, refresh) => ClServiceWorkerCountSelectorWidget(
                count: count,
                maxCount: 2,
                onChanged: (next) => refresh(() => count = next),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(Image), findsNothing);
    expect(find.text('عدد العمال المطلوب'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(count, 2);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(count, 2);
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(count, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('booking app bar is compact and provides back navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Column(
              children: const [
                HomeDetailsAppBar(),
                Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('تنظيف المنزل'), findsOneWidget);
    expect(find.byTooltip('الرجوع'), findsOneWidget);
    final rect = tester.getRect(find.byType(HomeDetailsAppBar));
    expect(rect.height, lessThan(90));
    expect(tester.takeException(), isNull);
  });
}
