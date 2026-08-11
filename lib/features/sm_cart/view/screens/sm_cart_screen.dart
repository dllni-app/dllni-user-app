import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../orders/view/screens/orders_screen.dart';
import '../../../orders/view/widgets/orders_cart_orders_segment_bar.dart';

@AutoRoutePage(path: "/cart")
class SmCartScreen extends StatelessWidget {
  const SmCartScreen({super.key, required this.params});

  final SmCartScreenParams? params;

  int _resolveInitialSectionIndex(BuildContext context) {
    final explicitIndex = params?.initialSectionIndex;
    if (explicitIndex != null) return explicitIndex;

    final pages = Navigator.of(context).widget.pages;
    if (pages.length < 2) return 0;

    final previousRouteName = (pages[pages.length - 2].name ?? '').toLowerCase();
    const restaurantRouteMarkers = <String>[
      'rs_',
      'rsmain',
      'rsstore',
      'rsproduct',
      'restaurant',
    ];

    return restaurantRouteMarkers.any(previousRouteName.contains) ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return OrdersScreen(
      initialSectionIndex: _resolveInitialSectionIndex(context),
      initialSegmentIndex: OrdersCartOrdersSegmentBar.cartIndex,
    );
  }
}

class SmCartScreenParams {
  final int initialSectionIndex;

  SmCartScreenParams({this.initialSectionIndex = 0});
}
