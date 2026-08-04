import 'dart:async';
import 'dart:ui' as ui;

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/delivery/presentation/cubit/delivery_tracking_cubit.dart';
import 'package:dllni_user_app/features/profile/view/widgets/personal_details_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

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

  void _syncPollTimer(DeliveryTrackingCubit cubit, DeliveryOrderModel? order) {
    if (!_isTerminalDeliveryStatus(order)) {
      _pollTimer ??= Timer.periodic(_pollInterval, (_) {
        cubit.load(widget.args.orderId, silent: true);
      });
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  bool _isTerminalDeliveryStatus(DeliveryOrderModel? order) {
    final status = (order?.status ?? order?.tracking?.currentStatus ?? '')
        .toLowerCase();
    return order?.isTerminal == true ||
        status == 'completed' ||
        status == 'stopped' ||
        status == 'cancelled' ||
        status == 'rejected';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<DeliveryTrackingCubit>()..load(widget.args.orderId),
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xffF3F4F6),
          body: SafeArea(
            child: BlocConsumer<DeliveryTrackingCubit, DeliveryTrackingState>(
              listener: (context, state) {
                _syncPollTimer(
                  context.read<DeliveryTrackingCubit>(),
                  state.order,
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
                final status = tracking?.currentStatus ?? order.status;

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
                              status: status,
                              fee: order.deliveryFee,
                              currency: order.currency ?? 'SYP',
                              distanceKm: order.distanceKm,
                            ),
                            const SizedBox(height: 14),
                            map == null
                                ? const _TrackingMapUnavailableCard()
                                : DeliveryTrackingMap(map: map),
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
    required this.status,
    this.fee,
    this.currency,
    this.distanceKm,
  });

  final String orderNumber;
  final String statusLabel;
  final String etaLabel;
  final String? status;
  final double? fee;
  final String? currency;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xffEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _statusIcon(status),
                  color: const Color(0xff1E2A78),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xff6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusLabel,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff1E2A78),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _deliveryStatusHint(status),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff374151),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (etaLabel.isNotEmpty)
                _StatusMetric(icon: Icons.timer_outlined, text: etaLabel),
              if (fee != null)
                _StatusMetric(
                  icon: Icons.payments_outlined,
                  text: '${fee!.toStringAsFixed(0)} ${currency ?? 'SYP'}',
                ),
              if (distanceKm != null)
                _StatusMetric(
                  icon: Icons.route_outlined,
                  text: '${distanceKm!.toStringAsFixed(1)} كم',
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String? status) {
    return switch ((status ?? '').toLowerCase()) {
      'new' => Icons.add_task_rounded,
      'dispatching' => Icons.search_rounded,
      'offered' => Icons.campaign_rounded,
      'accepted' => Icons.two_wheeler_rounded,
      'in_progress' => Icons.near_me_rounded,
      'picked_up' => Icons.inventory_2_rounded,
      'delivered' => Icons.home_rounded,
      'completed' => Icons.check_circle_rounded,
      'cancelled' => Icons.cancel_rounded,
      'rejected' => Icons.error_outline_rounded,
      'stopped' => Icons.pause_circle_rounded,
      _ => Icons.delivery_dining_rounded,
    };
  }

  String _deliveryStatusHint(String? status) {
    return switch ((status ?? '').toLowerCase()) {
      'new' => 'تم إنشاء طلب التوصيل',
      'dispatching' => 'جاري البحث عن مندوب قريب',
      'offered' => 'تم إرسال الطلب إلى مندوب',
      'accepted' => 'المندوب في الطريق إلى نقطة الاستلام',
      'in_progress' => 'المندوب يقترب من نقطة الاستلام',
      'picked_up' => 'المندوب استلم الطلب وهو في الطريق إليك',
      'delivered' => 'تم تسليم الطلب',
      'completed' => 'اكتمل طلب التوصيل',
      'cancelled' => 'تم إلغاء طلب التوصيل',
      'rejected' => 'تعذر قبول طلب التوصيل',
      'stopped' => 'توقف طلب التوصيل',
      _ => 'جاري تحديث حالة التوصيل',
    };
  }
}

class _StatusMetric extends StatelessWidget {
  const _StatusMetric({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xff6B7280)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xff374151)),
          ),
        ],
      ),
    );
  }
}

class _TrackingMapUnavailableCard extends StatelessWidget {
  const _TrackingMapUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: const Row(
        children: [
          Icon(Icons.map_outlined, color: Color(0xff6B7280)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'سيتم عرض موقع المندوب عند توفر بيانات التتبع.',
              style: TextStyle(color: Color(0xff6B7280)),
            ),
          ),
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
        final date = _formatArabicDateTime(event.createdAt);
        return ListTile(
          dense: true,
          title: Text(_deliveryEventLabel(event)),
          subtitle: date.isNotEmpty ? Text(date) : null,
        );
      }).toList(),
    );
  }

  static String _deliveryEventLabel(DeliveryEventModel event) {
    final to = event.toStatus;
    return switch ((to ?? '').toLowerCase()) {
      'accepted' => 'تم قبول الطلب من المندوب',
      'in_progress' => 'المندوب في الطريق لنقطة الاستلام',
      'picked_up' => 'تم استلام الطلب',
      'delivered' => 'تم تسليم الطلب',
      'completed' => 'اكتمل التوصيل',
      'cancelled' => 'تم إلغاء التوصيل',
      'stopped' => 'توقف التوصيل',
      'rejected' => 'تعذر قبول طلب التوصيل',
      _ => _localizedEventNote(event.note),
    };
  }

  static String _localizedEventNote(String? note) {
    final raw = note?.trim() ?? '';
    if (raw.isEmpty) return 'تم تحديث حالة الطلب';

    final normalized = raw.toLowerCase();
    if (normalized.contains('merchant accepted order') &&
        normalized.contains('driver search started')) {
      return 'قبل المتجر الطلب وبدأ البحث عن مندوب';
    }
    if (normalized.contains('offers sent to driver pool')) {
      return 'تم إرسال الطلب إلى مجموعة المندوبين';
    }
    if (normalized.contains('driver accepted')) {
      return 'تم قبول الطلب من المندوب';
    }
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(raw)) {
      return raw;
    }
    return 'تم تحديث حالة الطلب';
  }

  static String _formatArabicDateTime(String? value) {
    if (value == null || value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return DateFormat('yyyy/MM/dd - h:mm a', 'ar').format(parsed.toLocal());
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
