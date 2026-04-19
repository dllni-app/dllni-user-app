import 'package:dllni_user_app/core/di/injection.dart';
import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/bloc/orders_bloc.dart';
import '../widgets/orders_cart_orders_segment_bar.dart';
import '../widgets/orders_list_tab.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, this.initialSectionIndex = 0, this.initialSegmentIndex = OrdersCartOrdersSegmentBar.ordersIndex});

  final int initialSectionIndex;
  final int initialSegmentIndex;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ScrollController _scrollController = ScrollController();

  Future<void> _refreshOrders(BuildContext context) async {
    final bloc = context.read<OrdersBloc>();
    bloc.add(FetchOrdersEvent(isReload: true));
    await bloc.stream.firstWhere((state) {
      final pagination = state.selectedTabIndex == 2 ? state.cleaningOrders : state.orders;
      return pagination.status != BlocStatus.loading;
    });
  }

  Future<void> _refreshCart(BuildContext context) async {
    final bloc = context.read<OrdersBloc>();
    final waitingForStores = bloc.state.isStoresSection();
    bloc.add(FetchCartForActiveSectionEvent());
    await bloc.stream.firstWhere((state) {
      final status = waitingForStores ? state.storeCartStatus : state.restaurantCartStatus;
      return status != BlocStatus.loading;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrdersBloc>()..add(OrdersSectionChangedEvent(widget.initialSectionIndex)),
      child: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          return Scaffold(
            body: OrdersListTab(
              state: state,
              initialSegmentIndex: widget.initialSegmentIndex,
              scrollController: _scrollController,
              onRefresh: () => _refreshOrders(context),
              onRefreshCart: () => _refreshCart(context),
              onSectionChanged: (index) {
                context.read<OrdersBloc>().add(OrdersSectionChangedEvent(index));
              },
            ),
          );
        },
      ),
    );
  }
}
