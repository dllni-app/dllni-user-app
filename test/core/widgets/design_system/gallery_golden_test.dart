import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/core/widgets/design_system/design_system_gallery.dart';

void configureView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('V6 component gallery screenshot at 390dp RTL', (tester) async {
    configureView(tester, const Size(390, 844));
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DesignSystemGallery(),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(DesignSystemGallery),
      matchesGoldenFile('goldens/v6_components_390_rtl.png'),
    );
  });

  testWidgets('V6 secondary, disabled and loading states at 320dp RTL', (
    tester,
  ) async {
    configureView(tester, const Size(320, 720));
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DesignSystemGallery(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1250));
    // Indeterminate progress animations remain active in this gallery.
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(DesignSystemGallery),
      matchesGoldenFile('goldens/v6_states_320_rtl.png'),
    );
    expect(tester.takeException(), isNull);
  });
}
