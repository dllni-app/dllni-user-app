import 'package:dllni_user_app/core/themes/app_theme.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_assignment_mode.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_main_service_tabs_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_assignment_mode_section_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_bottom_actions_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('booking foundations fit narrow 320dp RTL layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.forSection('cleaning'),
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                ClMainServiceTabsWidget(selectedIndex: 0, onChanged: (_) {}),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      ClServiceAssignmentModeSectionWidget(
                        selectedMode: CleaningAssignmentMode.openCount,
                        onModeChanged: (_) {},
                      ),
                    ],
                  ),
                ),
                ClServiceBottomActionsWidget(
                  onBackPressed: () {},
                  onSubmitPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('التنظيفات'), findsOneWidget);
    expect(find.text('اختيار العمال تلقائياً'), findsOneWidget);
    expect(find.text('أرسل الطلب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
