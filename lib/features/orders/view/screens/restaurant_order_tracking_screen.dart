import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';

import '../../../delivery/data/models/delivery_order_models.dart';
import '../../../delivery/domain/usecases/fetch_delivery_order_details_use_case.dart';
import '../../data/models/orders_api_models.dart';
import '../../domain/usecases/fetch_restaurant_order_tracking_use_case.dart';
import '../../domain/usecases/fetch_store_order_tracking_use_case.dart';
import '../widgets/restaurant_order_tracking_view.dart';

class RestaurantOrderTrackingArgs {
  RestaurantOrderTrackingArgs({
    required this.order,
    this.section = 'restaurant',
  });

  final OrderResourceModel order;
  final String section;
}

@AutoRoutePage(path: '/restaurant-order-tracking')
class RestaurantOrderTrackingScreen extends StatefulWidget {
  const RestaurantOrderTrackingScreen({super.key, required this.args});

  final RestaurantOrderTrackingArgs args;

  @override
  State<RestaurantOrderTrackingScreen> createState() =>
      _RestaurantOrderTrackingScreenState();
}

class _RestaurantOrderTrackingScreenState
    extends State<RestaurantOrderTrackingScreen> {
  RestaurantOrderTrackingDataModel? _tracking;
  DeliveryOrderModel? _deliveryOrder;
  bool _loading = true;
  String? _error;
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 15);

  bool get _isTerminal {
    if (_deliveryOrder != null) return _deliveryOrder!.isTerminal;
    final status = (_tracking?.latestToStatus ?? widget.args.order.status ?? '')
        .toLowerCase();
    return status.contains('delivered') ||
        status.contains('completed') ||
        status.contains('cancelled');
  }

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
    final id = widget.args.order.id;
    if (id == null) {
      setState(() {
        _error = 'معرّف الطلب غير متوفر';
        _loading = false;
      });
      return;
    }

    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    final deliveryOrderId = widget.args.order.deliveryOrderId;
    if (deliveryOrderId != null) {
      final deliveryResult = await getIt<FetchDeliveryOrderDetailsUseCase>()(
        FetchDeliveryOrderDetailsParams(orderId: deliveryOrderId),
      );
      if (!mounted) return;
      deliveryResult.fold(
        (Failure f) {
          if (!silent) {
            setState(() {
              _error = f.message;
              _loading = false;
            });
          }
        },
        (FetchDeliveryOrderDetailsModel r) {
          setState(() {
            _deliveryOrder = r.data;
            _loading = false;
            _error = null;
          });
          _syncPollTimer();
        },
      );
      return;
    }

    final Either<Failure, FetchRestaurantOrderTrackingModel> result =
        widget.args.section == 'supermarket'
            ? await getIt<FetchStoreOrderTrackingUseCase>()(
                FetchRestaurantOrderTrackingParams(orderId: id),
              )
            : await getIt<FetchRestaurantOrderTrackingUseCase>()(
                FetchRestaurantOrderTrackingParams(orderId: id),
              );

    if (!mounted) return;

    result.fold(
      (Failure f) {
        setState(() {
          _error = f.message;
          _loading = false;
        });
      },
      (FetchRestaurantOrderTrackingModel r) {
        setState(() {
          _tracking = r.data;
          _loading = false;
        });
        _syncPollTimer();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _fetchTracking(),
            child:  RestaurantOrderTrackingView(
              order: widget.args.order,
              tracking: _tracking,
              deliveryOrder: _deliveryOrder,
              isLoading: _loading,
              loadError: _error,
              onRetry: () => _fetchTracking(),
            ),
          ),
        ),
      ),
    );
  }
}
