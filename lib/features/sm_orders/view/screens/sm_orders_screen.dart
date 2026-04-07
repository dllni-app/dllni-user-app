import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../widgets/order_card.dart';
import '../widgets/orders_simple_app_bar.dart';

class SmOrdersScreen extends StatefulWidget {
  const SmOrdersScreen({super.key});

  @override
  State<SmOrdersScreen> createState() => _SmOrdersScreenState();
}

class _SmOrdersScreenState extends State<SmOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      length: 4,
      vsync: this,
      animationDuration: Duration(milliseconds: 300),
    );
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SimpleAppBarWithTabBar(
            title: "طلباتي",
            items: ["الكل", "المتاجر", "المطاعم", "التنظيفات"],
            onChanged: (index) {
              _tabController.animateTo(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                4,
                (index) => ListView.separated(
                  padding: EdgeInsets.all(24),
                  itemCount: 5,
                  itemBuilder: (context, index) => OrderCard(
                    isScheduled: index % 2 == 0,
                    onTap: () {
                      context.pushRoute("/order_tracking");
                    },
                  ),
                  separatorBuilder: (context, index) => SizedBox(height: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
