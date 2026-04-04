import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../home/view/screens/home_screen.dart';
import '../../../orders/view/screens/orders_screen.dart';
import '../widgets/bottom_nav_bar.dart';

@AutoRoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.returnedIndex});

  final int? returnedIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    if (widget.returnedIndex != null) {
      controller.index = widget.returnedIndex!;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: TabBarView(controller: controller, physics: NeverScrollableScrollPhysics(), children: [HomeScreen(), OrdersScreen(), HomeScreen()]),
      ),
      bottomNavigationBar: BottomNavBar(controller: controller),
    );
  }
}
