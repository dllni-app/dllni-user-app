import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../widgets/orders_app_bar.dart';
import '../widgets/restaurant_order_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OrdersAppBar(),
        SizedBox(height: 14),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
            itemBuilder: (context, index) => RestaurantOrderCard(),
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemCount: 3,
          ),
        ),
      ],
    );
  }
}
