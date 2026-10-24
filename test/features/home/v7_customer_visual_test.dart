import 'package:dllni_user_app/features/home/data/models/fetch_user_offers_model.dart';
import 'package:dllni_user_app/features/home/view/widgets/home_cube.dart';
import 'package:dllni_user_app/features/home/view/widgets/platform_home_experience_v5.dart';
import 'package:dllni_user_app/features/home/view/widgets/v7_campaign_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final offers = [
    UserOfferItem(
      title: 'عرض خدمة تنظيف',
      description: 'تفاصيل العرض',
      imageUrl: '',
      discountLabel: 'حسب العرض',
    ),
  ];

  testWidgets('V7 editorial ads are the default; cube is not built', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: V7CampaignPresenter(offers: offers)),
      ),
    );
    expect(V7CampaignConfig.selected, V7CampaignStyle.editorial);
    expect(find.text('عرض خدمة تنظيف'), findsOneWidget);
    expect(find.byType(HomeCube), findsNothing);
  });

  testWidgets('V7 cube is retained behind an explicit mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: V7CampaignPresenter(
            offers: offers,
            style: V7CampaignStyle.cube,
          ),
        ),
      ),
    );
    expect(find.byType(HomeCube), findsOneWidget);
  });

  testWidgets('home cube shows a neutral service banner without offers', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HomeCube(offers: [])),
      ),
    );

    expect(find.text('اكتشف خدماتنا'), findsOneWidget);
    expect(
      find.text('خدمات التنظيف والمطاعم والتسوق والتوصيل'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'V7 service entry shows four categories and preserves callbacks',
    (tester) async {
      var cleaningTaps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PlatformHomeExperienceV5(
                onCleaning: () => cleaningTaps++,
                onRestaurants: () {},
                onSupermarket: () {},
                onDelivery: () {},
              ),
            ),
          ),
        ),
      );
      expect(find.text('التنظيفات'), findsOneWidget);
      expect(find.text('المطاعم'), findsOneWidget);
      expect(find.text('السوبرماركت'), findsOneWidget);
      expect(find.text('التوصيل'), findsOneWidget);
      await tester.tap(find.text('التنظيفات'));
      expect(cleaningTaps, 1);
    },
  );

  testWidgets('V7 four service cards remain readable at 320dp RTL', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: PlatformHomeExperienceV5(
                onCleaning: () {},
                onRestaurants: () {},
                onSupermarket: () {},
                onDelivery: () {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('التنظيفات'), findsOneWidget);
    expect(find.text('التوصيل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty offers do not create a fictitious promotion', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: V7CampaignPresenter(offers: [])),
      ),
    );
    expect(find.byType(HomeCube), findsNothing);
    expect(find.byType(PageView), findsNothing);
  });
}
