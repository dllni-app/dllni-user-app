import 'package:flutter/material.dart';
import '../manager/bloc/orders_bloc.dart';
import 'restaurant_cart_checkout_body.dart';
import 'supermarket_cart_checkout_body.dart';

class OrdersShoppingListTab extends StatelessWidget {
  const OrdersShoppingListTab({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  final OrdersState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (state.isStoresSection()) {
      return SupermarketCartCheckoutBody(onRefresh: onRefresh);
    }
    return RestaurantCartCheckoutBody(onRefresh: onRefresh);
  }
}
