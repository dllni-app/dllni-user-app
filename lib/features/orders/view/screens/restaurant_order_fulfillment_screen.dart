import 'dart:ui' as ui;

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/session/session_expired_handler.dart';
import 'package:dllni_user_app/features/profile/domain/models/address_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../delivery/presentation/screens/delivery_order_tracking_screen.dart';
import '../../../profile/view/widgets/personal_details_app_bar.dart';
import '../../data/models/fetch_supermarket_cart_model.dart';
import '../../data/models/orders_api_models.dart';
import '../../domain/usecases/fetch_supermarket_cart_use_case.dart';
import '../manager/bloc/orders_bloc.dart';
import '../screens/restaurant_order_tracking_screen.dart';
import '../widgets/merchant_checkout_coupon_section.dart';

class RestaurantOrderFulfillmentArgs {
  final OrdersBloc bloc;
  final int? cartId;
  final String section;

  RestaurantOrderFulfillmentArgs({
    required this.bloc,
    required this.cartId,
    required this.section,
  });
}

@AutoRoutePage(path: '/restaurant-order-fulfillment')
class RestaurantOrderFulfillmentScreen extends StatelessWidget {
  const RestaurantOrderFulfillmentScreen({
    super.key,
    required this.args,
  });

  final RestaurantOrderFulfillmentArgs args;

  String _money(double value) => '${value.toStringAsFixed(0)} ل.س';

  RestaurantCartDataModel? _cartForState(OrdersState state) {
    final carts = args.section == 'supermarket'
        ? state.storeCarts
        : state.restaurantCarts;
    for (final cart in carts) {
      if (cart.id == args.cartId) return cart;
    }
    return args.section == 'supermarket'
        ? state.storeCart
        : state.restaurantCart;
  }

  FetchSupermarketCartModelDataItem? _supermarketCartForState(
    OrdersState state,
  ) {
    final selected = state.singleSupermarketCart;
    if (selected?.id == args.cartId) return selected;

    for (final cart in state.supermarketCart?.data ??
        const <FetchSupermarketCartModelDataItem>[]) {
      if (cart.id == args.cartId) return cart;
    }
    return null;
  }

  String _joinLocationParts(Iterable<String?> parts) {
    final uniqueParts = <String>[];
    for (final part in parts) {
      final value = part?.trim() ?? '';
      if (value.isNotEmpty && !uniqueParts.contains(value)) {
        uniqueParts.add(value);
      }
    }
    return uniqueParts.join('، ');
  }

  String _coordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return '';
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  String _merchantLocation({
    required bool isStoreFlow,
    required RestaurantCartDataModel? cart,
    required FetchSupermarketCartModelDataItem? supermarketCart,
  }) {
    if (isStoreFlow) {
      final merchant = supermarketCart?.merchant;
      final store = supermarketCart?.store;
      final address = _joinLocationParts([
        merchant?.address ?? store?.address,
        merchant?.neighborhood ?? store?.neighborhood,
        merchant?.city ?? store?.city,
      ]);
      if (address.isNotEmpty) return address;
      return _coordinates(
        merchant?.latitude ?? store?.latitude,
        merchant?.longitude ?? store?.longitude,
      );
    }

    final merchant = cart?.merchant;
    final address = _joinLocationParts([
      merchant?.address,
      merchant?.locationDetails,
      merchant?.district,
      merchant?.city,
    ]);
    if (address.isNotEmpty) return address;
    return _coordinates(merchant?.latitude, merchant?.longitude);
  }

  void _exitCheckoutFlow(BuildContext context) {
    Navigator.of(context).popUntil((route) {
      final name = route.settings.name;
      return name == '/main' ||
          name == '/smmain' ||
          name == '/rsmain' ||
          name == '/clmain' ||
          route.isFirst;
    });
  }

  BuildContext? _rootContext() =>
      SessionExpiredHandler.navigatorKey?.currentContext;

