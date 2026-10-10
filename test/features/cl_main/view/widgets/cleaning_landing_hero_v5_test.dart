import 'package:dllni_user_app/features/cl_main/view/widgets/cl_cleaning_landing_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in <double>[320, 390, 430]) {
    testWidgets('cleaning fallback hero is responsive at ${width.toInt()} dp', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClCleaningLandingHero(onBookApartment: () => taps++),
              ),
            ),
          ),
        ),
      );

      expect(find.text('بيتك أنظف، ووقتك إلك'), findsOneWidget);
      expect(find.text('احجز تنظيف شقة'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(
        find.byKey(const Key('cl_cleaning_hero_apartment_booking')),
      );
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
