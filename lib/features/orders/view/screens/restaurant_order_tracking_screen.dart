import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/fetch_restaurant_order_tracking_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/fetch_store_order_tracking_use_case.dart';
import 'package:flutter/material.dart';

import '../../data/models/orders_api_models.dart';
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
  State<RestaurantOrderTrackingScreen> createState() => _RestaurantOrderTrackingScreenState();
}

class _RestaurantOrderTrackingScreenState extends State<RestaurantOrderTrackingScreen> {
  RestaurantOrderTrackingDataModel? _tracking;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTracking();
  }

  Future<void> _fetchTracking() async {
    final id = widget.args.order.id;
    if (id == null) {
      setState(() {
        _error = 'معرّف الطلب غير متوفر';
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

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
          child: RestaurantOrderTrackingView(
            order: widget.args.order,
            tracking: _tracking,
            isLoading: _loading,
            loadError: _error,
            onRetry: _fetchTracking,
          ),
        ),
      ),
    );
  }
}
