import 'package:flutter/material.dart';

import 'orders_cart_orders_segment_bar.dart';

class OrdersScreenSegmentSection extends StatelessWidget {
  const OrdersScreenSegmentSection({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
          child: OrdersCartOrdersSegmentBar(
            selectedIndex: selectedIndex,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
