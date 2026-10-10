import 'package:dllni_user_app/core/themes/app_theme.dart';
import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:dllni_user_app/core/widgets/app_app_bars.dart';
import 'package:dllni_user_app/core/widgets/app_buttons.dart';
import 'package:dllni_user_app/core/widgets/app_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  testWidgets(
    'primary CTA and section-colored navigation retain interactions',
    (tester) async {
      var tappedPrimary = false;
      var selectedTab = -1;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.forSection('supermarket'),
          home: Scaffold(
            body: Center(
              child: AppButton(
                title: 'تأكيد الطلب',
                onTap: () => tappedPrimary = true,
              ),
            ),
            bottomNavigationBar: AppNavBar(
              selectedIndex: 0,
              accentColor: SharedPlatformColors.supermarket,
              onChanged: (index) => selectedTab = index,
              items: [
                AppNavBarItem(title: 'الرئيسية', icon: FontAwesomeIcons.house),
                AppNavBarItem(title: 'تصفح', icon: FontAwesomeIcons.compass),
              ],
            ),
          ),
        ),
      );

      expect(find.text('تأكيد الطلب'), findsOneWidget);
      expect(find.text('تصفح'), findsOneWidget);
      await tester.tap(find.text('تأكيد الطلب'));
      await tester.tap(find.text('تصفح'));
      expect(tappedPrimary, isTrue);
      expect(selectedTab, 1);
    },
  );

  testWidgets('light header uses brand text and a contextual border', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.forSection('restaurant'),
        home: const Scaffold(
          body: AppSimpleAppBar(
            title: 'المطاعم',
            canPop: false,
            section: 'restaurant',
          ),
        ),
      ),
    );
    expect(find.text('المطاعم'), findsOneWidget);
    expect(SharedPlatformColors.restaurant, isNot(SharedPlatformColors.danger));
  });
}
