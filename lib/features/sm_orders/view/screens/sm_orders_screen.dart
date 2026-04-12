import 'package:flutter/material.dart';
import '../../../orders/view/screens/orders_screen.dart';
import '../../../orders/view/widgets/orders_cart_orders_segment_bar.dart';

class SmOrdersScreen extends StatelessWidget {
  const SmOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrdersScreen(
      initialSectionIndex: 0,
      initialSegmentIndex: OrdersCartOrdersSegmentBar.ordersIndex,
    );
  }
}
