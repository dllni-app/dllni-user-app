import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../sm_orders/view/screens/sm_order_details_screen.dart';
import '../../../sm_orders/view/widgets/order_card.dart';
import '../manager/bloc/orders_bloc.dart';
import '../screens/restaurant_order_tracking_screen.dart';
import 'restaurant_order_card.dart';

class OrdersListBody extends StatelessWidget {
  const OrdersListBody({super.key, required this.state, required this.scrollController});

  final OrdersState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final isStoresSection = state.selectedTabIndex == 0;
    if (state.status == BlocStatus.loading && state.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == BlocStatus.failed && state.orders.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: context.height * .2),
          Center(child: AppText.labelLarge(state.errorMessage ?? 'تعذر تحميل الطلبات')),
        ],
      );
    }
    if (state.orders.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: context.height * .2),
          const Center(child: Text('لا توجد طلبات حالياً')),
        ],
      );
    }
    return Stack(
      children: [
        ListView.separated(
          controller: scrollController,
          padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
          itemBuilder: (context, index) {
            if (index == state.orders.length) {
              return const Center(
                child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()),
              );
            }
            final order = state.orders[index];
            if (isStoresSection) {
              return OrderCard(
                order: order,
                onTap: () {
                  context.pushRoute(
                    '/order_details',
                    arguments: SmOrderDetailsScreenArgs(order: order),
                  );
                },
              );
            }
            return RestaurantOrderCard(
              order: order,
              merchantLabel: 'المطعم:',
              onTap: () {
                context.pushRoute(
                  '/restaurant-order-tracking',
                  arguments: RestaurantOrderTrackingArgs(
                    order: order,
                    section: 'restaurant',
                  ),
                );
              },
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemCount: state.orders.length + (state.isLoadingMore ? 1 : 0),
        ),
        if (state.status == BlocStatus.loading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}
