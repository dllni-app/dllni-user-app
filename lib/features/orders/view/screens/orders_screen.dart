import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../widgets/order_card.dart';
import '../widgets/orders_app_bar.dart';

enum OrdersFilter { all, stores, restaurants, cleaning }

class _OrderUiModel {
  const _OrderUiModel({
    required this.statusLabel,
    required this.orderNumber,
    required this.serviceName,
    required this.priceLabel,
    required this.dateLabel,
    required this.actionLabel,
    required this.actionType,
    required this.filter,
  });

  final String statusLabel;
  final String orderNumber;
  final String serviceName;
  final String priceLabel;
  final String dateLabel;
  final String actionLabel;
  final OrderCardActionType actionType;
  final OrdersFilter filter;
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrdersFilter _selectedFilter = OrdersFilter.cleaning;

  final List<_OrderUiModel> _orders = const [
    _OrderUiModel(
      statusLabel: 'مكتمل',
      orderNumber: '#1234_232',
      serviceName: 'خدمة تنظيف منزل',
      priceLabel: '120,000 س.س',
      dateLabel: '2026.04.03',
      actionLabel: 'إبلاغ عن مشكلة',
      actionType: OrderCardActionType.neutral,
      filter: OrdersFilter.cleaning,
    ),
    _OrderUiModel(
      statusLabel: 'مراجعة الاسترداد',
      orderNumber: '#1234_232',
      serviceName: 'خدمة تنظيف منزل',
      priceLabel: '120,000 س.س',
      dateLabel: '2026.04.03',
      actionLabel: 'إلغاء الطلب',
      actionType: OrderCardActionType.destructive,
      filter: OrdersFilter.cleaning,
    ),
    _OrderUiModel(
      statusLabel: 'مكتمل',
      orderNumber: '#1234_232',
      serviceName: 'خدمة تنظيف منزل',
      priceLabel: '120,000 س.س',
      dateLabel: '2026.04.03',
      actionLabel: 'إبلاغ عن مشكلة',
      actionType: OrderCardActionType.neutral,
      filter: OrdersFilter.cleaning,
    ),
  ];

  List<_OrderUiModel> get _filteredOrders {
    if (_selectedFilter == OrdersFilter.all) {
      return _orders;
    }
    return _orders.where((order) => order.filter == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filters = <(OrdersFilter, String)>[
      (OrdersFilter.all, 'الكل'),
      (OrdersFilter.stores, 'المتاجر'),
      (OrdersFilter.restaurants, 'المطاعم'),
      (OrdersFilter.cleaning, 'التنظيفات'),
    ];

    return Column(
      children: [
        OrdersAppBar(),
        SizedBox(height: 14,),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
            itemBuilder: (context, index) {
              final order = _filteredOrders[index];
              return OrderCard(
                statusLabel: order.statusLabel,
                orderNumber: order.orderNumber,
                serviceName: order.serviceName,
                priceLabel: order.priceLabel,
                dateLabel: order.dateLabel,
                actionLabel: order.actionLabel,
                actionType: order.actionType,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemCount: _filteredOrders.length,
          )
        ),
      ],
    );
  }
}
