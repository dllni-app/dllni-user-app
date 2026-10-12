import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_redesign_components.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_cleaning_type_option_card_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/v6_hourly_service_guide.dart';

Widget wrap(Widget child, {double scale = 1}) => MaterialApp(
  builder: (context, widget) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: widget!,
  ),
  home: Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'hourly discovery explains when to choose the tab without booking steps',
    (tester) async {
      await tester.pumpWidget(wrap(const V6HourlyServiceGuide()));
      expect(find.text('متى تختار عاملاً بالساعة؟'), findsOneWidget);
      expect(find.text('ترتيب أو تنظيم المنزل'), findsOneWidget);
      expect(find.text('حاجة مؤقتة بمدة غير محسومة'), findsOneWidget);
      expect(find.text('كيف يعمل الحجز؟'), findsNothing);
      expect(find.textContaining('خطوات الحجز'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('booking action bar disables submission and routes previous', (
    tester,
  ) async {
    var calls = 0;
    var previous = 0;
    await tester.pumpWidget(
      wrap(
        Column(
          children: [
            ClRedesignStickyActions(
              primaryLabel: 'تأكيد الحجز',
              onPrimary: () => calls++,
              primaryEnabled: false,
              secondaryLabel: 'السابق',
              onSecondary: () => previous++,
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('السابق'));
    expect(previous, 1);
    await tester.tap(find.text('تأكيد الحجز'), warnIfMissed: false);
    expect(calls, 0);
  });

  testWidgets('room counter retains caller increment and max rule', (
    tester,
  ) async {
    var incremented = 0;
    await tester.pumpWidget(
      wrap(
        ClRedesignCounter(
          label: 'غرف النوم',
          value: 1,
          maxValue: 2,
          onIncrement: () => incremented++,
          onDecrement: () {},
        ),
      ),
    );
    await tester.tap(find.byTooltip('زيادة العدد'));
    expect(incremented, 1);
  });

  testWidgets('cleaning mode card preserves selection action', (tester) async {
    var changes = 0;
    await tester.pumpWidget(
      wrap(
        ClCleaningTypeOptionCardWidget(
          title: 'تنظيف عميق',
          subtitle: 'تنظيف تفصيلي',
          isSelected: true,
          onTap: () => changes++,
        ),
      ),
    );
    await tester.tap(find.text('تنظيف عميق'));
    expect(changes, 1);
  });

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('V6 size choice and step fit ${width.toInt()} dp RTL', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        wrap(
          Column(
            children: [
              const ClRedesignStepHeader(
                currentStep: 2,
                totalSteps: 6,
                title: 'اختر أحجام الغرف',
                subtitle: 'اختر الحجم المناسب لكل مساحة',
              ),
              ClRedesignSegmentedChoice<int>(
                values: const [1, 2, 3],
                selected: 2,
                labelFor: (v) => ['صغيرة', 'متوسطة', 'كبيرة'][v - 1],
                onChanged: (v) {},
              ),
            ],
          ),
          scale: 1.5,
        ),
      );
      expect(tester.takeException(), isNull);
      // Full room-size words remain readable; do not stack one letter per line.
      expect(tester.getSize(find.text('متوسطة')).height, lessThan(64));
    });
  }
}
