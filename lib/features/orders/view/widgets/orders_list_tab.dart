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
    this.initialSegmentIndex = OrdersCartOrdersSegmentBar.ordersIndex,
    required this.scrollController,
    required this.onRefresh,
    required this.onRefreshCart,
    required this.onSectionChanged,
  });

  final OrdersState state;
  final int initialSegmentIndex;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRefreshCart;
  final ValueChanged<int> onSectionChanged;

  @override
  State<OrdersListTab> createState() => _OrdersListTabState();
}

class _OrdersListTabState extends State<OrdersListTab> {
  late int segmentIndex;

  @override
  void initState() {
    super.initState();
    segmentIndex = widget.initialSegmentIndex;
    if (segmentIndex == OrdersCartOrdersSegmentBar.cartIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<OrdersBloc>().add(FetchCartForActiveSectionEvent());
      });
    }
  }

  @override
  void didUpdateWidget(covariant OrdersListTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.selectedTabIndex != widget.state.selectedTabIndex && segmentIndex == OrdersCartOrdersSegmentBar.cartIndex) {
      context.read<OrdersBloc>().add(FetchCartForActiveSectionEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCleaningSection = widget.state.selectedTabIndex == 2;
    final effectiveSegmentIndex = isCleaningSection ? OrdersCartOrdersSegmentBar.ordersIndex : segmentIndex;
    return Column(
      children: [
        OrdersAppBar(selectedIndex: widget.state.selectedTabIndex, onChanged: widget.onSectionChanged),
        if (!isCleaningSection) ...[
          const SizedBox(height: 14),
          OrdersScreenSegmentSection(
            selectedIndex: segmentIndex,
            onChanged: (index) {
              setState(() => segmentIndex = index);
              if (index == OrdersCartOrdersSegmentBar.cartIndex) {
                context.read<OrdersBloc>().add(FetchCartForActiveSectionEvent());
              }
            },
          ),
        ],
        Expanded(
          child: IndexedStack(
            index: effectiveSegmentIndex,
            sizing: StackFit.expand,
            children: [
              OrdersShoppingListTab(state: widget.state, onRefresh: widget.onRefreshCart),
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
