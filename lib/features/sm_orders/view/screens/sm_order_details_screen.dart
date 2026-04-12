import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/fetch_restaurant_order_tracking_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/fetch_store_order_tracking_use_case.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_app_bars.dart';
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
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _fetchTracking();
  }

  Future<void> _fetchTracking() async {
    final orderId = widget.args.order.id;
    if (orderId == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'معرف الطلب غير متوفر';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
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
      (result) => setState(() {
        _tracking = result.data;
        _isLoading = false;
      }),
    );
  }

  int _statusStep() {
    final status = (_tracking?.latestToStatus ?? widget.args.order.status ?? '')
        .toLowerCase();
    if (status.contains('delivered') || status.contains('completed')) return 4;
    if (status.contains('out_for_delivery') || status.contains('dispatch'))
      return 3;
    if (status.contains('preparing') || status.contains('ready')) return 2;
    if (status.isNotEmpty) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.args.order;
    final hasDelivery =
        (order.fulfillment?.type ?? '').toLowerCase() == 'delivery';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        // appBar: AppBar(
        //   title: const Text('تفاصيل الطلب'),
        //   centerTitle: true,
        // ),
        body: Column(
          children: [
            AppSimpleAppBar2(
              title: 'تفاصيل الطلب',
              arrowBackType: ArrowBackType.cupertino,
            ),
            SizedBox(height: 12),
            Expanded(child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchTracking,
                    child: ListView(
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
                        OrderTrackingStatusCard(
                          hasDelivery: hasDelivery,
                          step: _statusStep(),
                        ),
                        const SizedBox(height: 12),
                        OrderInfoCard(order: order),
                        const SizedBox(height: 12),
                        OrderContent(items: order.items),
                        const SizedBox(height: 12),
                        SummaryRequest(order: order),
                      ],
                    ),
                  ),)
          ],
        ),
      ),
    );
  }
}
