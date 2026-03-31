import 'package:flutter/material.dart';

import '../widgets/order_card.dart';
import '../widgets/orders_simple_app_bar.dart';

class SmOrdersScreen extends StatelessWidget {
  const SmOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          OrdersSimpleAppBar(),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(24),
              itemCount: 5,
              itemBuilder: (context, index) => OrderCard(),
              separatorBuilder: (context, index) => SizedBox(height: 16),
            ),
          ),
        ],
      ),
    );
  }
}
