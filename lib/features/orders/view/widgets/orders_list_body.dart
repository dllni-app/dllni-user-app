import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../sm_orders/view/screens/sm_order_details_screen.dart';
import '../../../sm_orders/view/widgets/order_card.dart';
import '../manager/bloc/orders_bloc.dart';
import '../screens/cleaning_order_details_screen.dart';
import '../screens/cleaning_order_reschedule_screen.dart';
import '../screens/cleaning_order_problem_report_screen.dart';
import '../screens/restaurant_order_tracking_screen.dart';
import 'cleaning_cancel_reason_dialog.dart';
import 'cleaning_order_card.dart';
import 'restaurant_order_card.dart';

class OrdersListBody extends StatelessWidget {
  const OrdersListBody({
    super.key,
    required this.state,
    required this.scrollController,
  });

  final OrdersState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final isStoresSection = state.selectedTabIndex == 0;
    final isCleaningSection = state.selectedTabIndex == 2;
    final listLength = isCleaningSection
        ? state.cleaningOrders.length
        : state.orders.length;
    if (state.status == BlocStatus.loading && listLength == 0) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == BlocStatus.failed && listLength == 0) {
      return ListView(
        children: [
          SizedBox(height: context.height * .2),
          Center(
            child: AppText.labelLarge(
              state.errorMessage ?? 'تعذر تحميل الطلبات',
            ),
          ),
        ],
      );
    }
    if (listLength == 0) {
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
            if (index == listLength) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (isCleaningSection) {
              final cleaningOrder = state.cleaningOrders[index];
              return BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  return CleaningOrderCard(
                    order: cleaningOrder,
                    onTap: () {
                      final orderId = cleaningOrder.id;
                      if (orderId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تعذر تحديد الطلب الحالي، حاول مرة أخرى',
                            ),
                          ),
                        );
                        return;
                      }
                      context.pushRoute(
                        '/cleaning-order-details',
                        arguments: CleaningOrderDetailsArgs(orderId: orderId),
                      );
                    },
                    onRescheduleTap: () {
                      final orderId = cleaningOrder.id;
                      if (orderId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تعذر تحديد الطلب الحالي، حاول مرة أخرى',
                            ),
                          ),
                        );
                        return;
                      }
                      context
                          .pushRoute(
                            '/cleaning-order-reschedule',
                            arguments: CleaningOrderRescheduleArgs(
                              order: cleaningOrder,
                            ),
                          )
                          ?.then((result) {
                            if (result == true && context.mounted) {
                              context.read<OrdersBloc>().add(
                                FetchOrdersEvent(isReload: true),
                              );
                            }
                          });
                    },
                    onReportIssueTap: () {
                      context.pushRoute(
                        '/cleaning-order-problem',
                        arguments: CleaningOrderProblemReportArgs(
                          order: cleaningOrder,
                        ),
                      );
                    },
                    onCancelTap: () {
                      final orderId = cleaningOrder.id;
                      if (orderId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تعذر تحديد الطلب الحالي، حاول مرة أخرى',
                            ),
                          ),
                        );
                        return;
                      }
                      showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => CleaningCancelReasonDialog(
                          orderId: orderId,
                          bloc: context.read<OrdersBloc>(),
                        ),
                      );
                    },
                  );
                },
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
          itemCount: listLength + (state.isLoadingMore ? 1 : 0),
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