  void _showOrderSuccessSheet({
    required OrderResourceModel placedOrder,
    int? deliveryOrderId,
  }) {
    final rootContext = _rootContext();
    if (rootContext == null || !rootContext.mounted) return;

    showModalBottomSheet<void>(
      context: rootContext,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 56,
                  color: Color(0xff10B981),
                ),
                const SizedBox(height: 12),
                const Text(
                  'تم إنشاء طلبك بنجاح',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'سيتم تحديث حالة التوصيل تلقائياً ويمكنك متابعة المندوب من شاشة التتبع.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (deliveryOrderId != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        rootContext.pushRoute(
                          '/delivery/orders/tracking',
                          arguments: DeliveryOrderTrackingArgs(
                            orderId: deliveryOrderId,
                          ),
                        );
                      },
                      icon: const Icon(Icons.delivery_dining),
                      label: const Text('تتبع التوصيل'),
                    ),
                  ),
                if (placedOrder.id != null) ...[
                  if (deliveryOrderId != null) const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        rootContext.pushRoute(
                          '/restaurant-order-tracking',
                          arguments: RestaurantOrderTrackingArgs(
                            order: placedOrder,
                            section: args.section,
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('تتبع الطلب'),
                    ),
                  ),
                ],
                TextButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    rootContext.pushRoute('/main', arguments: 1);
                  },
                  child: const Text('العودة للطلبات'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleOrderPlaced(
    BuildContext context, {
    required OrderResourceModel? placedOrder,
  }) {
    final rootContext = _rootContext();
    if (rootContext != null && rootContext.mounted) {
      ScaffoldMessenger.of(rootContext).showSnackBar(
        const SnackBar(content: Text('تم تاكيد الطلب بنجاح')),
      );
    }

    if (args.section == 'supermarket') {
      context.read<OrdersBloc>().add(
        FetchSupermarketCartEvent(
          params: FetchSupermarketCartParams(),
        ),
      );
    }

    context.read<OrdersBloc>().add(FetchOrdersEvent(isReload: true));
    _exitCheckoutFlow(context);

    final order = placedOrder;
    if (order == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOrderSuccessSheet(
        placedOrder: order,
        deliveryOrderId: order.deliveryOrderId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: args.bloc,
      child: Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        body: SafeArea(
          child: BlocConsumer<OrdersBloc, OrdersState>(
            listenWhen: (previous, current) => args.section == 'supermarket'
                ? previous.placeStoreOrderStatus !=
                    current.placeStoreOrderStatus
                : previous.placeOrderStatus != current.placeOrderStatus,
            listener: (context, state) {
              final status = args.section == 'supermarket'
                  ? state.placeStoreOrderStatus
                  : state.placeOrderStatus;
              final errorMessage = args.section == 'supermarket'
                  ? state.placeStoreOrderErrorMessage
                  : state.placeOrderErrorMessage;

              if (status == BlocStatus.success) {
                final placedOrder = args.section == 'supermarket'
                    ? state.placedStoreOrder
                    : state.placedRestaurantOrder;
                _handleOrderPlaced(context, placedOrder: placedOrder);
              } else if (status == BlocStatus.failed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      errorMessage ?? 'تعذر تاكيد الطلب حالياً.',
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              final isStoreFlow = args.section == 'supermarket';
              final cart = _cartForState(state);
              final supermarketCart = isStoreFlow
                  ? _supermarketCartForState(state)
                  : null;
              final isDelivery =
                  (state.selectedFulfillmentType ?? 'delivery') == 'delivery';
              final isPlacingOrder = isStoreFlow
                  ? state.placeStoreOrderStatus == BlocStatus.loading
                  : state.placeOrderStatus == BlocStatus.loading;
              final couponData = isStoreFlow
                  ? state.storeCouponData
                  : state.couponData;
              final baseSubtotal = isStoreFlow
                  ? supermarketCart?.amounts?.subtotal?.toDouble()
                  : cart?.amounts?.subtotal;
              final baseTotal = isStoreFlow
                  ? supermarketCart?.amounts?.total?.toDouble()
                  : cart?.amounts?.total;
              final subtotal =
                  couponData?.amounts?.subtotal ?? baseSubtotal ?? 0;
              final discount =
                  couponData?.amounts?.discount ??
                  ((baseSubtotal ?? 0) - (baseTotal ?? baseSubtotal ?? 0));
              final deliveryFee = isDelivery ? 0.0 : 0.0;
              final total = couponData?.amounts?.total ?? baseTotal ?? 0;
              final merchantName = cart?.merchant?.name ??
                  supermarketCart?.merchant?.name ??
                  supermarketCart?.store?.name ??
                  (isStoreFlow ? 'المتجر' : 'المطعم');
              final merchantLocation = _merchantLocation(
                isStoreFlow: isStoreFlow,
                cart: cart,
                supermarketCart: supermarketCart,
              );

              return Column(
                children: [
                  PersonalDetailsAppBar(title: 'الطلبية الحالية'),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        12,
                        16,
                        20,
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: AppText.labelLarge(
                              'اختر الطريقة المناسبة لاستلام طلبك',
                              color: const Color(0xff6D28D9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _FulfillmentCard(
                            title: 'توصيل إلى العنوان',
                            subtitle: 'سيتم توصيل الطلب إلى موقعك',
                            icon: Icons.delivery_dining,
                            selected: isDelivery,
                            onTap: () {
                              context.read<OrdersBloc>().add(
                                CartFulfillmentTypeChangedEvent(
                                  fulfillmentType: 'delivery',
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _FulfillmentCard(
                            title: isStoreFlow
                                ? 'استلام من المتجر'
                                : 'استلام من المطعم',
                            subtitle: 'يمكنك استلام الطلب بنفسك',
                            icon: Icons.storefront_outlined,
                            selected: !isDelivery,
                            onTap: () {
                              context.read<OrdersBloc>().add(
                                CartFulfillmentTypeChangedEvent(
                                  fulfillmentType: 'pickup',
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          if (isDelivery)
                            _LocationCard(
                              title: 'موقع التوصيل',
                              topAction: 'تغيير',
                              onTopAction: () async {
                                final selected = await context.pushRoute(
                                  '/myaddresses',
                                  arguments: true,
                                );
                                if (!context.mounted) return;
                                if (selected is AddressListItem) {
                                  context.read<OrdersBloc>().add(
                                    CartSelectedAddressChangedEvent(
                                      address: selected,
                                    ),
                                  );
                                }
                              },
                              line1: state.selectedAddress?.line1 ??
                                  'لم يتم تحديد العنوان',
                              line2: state.selectedAddress?.street ?? '',
                            )
                          else
                            _LocationCard(
                              title: isStoreFlow
                                  ? 'موقع المتجر'
                                  : 'موقع المطعم',
                              line1: merchantName,
                              line2: merchantLocation.isNotEmpty
                                  ? merchantLocation
                                  : 'الموقع غير متوفر',
                            ),
                          if (args.cartId case final cartId?) ...[
                            const SizedBox(height: 24),
                            MerchantCheckoutCouponSection(
                              cartId: cartId,
                              section: args.section,
                            ),
                          ],
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xffE5E7EB),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: AppText.bodyMedium(
                                    'ملخص الطلب',
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff1F2937),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _SummaryRow(
                                  title: 'قيمة الطلب',
                                  value: _money(subtotal),
                                ),
                                if (isDelivery) ...[
                                  const SizedBox(height: 8),
                                  _SummaryRow(
                                    title: 'رسوم التوصيل',
                                    value: _money(deliveryFee),
                                  ),
                                ],
                                if (discount > 0) ...[
                                  const SizedBox(height: 8),
                                  _SummaryRow(
                                    title: 'الخصم',
                                    value: '- ${_money(discount)}',
                                    valueColor: const Color(0xff10B981),
                                  ),
                                ],
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    height: 1,
                                    color: Color(0xffE5E7EB),
                                  ),
                                ),
                                _SummaryRow(
                                  title: 'الإجمالي',
                                  value: _money(total),
                                  titleStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff1F2937),
                                  ),
                                  valueStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff1E2A78),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      16,
                      8,
                      16,
                      12,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isPlacingOrder
                            ? null
                            : () {
                                final cartId = args.cartId;
                                if (cartId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'تعذر تحديد السلة الحالية',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (isDelivery &&
                                    int.tryParse(
                                          state.selectedAddress?.id ?? '',
                                        ) ==
                                        null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'يرجى اختيار عنوان توصيل صالح',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                context.read<OrdersBloc>().add(
                                  isStoreFlow
                                      ? PlaceStoreOrderEvent(cartId: cartId)
                                      : PlaceRestaurantOrderEvent(
                                          cartId: cartId,
                                        ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1E2A78),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isPlacingOrder
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : AppText.bodyLarge(
                                'تاكيد الطلب',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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

class _FulfillmentCard extends StatelessWidget {
  const _FulfillmentCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffFFF7ED) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xffF97316)
                : const Color(0xffE5E7EB),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xffFED7AA)
                    : const Color(0xffF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected
                    ? const Color(0xffB45309)
                    : const Color(0xff9CA3AF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodyLarge(
                    title,
                    color: selected
                        ? const Color(0xffB45309)
                        : const Color(0xff374151),
                    fontWeight: FontWeight.bold,
                  ),
                  AppText.labelLarge(
                    subtitle,
                    color: selected
                        ? const Color(0xffC2410C)
                        : const Color(0xff6B7280),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_off,
              color: selected
                  ? const Color(0xffF97316)
                  : const Color(0xffD1D5DB),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.title,
    required this.line1,
    required this.line2,
    this.topAction,
    this.onTopAction,
  });

  final String title;
  final String line1;
  final String line2;
  final String? topAction;
  final VoidCallback? onTopAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_pin,
                color: Color(0xff6D28D9),
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AppText.bodyMedium(
                  title,
                  color: const Color(0xff1E2A78),
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.start,
                ),
              ),
              if (topAction != null)
                TextButton(
                  onPressed: onTopAction,
                  child: AppText.labelMedium(
                    topAction!,
                    color: const Color(0xff8B5CF6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xffF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelLarge(
                  line1,
                  color: const Color(0xff111827),
                ),
                if (line2.isNotEmpty)
                  AppText.labelMedium(
                    line2,
                    color: const Color(0xff6B7280),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.title,
    required this.value,
    this.valueColor,
    this.titleStyle,
    this.valueStyle,
  });

  final String title;
  final String value;
  final Color? valueColor;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: titleStyle ??
                const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff6B7280),
                ),
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xff111827),
              ),
        ),
      ],
    );
  }
}
