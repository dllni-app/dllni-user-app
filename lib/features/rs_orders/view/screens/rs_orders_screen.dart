import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/bloc/rs_orders_bloc.dart';
import 'rs_order_edit_screen.dart';

class RsOrdersScreen extends StatelessWidget {
  const RsOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RsOrdersBloc>(
      lazy: false,
      create: (_) => getIt<RsOrdersBloc>()..add(RsOrdersLoadRequested()),
      child: Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        body: SafeArea(
          child: BlocBuilder<RsOrdersBloc, RsOrdersState>(
            builder: (context, state) {
              if (state.ordersStatus == BlocStatus.loading || state.ordersStatus == BlocStatus.init) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  const _OrdersHeader(),
                  const SizedBox(height: 18),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (state.orders.isNotEmpty)
                            ...state.orders.map(
                              (order) => InkWell(
                                onTap: () {
                                  if (order.id != null) {
                                    context.read<RsOrdersBloc>().add(RsOrderSelected(orderId: order.id!));
                                  }
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<RsOrdersBloc>(),
                                        child: const RsOrderEditScreen(),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: context.onPrimary,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: const Color(0xffE5E7EB)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppText.titleLarge(order.orderNumber ?? 'Order'),
                                      const SizedBox(height: 6),
                                      AppText.labelLarge('الحالة: ${order.statusLabelAr ?? order.status ?? '-'}'),
                                      AppText.labelLarge('المطعم: ${order.restaurant?.name ?? '-'}'),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            const _OrdersEmptyState(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: context.width,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: context.primaryContainer, width: 2)),
      ),
      child: Row(
        children: [AppText.headlineMedium('طلباتي', color: context.primary, fontWeight: FontWeight.bold, textAlign: TextAlign.start)],
      ),
    );
  }
}

class _OrdersEmptyState extends StatelessWidget {
  const _OrdersEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: const Color(0xff9CA3AF),
            size: 42,
          ),
          const SizedBox(height: 10),
          AppText.titleMedium(
            'لا توجد طلبات حالياً',
            color: const Color(0xff374151),
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 4),
          AppText.bodyMedium(
            'عند توفر طلباتك ستظهر هنا مباشرة من الخادم',
            color: const Color(0xff6B7280),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
