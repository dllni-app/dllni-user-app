import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:dllni_user_app/core/themes/app_theme.dart';
import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/widgets/app_nav_bar.dart';
import 'sm_discover/view/screens/sm_discover_screen.dart';
import 'sm_home/view/screens/sm_home_screen.dart';
import 'sm_favorite/view/screens/sm_favorite_screen.dart';
import 'sm_offers/view/screens/sm_offers_screen.dart';

class SmMainScreenParams {
  final int? initialPage;
  final bool expandSearch;

  SmMainScreenParams({required this.initialPage, this.expandSearch = false});
}

@AutoRoutePage(path: "/smmain")
class SmMainPage extends StatefulWidget {
  const SmMainPage({super.key, required this.params});

  final SmMainScreenParams params;

  @override
  State<SmMainPage> createState() => _SmMainPageState();
}

class _SmMainPageState extends State<SmMainPage>
    with SingleTickerProviderStateMixin {
  int selectedTab = 0;
  bool expandSearch = false;

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    if (widget.params.initialPage != null) {
      selectedTab = widget.params.initialPage!;
    }
    expandSearch = widget.params.expandSearch;
    tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: selectedTab,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.forSection('supermarket'),
      child: Scaffold(
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: tabController,
          children: [
            SmHomeScreen(),
            SmDiscoverScreen(
              params: SmDiscoverScreenParams(expandSearch: expandSearch),
            ),
            SmFavoriteScreen(),
            SmOffersScreen(),
          ],
        ),
        bottomNavigationBar: AppNavBar(
          accentColor: SharedPlatformColors.supermarket,
          items: [
            AppNavBarItem(title: "المتاجر", icon: FontAwesomeIcons.solidHouse),
            AppNavBarItem(title: "تصفح", icon: FontAwesomeIcons.solidCompass),
            AppNavBarItem(title: "المفضلة", icon: FontAwesomeIcons.tags),
            AppNavBarItem(title: "العروض", icon: FontAwesomeIcons.percent),
          ],
          selectedIndex: selectedTab,
          onChanged: (index) {
            if (index != selectedTab) {
              if (selectedTab == 1) {
                expandSearch = false;
              }
              selectedTab = index;
              setState(() {});
              tabController.animateTo(selectedTab);
            }
          },
        ),
      ),
    );
  }
}
