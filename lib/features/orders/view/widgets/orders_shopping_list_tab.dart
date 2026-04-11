import 'package:flutter/material.dart';
import 'restaurant_cart_checkout_body.dart';

class OrdersShoppingListTab extends StatelessWidget {
  const OrdersShoppingListTab({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RestaurantCartCheckoutBody(onRefresh: onRefresh);
  }
}
