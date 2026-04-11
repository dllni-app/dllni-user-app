import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'orders_filter_tap_bar.dart';

class OrdersAppBar extends StatelessWidget {
  const OrdersAppBar({super.key, required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(27), offset: Offset(0, 4), blurRadius: 5, spreadRadius: 0)],
      ),
      width: context.width,
      child: Column(
        children: [
          SizedBox(height: 20),
          AppText.titleLarge('طلباتي', fontWeight: FontWeight.bold, color: Color(0xff1E2A78)),
          SizedBox(height: 25),
          CategoriesTabBar(selectedIndex: selectedIndex, onChanged: onChanged),
        ],
      ),
    );
  }
}
