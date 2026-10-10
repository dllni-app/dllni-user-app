import 'package:dllni_user_app/core/themes/app_theme.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_cleaning_type_option_card_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_counter_row_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_main_continue_button_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_main_service_tabs_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_option_tile_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_bottom_actions_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_worker_count_selector_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget widget) => MaterialApp(
  theme: AppTheme.forSection('cleaning'),
  home: Scaffold(
    body: Directionality(
      textDirection: TextDirection.rtl,
      child: Center(child: widget),
    ),
  ),
);

void main() {
  testWidgets('cleaning tabs keep existing selection callbacks', (
    tester,
  ) async {
    var selected = -1;
    await tester.pumpWidget(
      _app(
        ClMainServiceTabsWidget(
          selectedIndex: 0,
          onChanged: (index) => selected = index,
        ),
      ),
    );
    await tester.tap(find.text('المناسبات'));
    expect(selected, 1);
    await tester.tap(find.text('عامل بالساعة'));
    expect(selected, 2);
  });

  testWidgets('primary continue obeys enabled/disabled state', (tester) async {
    var submits = 0;
    await tester.pumpWidget(
      _app(ClMainContinueButtonWidget(onPressed: () => submits++)),
    );
    await tester.tap(find.text('متابعة'));
    expect(submits, 1);
    await tester.pumpWidget(
      _app(const ClMainContinueButtonWidget(onPressed: null)),
    );
    await tester.tap(find.text('متابعة'));
    expect(submits, 1);
  });

  testWidgets('booking actions invoke same submit/back handlers', (
    tester,
  ) async {
    var submit = 0;
    var back = 0;
    await tester.pumpWidget(
      _app(
        ClServiceBottomActionsWidget(
          onBackPressed: () => back++,
          onSubmitPressed: () => submit++,
        ),
      ),
    );
    await tester.tap(find.text('أرسل الطلب'));
    await tester.tap(find.text('تراجع'));
    expect(submit, 1);
    expect(back, 1);
  });

  testWidgets('type selection remains actionable', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(
        ClCleaningTypeOptionCardWidget(
          title: 'تنظيف عادي',
          subtitle: 'تفاصيل الخدمة',
          isSelected: true,
          onTap: () => taps++,
        ),
      ),
    );
    await tester.tap(find.text('تنظيف عادي'));
    expect(taps, 1);
  });

  testWidgets('checkbox toggle emits selected value', (tester) async {
    bool? selected;
    await tester.pumpWidget(
      _app(
        ClOptionTileWidget(
          title: 'خدمة إضافية',
          value: false,
          onChanged: (value) => selected = value,
        ),
      ),
    );
    await tester.tap(find.text('خدمة إضافية'));
    expect(selected, isTrue);
  });

  testWidgets('room counter increment preserves callbacks', (tester) async {
    var increments = 0;
    await tester.pumpWidget(
      _app(
        ClCounterRowWidget(
          label: 'غرفة نوم',
          value: 2,
          onIncrement: () => increments++,
          onDecrement: () {},
          icon: Icons.bed,
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.add));
    expect(increments, 1);
  });

  testWidgets('worker count respects max and minimum', (tester) async {
    var proposed = -1;
    await tester.pumpWidget(
      _app(
        ClServiceWorkerCountSelectorWidget(
          count: 1,
          maxCount: 2,
          onChanged: (v) => proposed = v,
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.add));
    expect(proposed, 2);
    await tester.tap(find.byIcon(Icons.remove));
    expect(proposed, 2); // Minimum one; minus is disabled at count 1.
  });
}
