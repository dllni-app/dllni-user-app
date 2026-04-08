import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/widgets/app_nav_bar.dart';
import 'sm_discover/view/screens/sm_discover_screen.dart';
import 'sm_home/view/screens/sm_home_screen.dart';
import 'sm_favorite/view/screens/sm_favorite_screen.dart';

@AutoRoutePage(path: "/")
class SmMainPage extends StatefulWidget {
  const SmMainPage({super.key, this.initialPage, this.expandSearch = false});
  final int? initialPage;

  /// this property just for open [AppSimpleAppBarWithSearch] by default if it is [true]
  final bool expandSearch;
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
    if (widget.initialPage != null) selectedTab = widget.initialPage!;
    expandSearch = widget.expandSearch;
    tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: selectedTab,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          SmHomeScreen(),
          SmDiscoverScreen(expandSearch: expandSearch),
          SmFavoriteScreen(),
          // SmOrdersScreen(),
          // SmProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppNavBar(
        items: [
          AppNavBarItem(title: "الرئيسية", icon: FontAwesomeIcons.solidHouse),
          AppNavBarItem(title: "تصفح", icon: FontAwesomeIcons.solidCompass),
          AppNavBarItem(title: "المفضلة", icon: FontAwesomeIcons.tags),
          // AppNavBarItem(title: "طلباتي", icon: FontAwesomeIcons.receipt),
          // AppNavBarItem(title: "حسابي", icon: FontAwesomeIcons.user),
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
    );
  }
}

class _OnDevelopingScreen extends StatelessWidget {
  const _OnDevelopingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "هذه الصفحة قيد التطوير 🚧",
          style: TextStyle(
            color: Color(0xFF1E2A78),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 28 / 18,
          ),
        ),
      ),
    );
  }
}
