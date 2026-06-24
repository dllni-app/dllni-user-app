import 'package:flutter/material.dart';

import 'supermarket_cart_checkout_body.dart';

class StoresCartCheckoutBody extends StatelessWidget {
  const StoresCartCheckoutBody({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return SupermarketCartCheckoutBody(onRefresh: onRefresh);
  }
}
