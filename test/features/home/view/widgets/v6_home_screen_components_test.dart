import 'package:dllni_user_app/features/home/view/widgets/platform_home_experience_v5.dart';
import 'package:dllni_user_app/features/home/view/widgets/v6_home_widgets.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/v6_cleaning_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget widget) => MaterialApp(
  home: Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: widget,
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'home search filters service destinations and invokes real callback',
    (tester) async {
      var cleaning = 0;
      var restaurants = 0;
      await tester.pumpWidget(
        _wrap(
          V6ServiceFinder(
            onCleaning: () => cleaning++,
            onRestaurants: () => restaurants++,
            onSupermarket: () {},
            onDelivery: null,
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const Key('v6_home_service_search')),
        'تنظ',
      );
      await tester.pump();
      expect(find.text('التنظيفات'), findsOneWidget);
      expect(find.text('المطاعم'), findsNothing);
      await tester.tap(find.text('التنظيفات'));
      expect(cleaning, 1);
      expect(restaurants, 0);
    },
  );

  testWidgets('new header preserves notifications and address controls', (
    tester,
  ) async {
    var notifications = 0;
    var locations = 0;
    await tester.pumpWidget(
      _wrap(
        V6HomeHeader(
          displayName: 'سارة',
          locationLabel: 'المنزل',
          isAuthenticated: true,
          unreadCount: 3,
          onNotificationsTap: () => notifications++,
          onLocationTap: () => locations++,
        ),
      ),
    );
    expect(find.textContaining('سارة'), findsOneWidget);
    expect(find.text('المنزل'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await tester.tap(find.text('المنزل'));
    expect(notifications, 1);
    expect(locations, 1);
  });

  testWidgets(
    'cleaning discovery explains when to use the tab without duplicate booking actions',
    (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _wrap(V6CleaningDiscoveryIntro(onBookApartment: () => pressed++)),
      );
      expect(find.text('متى تختار التنظيفات؟'), findsOneWidget);
      expect(find.text('مكان يحتاج عناية'), findsOneWidget);
      expect(find.text('تنظيف عادي'), findsNothing);
      expect(find.text('تنظيف عميق'), findsNothing);
      expect(find.text('ابدأ حجز تنظيف شقة'), findsNothing);
      expect(pressed, 0);
    },
  );

  testWidgets(
    'V6 active order opens details and guest prompt retains auth callbacks',
    (tester) async {
      var details = 0;
      var login = 0;
      var register = 0;
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              V6HomeActiveOrder(
                section: 'cleaning',
                sectionLabel: 'تنظيف',
                title: 'خدمة تنظيف',
                status: 'جاري تأكيد طلبك',
                meta: 'الثلاثاء 20 أكتوبر',
                onTap: () => details++,
              ),
              V6GuestAccountPrompt(
                onLogin: () => login++,
                onRegister: () => register++,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('عرض التفاصيل'));
      await tester.tap(find.text('دخول'));
      await tester.tap(find.text('إنشاء حساب'));
      expect(details, 1);
      expect(login, 1);
      expect(register, 1);
    },
  );

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('V6 category cards fit ${width.toInt()}dp RTL at large text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
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
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
