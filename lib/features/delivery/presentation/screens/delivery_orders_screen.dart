import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/delivery/presentation/cubit/delivery_orders_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/delivery_order_models.dart';
import 'delivery_order_tracking_screen.dart';

@AutoRoutePage(path: '/delivery/orders')
class DeliveryOrdersScreen extends StatefulWidget {
  const DeliveryOrdersScreen({super.key});

  @override
  State<DeliveryOrdersScreen> createState() => _DeliveryOrdersScreenState();
}

class _DeliveryOrdersScreenState extends State<DeliveryOrdersScreen> {
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 20);

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _syncPollTimer(DeliveryOrdersCubit cubit) {
    if (cubit.hasActiveOrders) {
      _pollTimer ??= Timer.periodic(_pollInterval, (_) {
        cubit.load(reload: true);
      });
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeliveryOrdersCubit>()..load(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xffF3F4F6),
          appBar: AppBar(
            title: const Text('طلبات التوصيل'),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xff1F2937),
            elevation: 0,
          ),
          body: BlocConsumer<DeliveryOrdersCubit, DeliveryOrdersState>(
            listener: (context, state) {
              _syncPollTimer(context.read<DeliveryOrdersCubit>());
            },
            builder: (context, state) {
              if (state.loading && state.orders.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null && state.orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.error!),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () =>
                            context.read<DeliveryOrdersCubit>().load(reload: true),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    context.read<DeliveryOrdersCubit>().load(reload: true),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: state.orders.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.orders.length) {
                      if (state.loadingMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      context.read<DeliveryOrdersCubit>().loadMore();
                      return const SizedBox.shrink();
                    }

                    final order = state.orders[index];
                    return _DeliveryOrderListTile(order: order);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DeliveryOrderListTile extends StatelessWidget {
  const _DeliveryOrderListTile({required this.order});

  final DeliveryOrderModel order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          final id = order.id;
          if (id == null) return;
          context.pushRoute(
            '/delivery/orders/tracking',
            arguments: DeliveryOrderTrackingArgs(orderId: id),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber ?? '—',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xffEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.displayStatusLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff1E2A78),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (order.etaLabel.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  order.etaLabel,
                  style: const TextStyle(color: Color(0xff6B7280), fontSize: 13),
                ),
              ],
              if (order.driver != null) ...[
                const SizedBox(height: 8),
                Text(
                  'المندوب: ${order.driver!.name}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
              if (order.dropoffAddress != null) ...[
                const SizedBox(height: 4),
                Text(
                  order.dropoffAddress!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff9CA3AF),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
