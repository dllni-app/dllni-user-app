import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/bloc/orders_bloc.dart';
import 'orders_app_bar.dart';
import 'orders_cart_orders_segment_bar.dart';
import 'orders_list_body.dart';
import 'orders_screen_segment_section.dart';
import 'orders_shopping_list_tab.dart';

class OrdersListTab extends StatefulWidget {
  const OrdersListTab({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onRefresh,
    required this.onRefreshCart,
    required this.onSectionChanged,
  });

  final OrdersState state;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRefreshCart;
  final ValueChanged<int> onSectionChanged;

  @override
  State<OrdersListTab> createState() => _OrdersListTabState();
}

class _OrdersListTabState extends State<OrdersListTab> {

  int segmentIndex = OrdersCartOrdersSegmentBar.ordersIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OrdersAppBar(selectedIndex: widget.state.selectedTabIndex, onChanged: widget.onSectionChanged),
        const SizedBox(height: 14),
        OrdersScreenSegmentSection(
          selectedIndex: segmentIndex,
          onChanged: (index) {
            setState(() => segmentIndex = index);
            if (index == OrdersCartOrdersSegmentBar.cartIndex) {
              context.read<OrdersBloc>().add(FetchRestaurantCartEvent());
            }
          },
        ),
        Expanded(
          child: IndexedStack(
            index: segmentIndex,
            sizing: StackFit.expand,
            children: [
              OrdersShoppingListTab(
                onRefresh: widget.onRefreshCart,
              ),
              RefreshIndicator(
                onRefresh: widget.onRefresh,
                child: OrdersListBody(state: widget.state, scrollController: widget.scrollController),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
