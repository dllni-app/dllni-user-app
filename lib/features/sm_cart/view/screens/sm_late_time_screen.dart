import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../orders/view/screens/orders_screen.dart';
import '../../../orders/view/widgets/orders_cart_orders_segment_bar.dart';

@AutoRoutePage(path: "/late_time")
class SmLateTimeScreen extends StatelessWidget {
  const SmLateTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrdersScreen(
      initialSectionIndex: 0,
      initialSegmentIndex: OrdersCartOrdersSegmentBar.cartIndex,
    );
  }
}
