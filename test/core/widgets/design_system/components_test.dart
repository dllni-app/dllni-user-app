import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/core/widgets/design_system/design_system.dart';

Widget wrap(Widget child) => MaterialApp(
  home: Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  testWidgets('button respects loading and disabled states', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        AppActionButton(
          label: 'متابعة',
          onPressed: () => taps++,
          loading: true,
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('متابعة'));
    expect(taps, 0);
    await tester.pumpWidget(
      wrap(AppActionButton(label: 'متابعة', onPressed: () => taps++)),
    );
    await tester.tap(find.text('متابعة'));
    expect(taps, 1);
  });

  testWidgets('counter enforces min/max and emits intentional change', (
    tester,
  ) async {
    var value = 0;
    await tester.pumpWidget(
      wrap(
        AppCounter(
          label: 'غرف النوم',
          value: value,
          minimum: 0,
          maximum: 1,
          onChanged: (newValue) => value = newValue,
        ),
      ),
    );
    await tester.tap(find.byTooltip('إنقاص غرف النوم'), warnIfMissed: false);
    expect(value, 0);
    await tester.tap(find.byTooltip('زيادة غرف النوم'));
    expect(value, 1);
    await tester.pumpWidget(
      wrap(
        AppCounter(
          label: 'غرف النوم',
          value: value,
          minimum: 0,
          maximum: 1,
          onChanged: (newValue) => value = newValue,
        ),
      ),
    );
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.add_circle_outline),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('choice and progress expose current values', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        Column(
          children: [
            AppChoiceTile(
              title: 'تنظيف عادي',
              selected: true,
              onTap: () => tapped = true,
            ),
            const AppStepProgress(current: 2, total: 6),
          ],
        ),
      ),
    );
    expect(find.text('الخطوة 2 من 6'), findsOneWidget);
    await tester.tap(find.text('تنظيف عادي'));
    expect(tapped, isTrue);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      closeTo(1 / 3, .00001),
    );
  });

  testWidgets('danger confirmation can be safely dismissed', (tester) async {
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => AppActionButton(
            label: 'إلغاء',
            onPressed: () async {
              final confirmed = await AppConfirmSheet.ask(
                context,
                title: 'إلغاء الطلب',
                message: 'هل تريد المتابعة؟',
                confirmLabel: 'تأكيد الإلغاء',
                danger: true,
              );
              expect(confirmed, isFalse);
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect(find.text('تأكيد الإلغاء'), findsOneWidget);
    await tester.tap(find.text('تراجع'));
    await tester.pumpAndSettle();
  });

  testWidgets('backend formatted price not recalculated in UI', (tester) async {
    await tester.pumpWidget(
      wrap(
        const AppPriceSummary(
          lines: [AppPriceLine(label: 'خدمة', formattedAmount: '10,000 ل.س')],
          totalFormatted: '12,500 ل.س',
          provisional: true,
        ),
      ),
    );
    expect(find.text('12,500 ل.س'), findsOneWidget);
    expect(find.text('سعر تقديري'), findsOneWidget);
  });
}
