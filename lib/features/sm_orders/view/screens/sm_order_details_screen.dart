import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/delivery/data/models/delivery_order_models.dart';
import 'package:dllni_user_app/features/delivery/domain/usecases/fetch_delivery_order_details_use_case.dart';
import 'package:dllni_user_app/features/delivery/presentation/widgets/delivery_driver_card.dart';
import 'package:dllni_user_app/features/delivery/presentation/widgets/delivery_status_stepper.dart';
import 'package:dllni_user_app/features/delivery/presentation/widgets/delivery_tracking_map.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_app_bars.dart';
import '../../../orders/domain/usecases/fetch_restaurant_order_tracking_use_case.dart';
import '../../../orders/domain/usecases/fetch_store_order_tracking_use_case.dart';
import '../../../orders/data/models/orders_api_models.dart';
import '../widgets/order_content.dart';
import '../widgets/order_details_status_card.dart';
import '../widgets/order_info_card.dart';
import '../widgets/order_tracking_status_card.dart';
import '../widgets/summary_request.dart';

@AutoRoutePage(path: "/order_details")
class SmOrderDetailsScreen extends StatefulWidget {
  const SmOrderDetailsScreen({super.key, required this.args});

  final SmOrderDetailsScreenArgs args;

  @override
  State<SmOrderDetailsScreen> createState() => _SmOrderDetailsScreenState();
}

class SmOrderDetailsScreenArgs {
  const SmOrderDetailsScreenArgs({required this.order});

  final OrderResourceModel order;
}

class _SmOrderDetailsScreenState extends State<SmOrderDetailsScreen> {
  RestaurantOrderTrackingDataModel? _tracking;
  DeliveryOrderModel? _deliveryOrder;
  bool _isLoading = true;
  String? _loadError;
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _fetchTracking();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  bool get _isTerminal {
    if (_deliveryOrder != null) return _deliveryOrder!.isTerminal;
    final status = (_tracking?.latestToStatus ?? widget.args.order.status ?? '')
        .toLowerCase();
    return status.contains('delivered') ||
        status.contains('completed') ||
        status.contains('cancelled');
  }

  void _syncPollTimer() {
    if (!_isTerminal) {
      _pollTimer ??= Timer.periodic(_pollInterval, (_) {
        _fetchTracking(silent: true);
      });
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  Future<void> _fetchTracking({bool silent = false}) async {
    final orderId = widget.args.order.id;
    if (orderId == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'معرف الطلب غير متوفر';
      });
      return;
    }
    if (!silent) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    final deliveryOrderId = widget.args.order.deliveryOrderId;
    if (deliveryOrderId != null) {
      final deliveryResult = await getIt<FetchDeliveryOrderDetailsUseCase>()(
        FetchDeliveryOrderDetailsParams(orderId: deliveryOrderId),
      );
      if (!mounted) return;
      deliveryResult.fold(
        (failure) {
          if (!silent) {
            setState(() {
              _isLoading = false;
              _loadError = failure.message;
            });
          }
        },
        (result) {
          setState(() {
            _deliveryOrder = result.data;
            _isLoading = false;
          });
          _syncPollTimer();
        },
      );
      return;
    }

    final Either<Failure, FetchRestaurantOrderTrackingModel> response =
        await getIt<FetchStoreOrderTrackingUseCase>()(
          FetchRestaurantOrderTrackingParams(orderId: orderId),
        );
    if (!mounted) return;
    response.fold(
      (failure) => setState(() {
        _isLoading = false;
        _loadError = failure.message;
      }),
      (result) {
        setState(() {
          _tracking = result.data;
          _isLoading = false;
        });
        _syncPollTimer();
      },
    );
  }

  int _statusStep() {
    final order = widget.args.order;
    final hasDelivery =
        (order.fulfillment?.type ?? '').toLowerCase() == 'delivery';
    final status = (_tracking?.latestToStatus ?? order.status ?? '')
        .toLowerCase();
    if (status.contains('delivered') || status.contains('completed')) {
      return hasDelivery ? 4 : 3;
    }
    if (status.contains('out_for_delivery') || status.contains('dispatch')) {
      return hasDelivery ? 3 : 2;
    }
    if (status.contains('preparing') || status.contains('ready')) return 2;
    if (status.isNotEmpty) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.args.order;
    final hasDelivery =
        (order.fulfillment?.type ?? '').toLowerCase() == 'delivery';
    final deliveryTracking = _deliveryOrder?.tracking;
    final deliveryStages = deliveryTracking?.stages.isNotEmpty == true
        ? deliveryTracking!.stages
        : deliveryTracking?.timeline ?? _deliveryOrder?.timeline ?? const [];
    final deliveryDriver = deliveryTracking?.driver ?? _deliveryOrder?.driver;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        body: Column(
          children: [
            AppSimpleAppBar2(
              title: 'تفاصيل الطلب',
              arrowBackType: ArrowBackType.cupertino,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchTracking,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          12,
                          16,
                          24,
                        ),
                        children: [
                          if (_loadError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: const Color(0xffFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _loadError!,
                                          style: const TextStyle(
                                            color: Color(0xff991B1B),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _fetchTracking,
                                        child: const Text('إعادة المحاولة'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          OrderStatus(order: order),
                          const SizedBox(height: 12),
                          if (deliveryStages.isNotEmpty)
                            DeliveryStatusStepper(stages: deliveryStages)
                          else
                            OrderTrackingStatusCard(
                              hasDelivery: hasDelivery,
                              step: _statusStep(),
                            ),
                          if (deliveryTracking?.map != null &&
                              deliveryTracking!.map!.enabled) ...[
                            const SizedBox(height: 12),
                            DeliveryTrackingMap(map: deliveryTracking.map!),
                          ],
                          if (deliveryDriver != null) ...[
                            const SizedBox(height: 12),
                            DeliveryDriverCard(driver: deliveryDriver),
                          ],
                          const SizedBox(height: 12),
                          OrderInfoCard(order: order),
                          const SizedBox(height: 12),
                          OrderContent(items: order.items),
                          const SizedBox(height: 12),
                          SummaryRequest(order: order),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
