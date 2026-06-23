import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/orders_api_models.dart';
import '../manager/bloc/orders_bloc.dart';
import '../screens/restaurant_order_fulfillment_screen.dart';
import 'restaurant_cart_add_more_products_button.dart';
import 'restaurant_cart_checkout_fulfillment_button.dart';
import 'restaurant_cart_coupon_section.dart';
import 'restaurant_cart_empty_view.dart';
import 'restaurant_cart_load_failed_view.dart';
import 'restaurant_cart_order_notes_section.dart';
import 'restaurant_cart_order_summary_section.dart';
import 'restaurant_cart_product_card.dart';

class RestaurantCartCheckoutBody extends StatefulWidget {
  const RestaurantCartCheckoutBody({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  State<RestaurantCartCheckoutBody> createState() => _RestaurantCartCheckoutBodyState();
}

class _RestaurantCartCheckoutBodyState extends State<RestaurantCartCheckoutBody> {
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.text = context.read<OrdersBloc>().state.cartNote;
  }

  @override
  void dispose() {
    _couponController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // String _money(double value) => '${value.toStringAsFixed(0)} ل.س';

  String _money(double value) => '${value.toStringAsFixed(0)} ل.س';
  String _couponUnavailableMessage(CouponCheckDataModel? couponData) {
    switch (couponData?.reason) {
      case 'not_found':
        return 'الكوبون غير موجود.';
      case 'expired':
        return 'انتهت صلاحية هذا الكوبون.';
      case 'not_available':
        return 'هذا الكوبون غير متاح حالياً.';
      default:
        return 'لا يمكن استخدام هذا الكوبون.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      buildWhen: (p, c) =>
          p.restaurantCartStatus != c.restaurantCartStatus ||
          p.restaurantCart != c.restaurantCart ||
          p.restaurantCartErrorMessage != c.restaurantCartErrorMessage ||
          p.couponStatus != c.couponStatus ||
          p.couponData != c.couponData ||
          p.cartNote != c.cartNote ||
          p.isMutatingCartItem != c.isMutatingCartItem,
      builder: (context, state) {
        final cart = state.restaurantCart;
        final loading = state.restaurantCartStatus == BlocStatus.loading;
        final failed = state.restaurantCartStatus == BlocStatus.failed;
        final hasCart = cart != null && cart.items.isNotEmpty;
        final subtotal = state.couponData?.amounts?.subtotal ?? cart?.amounts?.subtotal ?? 0;
        final discount = state.couponData?.amounts?.discount ?? (subtotal - (cart?.amounts?.total ?? 0));
        final total = state.couponData?.amounts?.total ?? cart?.amounts?.total ?? 0;

        if (loading && cart == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (failed && cart == null) {
          return RestaurantCartLoadFailedView(
            errorMessage: state.restaurantCartErrorMessage,
            onRetry: () => context.read<OrdersBloc>().add(FetchRestaurantCartEvent()),
          );
        }
        if (!hasCart) {
          return RestaurantCartEmptyView(onRefresh: widget.onRefresh, isStore: false,);
        }

        final data = cart;
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 20),
                children: [
                  ...data.items.map(
                    (item) => Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 12),
                      child: RestaurantCartProductCard(
                        item: item,
                        isMutating: state.isMutatingCartItem,
                        onDelete: () {
                          if (item.id == null) return;
                          context.read<OrdersBloc>().add(DeleteRestaurantCartItemEvent(itemId: item.id!));
                        },

                        money: _money,
                      ),
                    ),
                  ),
                  const RestaurantCartAddMoreProductsButton(),
                  const SizedBox(height: 12),
                  RestaurantCartCouponSection(
                    couponController: _couponController,
                    state: state,
                    discount: discount,
                    money: _money,
                    couponUnavailableMessage: _couponUnavailableMessage,
                  ),
                  const SizedBox(height: 12),
                  RestaurantCartOrderNotesSection(
                    notesController: _notesController,
                    onChanged: (value) => context.read<OrdersBloc>().add(CartNoteChangedEvent(note: value)),
                  ),
                  const SizedBox(height: 12),
                  RestaurantCartOrderSummarySection(itemsCount: data.items.length, subtotal: subtotal, discount: discount, total: total, money: _money),
                  const SizedBox(height: 16),
                  RestaurantCartCheckoutFulfillmentButton(
                    onTap: () {
                      context.pushRoute(
                        '/restaurant-order-fulfillment',
                        arguments: RestaurantOrderFulfillmentArgs(bloc: context.read<OrdersBloc>(), cartId: data.id, section: 'restaurant'),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (loading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        );
      },
    );
  }
}
