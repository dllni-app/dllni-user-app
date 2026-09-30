import 'dart:async';
import 'dart:ui' as ui;

import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/cart/cart_products_count_cubit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../../delivery/data/models/delivery_order_models.dart';
import '../../../delivery/domain/usecases/fetch_delivery_order_details_use_case.dart';
import '../../data/models/orders_api_models.dart';
import '../../domain/repository/orders_repo.dart';
import '../../domain/usecases/fetch_order_details_use_case.dart';
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
  late OrderResourceModel _order;
  RestaurantOrderTrackingDataModel? _tracking;
  DeliveryOrderModel? _deliveryOrder;
  bool _loading = true;
  bool _actionLoading = false;
  String? _error;
  Timer? _pollTimer;
  StreamSubscription<RemoteMessage>? _fcmSubscription;
  static const _pollInterval = Duration(seconds: 15);

  bool get _isTerminal {
    if (_deliveryOrder != null) return _deliveryOrder!.isTerminal;
    final status = (_tracking?.latestToStatus ?? _order.status ?? '')
        .toLowerCase();
    return status.contains('delivered') ||
        status.contains('completed') ||
        status.contains('cancelled') ||
        status.contains('rejected');
  }

  bool _isRelevantMessage(RemoteMessage message) {
    final orderId = _order.id?.toString();
    final deliveryOrderId = _order.deliveryOrderId?.toString();
    final serialized = <String>[
      ...message.data.entries.map((entry) => '${entry.key}:${entry.value}'),
      message.notification?.title ?? '',
      message.notification?.body ?? '',
    ].join(' ').toLowerCase();

    if (orderId != null && serialized.contains(orderId)) {
      return true;
    }
    if (deliveryOrderId != null && serialized.contains(deliveryOrderId)) {
      return true;
    }
    return serialized.contains('order') ||
        serialized.contains('delivery') ||
        serialized.contains('restaurant') ||
        serialized.contains('supermarket') ||
        serialized.contains('طلب') ||
        serialized.contains('توصيل');
  }

  @override
  void initState() {
    super.initState();
    _order = widget.args.order;
    _fetchTracking();
    _fcmSubscription = FirebaseMessaging.onMessage.listen((message) {
      if (!mounted || !_isRelevantMessage(message)) return;
      _fetchTracking(silent: true);
    });
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
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
    final id = _order.id;
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

    final deliveryOrderId = _order.deliveryOrderId;
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
        if (!silent) {
          setState(() {
            _error = f.message;
            _loading = false;
          });
        }
      },
      (FetchRestaurantOrderTrackingModel r) {
        setState(() {
          _tracking = r.data;
          _loading = false;
          _error = null;
        });
        _syncPollTimer();
      },
    );
  }

  Future<void> _refreshOrderAndTracking() async {
    final orderId = _order.id;
    if (orderId == null) return;

    final result = await getIt<FetchOrderDetailsUseCase>()(
      FetchOrderDetailsParams(
        section: widget.args.section,
        orderId: orderId,
      ),
    );
    if (!mounted) return;

    result.fold(
      (_) {},
      (response) {
        final refreshed = response.data;
        if (refreshed != null) {
          setState(() {
            _order = refreshed;
          });
        }
      },
    );
    await _fetchTracking(silent: true);
  }

  Future<void> _runOrderAction(
    Future<Either<Failure, bool>> Function() action, {
    required String successMessage,
    bool refreshCart = false,
  }) async {
    if (_actionLoading) return;
    setState(() {
      _actionLoading = true;
    });

    final result = await action();
    if (!mounted) return;

    Failure? failure;
    result.fold((value) => failure = value, (_) {});
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure!.message)),
      );
      setState(() {
        _actionLoading = false;
      });
      return;
    }

    if (refreshCart) {
      getIt<CartProductsCountCubit>().refreshAfterAdd();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage)),
    );
    await _refreshOrderAndTracking();
    if (!mounted) return;
    setState(() {
      _actionLoading = false;
    });
  }

  Future<void> _cancelOrder() async {
    final orderId = _order.id;
    if (orderId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل تريد إلغاء هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('إلغاء الطلب'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _runOrderAction(
      () => getIt<OrdersRepo>().cancelMerchantOrder(
        section: widget.args.section,
        orderId: orderId,
      ),
      successMessage: 'تم إلغاء الطلب.',
    );
  }

  Future<void> _reorderOrder() async {
    final orderId = _order.id;
    if (orderId == null) return;
    await _runOrderAction(
      () => getIt<OrdersRepo>().reorderMerchantOrder(
        section: widget.args.section,
        orderId: orderId,
      ),
      successMessage: 'تمت إضافة منتجات الطلب إلى السلة.',
      refreshCart: true,
    );
  }

  Future<void> _rescheduleOrder() async {
    final orderId = _order.id;
    if (orderId == null) return;

    final now = DateTime.now();
    final initial = DateTime.tryParse(_order.fulfillment?.scheduledAt ?? '');
    final date = await showDatePicker(
      context: context,
      initialDate: initial != null && initial.isAfter(now)
          ? initial
          : now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: initial != null
          ? TimeOfDay.fromDateTime(initial)
          : TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null || !mounted) return;

    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!scheduledAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار موعد مستقبلي.')),
      );
      return;
    }

    await _runOrderAction(
      () => getIt<OrdersRepo>().rescheduleMerchantOrder(
        section: widget.args.section,
        orderId: orderId,
        scheduledAt: scheduledAt.toIso8601String(),
      ),
      successMessage: 'تم تحديث موعد الطلب.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _fetchTracking(),
            child: RestaurantOrderTrackingView(
              order: _order,
              section: widget.args.section,
              tracking: _tracking,
              deliveryOrder: _deliveryOrder,
              isLoading: _loading,
              isActionLoading: _actionLoading,
              loadError: _error,
              onRetry: () => _fetchTracking(),
              onCancel: _cancelOrder,
              onReorder: _reorderOrder,
              onReschedule: _rescheduleOrder,
            ),
          ),
        ),
      ),
    );
  }
}
