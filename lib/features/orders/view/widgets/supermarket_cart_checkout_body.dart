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

class SupermarketCartCheckoutBody extends StatelessWidget {
  const SupermarketCartCheckoutBody({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  String _money(double value) => '${value.toStringAsFixed(0)} ل.س';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      buildWhen: (p, c) =>
          p.storeCartStatus != c.storeCartStatus ||
          p.storeCarts != c.storeCarts ||
          p.storeCartErrorMessage != c.storeCartErrorMessage ||
          p.isMutatingStoreCartItem != c.isMutatingStoreCartItem,
      builder: (context, state) {
        final carts = state.storeCarts;
        final loading = state.storeCartStatus == BlocStatus.loading;
        final failed = state.storeCartStatus == BlocStatus.failed;

        if (loading && carts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (failed && carts.isEmpty) {
          return RestaurantCartLoadFailedView(
            errorMessage: state.storeCartErrorMessage,
            onRetry: () => context.read<OrdersBloc>().add(FetchStoreCartEvent()),
          );
        }
        if (carts.isEmpty) {
          return RestaurantCartEmptyView(onRefresh: onRefresh, isStore: true);
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
                    (cart) => _StoreCartCard(
                      cart: cart,
                      isMutating: state.isMutatingStoreCartItem,
                      money: _money,
                    ),
                  ),
                  const RestaurantCartAddMoreProductsButton(isRestaurant: false),
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

class _StoreCartCard extends StatelessWidget {
  const _StoreCartCard({
    required this.cart,
    required this.isMutating,
    required this.money,
  });

  final RestaurantCartDataModel cart;
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
                  cart.merchant?.name ?? 'المتجر',
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
                cartId: cartId,
                isStore: true,
                isMutating: isMutating,
                onDelete: () {
                  if (cartId == null || item.id == null) return;
                  context.read<OrdersBloc>().add(
                    DeleteStoreCartItemEvent(cartId: cartId, itemId: item.id!),
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

          ),
          const SizedBox(height: 12),
          RestaurantCartCheckoutFulfillmentButton(
            onTap: () {
              if (cartId == null) return;
              context.read<OrdersBloc>().add(SelectStoreCartEvent(cartId: cartId));
              context.pushRoute(
                '/restaurant-order-fulfillment',
                arguments: RestaurantOrderFulfillmentArgs(
                  bloc: context.read<OrdersBloc>(),
                  cartId: cartId,
                  section: 'supermarket',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
