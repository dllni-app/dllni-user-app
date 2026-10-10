import 'package:dllni_user_app/features/cl_main/view/widgets/cl_redesign_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('counter prevents adding above the server limit', (tester) async {
    var additions = 0;
    var removals = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: ClRedesignCounter(
              label: 'غرف النوم',
              value: 20,
              maxValue: 20,
              onIncrement: () => additions++,
              onDecrement: () => removals++,
            ),
          ),
        ),
      ),
    );

    final addButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.add),
    );
    expect(addButton.onPressed, isNull);
    await tester.tap(find.widgetWithIcon(IconButton, Icons.remove));
    expect(additions, 0);
    expect(removals, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sticky booking CTA disables until the step is valid', (
    tester,
  ) async {
    var pressed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClRedesignStickyActions(
            primaryLabel: 'التالي',
            primaryEnabled: false,
            onPrimary: () => pressed++,
          ),
        ),
      ),
    );
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(pressed, 0);
  });
}
