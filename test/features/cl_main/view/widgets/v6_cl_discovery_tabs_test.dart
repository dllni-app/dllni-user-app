import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_main_service_tabs_widget.dart';

void main() {
  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('V6 discovery tabs preserve indices at ${width.toInt()}dp', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var chosen = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: ClMainServiceTabsWidget(
                selectedIndex: ClMainServiceTabsWidget.cleaningIndex,
                onChanged: (i) => chosen = i,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('cl_main_occasions_tab')));
      expect(chosen, ClMainServiceTabsWidget.occasionsIndex);
      await tester.tap(find.byKey(const Key('cl_main_hourly_tab')));
      expect(chosen, ClMainServiceTabsWidget.hourlyIndex);
      expect(tester.takeException(), isNull);
    });
  }
}
