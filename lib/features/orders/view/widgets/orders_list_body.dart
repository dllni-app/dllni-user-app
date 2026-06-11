import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../sm_orders/view/screens/sm_order_details_screen.dart';
import '../../../sm_orders/view/widgets/order_card.dart';
import '../../data/models/cleaning_booking_status.dart';
import '../../data/models/cleaning_orders_api_models.dart';
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
    this.showCompletedCleaningOrders = false,
  });

  final OrdersState state;
  final ScrollController scrollController;
  final bool showCompletedCleaningOrders;

  bool _isPreviousCleaningOrder(String? status) {
    final normalizedStatus = (status ?? '').toLowerCase();
    return normalizedStatus == CleaningBookingStatus.completed ||
        normalizedStatus == CleaningBookingStatus.cancelled;
  }

  @override
  Widget build(BuildContext context) {
    final isStoresSection = state.selectedTabIndex == 0;
    final isCleaningSection = state.selectedTabIndex == 2;
    final cleaningOrders = state.cleaningOrders.list
        .where((order) {
          final isPreviousOrder = _isPreviousCleaningOrder(order.status);
          return showCompletedCleaningOrders
              ? isPreviousOrder
              : !isPreviousOrder;
        })
        .toList(growable: false);
    final orders = state.orders.list;
    final pagination = isCleaningSection ? state.cleaningOrders : state.orders;
    final listLength = isCleaningSection
        ? cleaningOrders.length
        : orders.length;
    if (pagination.status == BlocStatus.loading && listLength == 0) {
      return const Center(child: CircularProgressIndicator());
    }
    if (pagination.status == BlocStatus.failed && listLength == 0) {
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
    if (listLength == 0 && pagination.isEndPage) {
      return ListView(
        children: [
          SizedBox(height: context.height * .2),
          const Center(child: Text('لا توجد طلبات حالياً')),
        ],
      );
    }
    final itemCount = pagination.isEndPage ? listLength : listLength + 1;
    return Stack(
      children: [
        ListView.separated(
          controller: scrollController,
          padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
          itemBuilder: (context, index) {
            if (index >= listLength) {
              if (index == listLength &&
                  pagination.status != BlocStatus.loading) {
                context.read<OrdersBloc>().add(
                  FetchOrdersEvent(loadMore: true),
                );
              }
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (isCleaningSection) {
              final cleaningOrder = cleaningOrders[index];
              final orderId = cleaningOrder.id;
              if (orderId == null) {
                return const SizedBox.shrink();
              }
              return _CleaningOrderListItem(
                key: ValueKey<int>(orderId),
                orderId: orderId,
              );
            }
            final order = orders[index];
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
          itemCount: itemCount,
        ),
        if (pagination.status == BlocStatus.loading && listLength > 0)
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

bool _blocksCleaningListCancel(String? status) {
  final normalized = (status ?? '').toLowerCase();
  return normalized == CleaningBookingStatus.awaitingStartVerification ||
      normalized == CleaningBookingStatus.awaitingWorkerStartConfirmation ||
      normalized == CleaningBookingStatus.awaitingCustomerCompletion;
}

bool _blocksCleaningListReschedule(String? status) {
  final normalized = (status ?? '').toLowerCase();
  return normalized == CleaningBookingStatus.awaitingStartVerification ||
      normalized == CleaningBookingStatus.awaitingWorkerStartConfirmation ||
      normalized == CleaningBookingStatus.awaitingCustomerCompletion ||
      normalized == CleaningBookingStatus.inProgress ||
      normalized == CleaningBookingStatus.timeExtensionRequested;
}

class _CleaningOrderListItem extends StatelessWidget {
  const _CleaningOrderListItem({super.key, required this.orderId});

  final int orderId;

  CleaningOrderModel? _findOrder(OrdersState state) {
    for (final order in state.cleaningOrders.list) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OrdersBloc, OrdersState, CleaningOrderModel?>(
      selector: _findOrder,
      builder: (context, cleaningOrder) {
        if (cleaningOrder == null) {
          return const SizedBox.shrink();
        }
        return CleaningOrderCard(
          order: cleaningOrder,
          onTap: () {
            context.pushRoute(
              '/cleaning-order-details',
              arguments: CleaningOrderDetailsArgs(orderId: orderId),
            );
          },
          onRescheduleTap: () {
            if (_blocksCleaningListReschedule(cleaningOrder.status)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('لا يمكن تغيير موعد الخدمة في هذه المرحلة'),
                ),
              );
              return;
            }
            context
                .pushRoute(
                  '/cleaning-order-reschedule',
                  arguments: CleaningOrderRescheduleArgs(order: cleaningOrder),
                )
                ?.then((result) {
                  if (!context.mounted) return;
                  if (result == true ||
                      result is CleaningOrderRescheduleResult) {
                    context.read<OrdersBloc>().add(
                      FetchOrdersEvent(isReload: true),
                    );
                  }
                });
          },
          onReportIssueTap: () {
            context.pushRoute(
              '/cleaning-order-problem',
              arguments: CleaningOrderProblemReportArgs(order: cleaningOrder),
            );
          },
          onCancelTap: () {
            if (_blocksCleaningListCancel(cleaningOrder.status)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'أكمل خطوة التحقق أو تأكيد الإكمال قبل الإلغاء',
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
                scheduledDate: cleaningOrder.scheduledDate,
                scheduledTime: cleaningOrder.scheduledTime,
              ),
            );
          },
        );
      },
    );
  }
}
