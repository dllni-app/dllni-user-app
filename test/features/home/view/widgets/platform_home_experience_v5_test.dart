import 'package:dllni_user_app/features/home/view/widgets/platform_home_experience_v5.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in <double>[320, 390, 430]) {
    testWidgets('main services remain usable on ${width.toInt()}px screen', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      var cleaning = 0;
      var restaurants = 0;
      var supermarket = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: PlatformHomeExperienceV5(
                  onCleaning: () => cleaning++,
                  onRestaurants: () => restaurants++,
                  onSupermarket: () => supermarket++,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('ع الندهة'), findsOneWidget);
      await tester.tap(find.byKey(const Key('platform_home_v5_cleaning_cta')));
      await tester.tap(
        find.byKey(const Key('platform_home_v5_restaurants_tile')),
      );
      await tester.tap(
        find.byKey(const Key('platform_home_v5_supermarket_tile')),
      );
      expect(cleaning, 1);
      expect(restaurants, 1);
      expect(supermarket, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
