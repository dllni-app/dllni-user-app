import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../orders/view/screens/orders_screen.dart';
import '../../../orders/view/widgets/orders_cart_orders_segment_bar.dart';

@AutoRoutePage(path: "/cart")
class SmCartScreen extends StatelessWidget {
  const SmCartScreen({super.key, required this.params});

  final SmCartScreenParams? params;

  @override
  Widget build(BuildContext context) {
    return OrdersScreen(
      initialSectionIndex: params?.initialSectionIndex ?? 0,
      initialSegmentIndex: OrdersCartOrdersSegmentBar.cartIndex,
    );
  }
}

class SmCartScreenParams {
  final int initialSectionIndex;

  SmCartScreenParams({this.initialSectionIndex = 0});
}
