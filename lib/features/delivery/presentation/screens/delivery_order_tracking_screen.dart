import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/delivery/presentation/cubit/delivery_tracking_cubit.dart';
import 'package:dllni_user_app/features/profile/view/widgets/personal_details_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/delivery_order_models.dart';
import '../widgets/delivery_driver_card.dart';
import '../widgets/delivery_status_stepper.dart';
import '../widgets/delivery_tracking_map.dart';

class DeliveryOrderTrackingArgs {
  DeliveryOrderTrackingArgs({required this.orderId});

  final int orderId;
}

@AutoRoutePage(path: '/delivery/orders/tracking')
class DeliveryOrderTrackingScreen extends StatefulWidget {
  const DeliveryOrderTrackingScreen({super.key, required this.args});

  final DeliveryOrderTrackingArgs args;

  @override
  State<DeliveryOrderTrackingScreen> createState() =>
      _DeliveryOrderTrackingScreenState();
}

class _DeliveryOrderTrackingScreenState
    extends State<DeliveryOrderTrackingScreen> {
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 15);

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _syncPollTimer(DeliveryTrackingCubit cubit, bool isTerminal) {
    if (!isTerminal) {
      _pollTimer ??= Timer.periodic(_pollInterval, (_) {
        cubit.load(widget.args.orderId, silent: true);
      });
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<DeliveryTrackingCubit>()..load(widget.args.orderId),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xffF3F4F6),
          body: SafeArea(
            child: BlocConsumer<DeliveryTrackingCubit, DeliveryTrackingState>(
              listener: (context, state) {
                _syncPollTimer(
                  context.read<DeliveryTrackingCubit>(),
                  state.order?.isTerminal ?? false,
                );
              },
              builder: (context, state) {
                if (state.loading && state.order == null) {
                  return const Column(
                    children: [
                      PersonalDetailsAppBar(title: 'تتبع التوصيل'),
                      Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                if (state.error != null && state.order == null) {
                  return Column(
                    children: [
                      const PersonalDetailsAppBar(title: 'تتبع التوصيل'),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(state.error!),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () => context
                                    .read<DeliveryTrackingCubit>()
                                    .load(widget.args.orderId),
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final order = state.order;
                if (order == null) {
                  return const Column(
                    children: [
                      PersonalDetailsAppBar(title: 'تتبع التوصيل'),
                      Expanded(child: Center(child: Text('لا توجد بيانات'))),
                    ],
                  );
                }

                final tracking = order.tracking;
                final stages = tracking?.stages.isNotEmpty == true
                    ? tracking!.stages
                    : tracking?.timeline ?? order.timeline;
                final driver = tracking?.driver ?? order.driver;
                final map = tracking?.map;

                return Column(
                  children: [
                    PersonalDetailsAppBar(title: 'تتبع التوصيل'),
                    if (state.error != null)
                      Material(
                        color: const Color(0xffFEF2F2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: Color(0xff991B1B)),
                          ),
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => context
                            .read<DeliveryTrackingCubit>()
                            .load(widget.args.orderId),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          children: [
                            _StatusHeader(
                              orderNumber: order.orderNumber ?? '—',
                              statusLabel: order.displayStatusLabel,
                              etaLabel: order.etaLabel,
                            ),
                            if (map != null && map.enabled) ...[
                              const SizedBox(height: 14),
                              DeliveryTrackingMap(map: map),
                            ],
                            const SizedBox(height: 14),
                            DeliveryStatusStepper(stages: stages),
                            if (driver != null) ...[
                              const SizedBox(height: 14),
                              DeliveryDriverCard(driver: driver),
                            ],
                            if (tracking?.pickup != null ||
                                tracking?.dropoff != null) ...[
                              const SizedBox(height: 14),
                              _AddressCard(
                                pickup: tracking?.pickup?.address ??
                                    order.pickupAddress,
                                dropoff: tracking?.dropoff?.address ??
                                    order.dropoffAddress,
                              ),
                            ],
                            if (order.events.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              _EventsCard(events: order.events),
                            ],
                            if (order.deliveryFee != null) ...[
                              const SizedBox(height: 14),
                              _FeeCard(
                                fee: order.deliveryFee!,
                                currency: order.currency ?? 'SYP',
                                distanceKm: order.distanceKm,
                              ),
                            ],
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
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({
    required this.orderNumber,
    required this.statusLabel,
    required this.etaLabel,
  });

  final String orderNumber;
  final String statusLabel;
  final String etaLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            orderNumber,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xff6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusLabel,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xff1E2A78),
            ),
          ),
          if (etaLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              etaLabel,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xff374151),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({this.pickup, this.dropoff});

  final String? pickup;
  final String? dropoff;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (pickup != null) ...[
            const Row(
              children: [
                Icon(Icons.store_rounded, size: 18, color: Color(0xffF59E0B)),
                SizedBox(width: 8),
                Text('نقطة الاستلام', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Text(pickup!, style: const TextStyle(color: Color(0xff4B5563))),
            const SizedBox(height: 12),
          ],
          if (dropoff != null) ...[
            const Row(
              children: [
                Icon(Icons.home_rounded, size: 18, color: Color(0xff1E2A78)),
                SizedBox(width: 8),
                Text('نقطة التسليم', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Text(dropoff!, style: const TextStyle(color: Color(0xff4B5563))),
          ],
        ],
      ),
    );
  }
}

class _EventsCard extends StatelessWidget {
  const _EventsCard({required this.events});

  final List<DeliveryEventModel> events;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'سجل التحديثات',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      children: events.map((event) {
        return ListTile(
          dense: true,
          title: Text('${event.fromStatus ?? '—'} ← ${event.toStatus ?? '—'}'),
          subtitle: event.createdAt != null ? Text(event.createdAt!) : null,
        );
      }).toList(),
    );
  }
}

class _FeeCard extends StatelessWidget {
  const _FeeCard({
    required this.fee,
    required this.currency,
    this.distanceKm,
  });

  final double fee;
  final String currency;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('رسوم التوصيل'),
                Text(
                  '${fee.toStringAsFixed(0)} $currency',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (distanceKm != null)
            Text(
              '${distanceKm!.toStringAsFixed(1)} كم',
              style: const TextStyle(color: Color(0xff6B7280)),
            ),
        ],
      ),
    );
  }
}
