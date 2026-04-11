import 'package:dllni_user_app/core/di/injection.dart';
import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/bloc/orders_bloc.dart';
import '../widgets/orders_list_tab.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ScrollController _scrollController = ScrollController();

  Future<void> _refreshOrders(BuildContext context) async {
    final bloc = context.read<OrdersBloc>();
    bloc.add(FetchOrdersEvent(isReload: true));
    await bloc.stream.firstWhere((state) => state.status != BlocStatus.loading);
  }

  Future<void> _refreshCart(BuildContext context) async {
    final bloc = context.read<OrdersBloc>();
    bloc.add(FetchRestaurantCartEvent());
    await bloc.stream.firstWhere((state) => state.restaurantCartStatus != BlocStatus.loading);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      context.read<OrdersBloc>().add(LoadMoreOrdersEvent());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrdersBloc>()
        ..add(FetchOrdersEvent(isReload: true))
        ..add(FetchRestaurantCartEvent()),
      child: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          return OrdersListTab(
            state: state,
            scrollController: _scrollController,
            onRefresh: () => _refreshOrders(context),
            onRefreshCart: () => _refreshCart(context),
            onSectionChanged: (index) {
              context.read<OrdersBloc>().add(OrdersSectionChangedEvent(index));
            },
          );
        },
      ),
    );
  }
}
