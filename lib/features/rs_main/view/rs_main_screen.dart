import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/rs_main/view/widgets/rs_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

import '../../rs_discover/view/screens/rs_discover_screen.dart';
import '../../rs_home/view/rs_home_screen.dart';
import '../../rs_offers/view/rs_offers_screen.dart';
import '../../rs_orders/view/rs_orders_screen.dart';
import '../../rs_profile/view/screens/rs_profile_screen.dart';

class RsMainScreen extends StatefulWidget {
  const RsMainScreen({super.key});

  @override
  State<RsMainScreen> createState() => _RsMainScreenState();
}

class _RsMainScreenState extends State<RsMainScreen> with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 5, vsync: this);
  }

  static const List<Widget> _pages = <Widget>[RsHomeScreen(), RsDiscoverScreen(), RsOffersScreen(), RsOrdersScreen(), RsProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        body: TabBarView(controller: controller, physics: NeverScrollableScrollPhysics(), children: _pages),
      ),
      bottomNavigationBar: RsBottomNavBar(controller: controller),
    );
  }
}
