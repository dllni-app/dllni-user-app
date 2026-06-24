import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/orders_api_models.dart';
import '../manager/bloc/orders_bloc.dart';
import '../screens/restaurant_order_fulfillment_screen.dart';
import 'restaurant_cart_add_more_products_button.dart';
import 'restaurant_cart_checkout_fulfillment_button.dart';
import 'restaurant_cart_empty_view.dart';
import 'restaurant_cart_load_failed_view.dart';
import 'restaurant_cart_order_summary_section.dart';
import 'restaurant_cart_product_card.dart';

class RestaurantCartCheckoutBody extends StatelessWidget {
  const RestaurantCartCheckoutBody({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  String _money(double value) => '${value.toStringAsFixed(0)} ل.س';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      buildWhen: (p, c) =>
          p.restaurantCartStatus != c.restaurantCartStatus ||
          p.restaurantCarts != c.restaurantCarts ||
          p.restaurantCartErrorMessage != c.restaurantCartErrorMessage ||
          p.isMutatingCartItem != c.isMutatingCartItem,
      builder: (context, state) {
        final carts = state.restaurantCarts;
        final loading = state.restaurantCartStatus == BlocStatus.loading;
        final failed = state.restaurantCartStatus == BlocStatus.failed;

        if (loading && carts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (failed && carts.isEmpty) {
          return RestaurantCartLoadFailedView(
            errorMessage: state.restaurantCartErrorMessage,
            onRetry: () => context.read<OrdersBloc>().add(FetchRestaurantCartEvent()),
          );
        }
        if (carts.isEmpty) {
          return RestaurantCartEmptyView(onRefresh: onRefresh, isStore: false);
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 20),
                children: [
                  ...carts.map(
                    (cart) => _MerchantCartCard(
                      cart: cart,
                      isStore: false,
                      isMutating: state.isMutatingCartItem,
                      money: _money,
                    ),
                  ),
                  const RestaurantCartAddMoreProductsButton(),
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

class _MerchantCartCard extends StatelessWidget {
  const _MerchantCartCard({
    required this.cart,
    required this.isStore,
    required this.isMutating,
    required this.money,
  });

  final RestaurantCartDataModel cart;
  final bool isStore;
  final bool isMutating;
  final String Function(double value) money;

  @override
  Widget build(BuildContext context) {
    final cartId = cart.id;
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 16),
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
              Expanded(
                child: AppText.bodyLarge(
                  cart.merchant?.name ?? 'المطعم',
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1F2937),
                ),
              ),
              AppText.labelMedium(
                '${cart.items.length} عناصر',
                color: const Color(0xff6B7280),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...cart.items.map(
            (item) => Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 12),
              child: RestaurantCartProductCard(
                item: item,
                isMutating: isMutating,
                onDelete: () {
                  if (cartId == null || item.id == null) return;
                  context.read<OrdersBloc>().add(
                    DeleteRestaurantCartItemEvent(cartId: cartId, itemId: item.id!),
                  );
                },
                money: money,
              ),
            ),
          ),
          RestaurantCartOrderSummarySection(
            itemsCount: cart.items.length,
            subtotal: cart.amounts?.subtotal ?? 0,
            discount: 0,
            total: cart.amounts?.total ?? 0,
            money: money,
          ),
          const SizedBox(height: 12),
          RestaurantCartCheckoutFulfillmentButton(
            onTap: cartId == null
                ? null
                : () {
                    context.read<OrdersBloc>().add(
                      SelectRestaurantCartEvent(cartId: cartId),
                    );
                    context.pushRoute(
                      '/restaurant-order-fulfillment',
                      arguments: RestaurantOrderFulfillmentArgs(
                        bloc: context.read<OrdersBloc>(),
                        cartId: cartId,
                        section: 'restaurant',
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
