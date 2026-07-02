import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../sm_cart/view/widgets/cart_card.dart';
import '../../data/models/orders_api_models.dart';
import '../../domain/usecases/fetch_supermarket_cart_use_case.dart';
import '../../domain/usecases/remove_supermarket_cart_use_case.dart';
import '../manager/bloc/orders_bloc.dart';
import '../screens/restaurant_order_fulfillment_screen.dart';
import '../screens/supermarket_cart_details_screen.dart';
import 'restaurant_cart_checkout_fulfillment_button.dart';
import 'restaurant_cart_empty_view.dart';
import 'restaurant_cart_load_failed_view.dart';
import 'restaurant_cart_order_summary_section.dart';
import 'restaurant_cart_product_card.dart';

Future<bool?> showDeleteCartDialog(BuildContext context, String cartName) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "حذف السلة '$cartName' ؟",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "هل أنت متأكد من حذف هذه السلة؟\nهذا الإجراء لا يمكن التراجع عنه.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("إلغاء"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "حذف",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: context.height,
      color: Colors.black.withValues(alpha: 0.15),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class SupermarketCartCheckoutBody extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const SupermarketCartCheckoutBody({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      buildWhen: (p, c) =>
          p.supermarketCartStatus != c.supermarketCartStatus ||
          p.storeCartErrorMessage != c.storeCartErrorMessage ||
          p.isMutatingStoreCartItem != c.isMutatingStoreCartItem,
      builder: (context, state) {
        if (state.supermarketCartStatus == BlocStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.supermarketCartStatus == BlocStatus.failed) {
          return RestaurantCartLoadFailedView(
            errorMessage: state.storeCartErrorMessage,
            onRetry: () =>
                context.read<OrdersBloc>().add(FetchStoreCartEvent()),
          );
        }
        if (state.supermarketCart?.data?.isEmpty ?? true) {
          return CartEmptyView(onRefresh: onRefresh, isStore: true);
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 20),
                children: [
                  ...state.supermarketCart?.data?.first.merchantGroups?.map(
                        (cart) => CartCard(
                          cart: cart,
                          onTap: () {
                            context.pushRoute(
                              '/supermarketcartdetails',
                              arguments: SupermarketCartDetailsArgs(
                                storeName: cart.merchant?.name,
                                cart: cart,
                              ),
                            );
                          },
                          onDeleteTap: () async {
                            final bool yes =
                                await showDeleteCartDialog(
                                  context,
                                  cart.merchant?.name ?? "غير معروف",
                                ) ??
                                false;
                            if (!yes || !context.mounted) return;
                            context.read<OrdersBloc>().add(
                              RemoveSupermarketCartEvent(
                                params: RemoveSupermarketCartParams(
                                  id: cart.merchant?.id ?? 0,
                                ),
                              ),
                            );
                          },
                        ),
                        // _StoreCartCard(
                        //   cart: cart,
                        //   isMutating: state.isMutatingStoreCartItem,
                        //   money: '${value.toStringAsFixed(0)} ل.س',
                        // )
                      ) ??
                      [],
                  // const RestaurantCartAddMoreProductsButton(
                  //   isRestaurant: false,
                  // ),
                ],
              ),
            ),
            if (state.supermarketCartStatus == BlocStatus.loading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),
            BlocConsumer<OrdersBloc, OrdersState>(
              listenWhen: (p, c) =>
                  p.removeSupermarketCartStatus !=
                  c.removeSupermarketCartStatus,
              listener: (context, state) {
                if (state.removeSupermarketCartStatus == BlocStatus.failed) {
                  AppToast.showToast(
                    context: context,
                    message: state.errorMessage ?? "تعذر حذف السلة",
                    type: ToastificationType.error,
                  );
                }
                if (state.removeSupermarketCartStatus == BlocStatus.success) {
                  context.read<OrdersBloc>().add(
                    FetchSupermarketCartEvent(
                      params: FetchSupermarketCartParams(),
                    ),
                  );
                  AppToast.showToast(
                    context: context,
                    message: "تم حذف السلة بنجاح",
                    type: ToastificationType.success,
                  );
                }
              },
              buildWhen: (p, c) =>
                  p.removeSupermarketCartStatus !=
                  c.removeSupermarketCartStatus,
              builder: (context, state) {
                if (state.removeSupermarketCartStatus == BlocStatus.loading) {
                  return Positioned.fill(child: AppLoading());
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        );
      },
    );
  }
}

class _StoreCartCard extends StatelessWidget {
  final RestaurantCartDataModel cart;

  final bool isMutating;
  final String Function(double value) money;
  const _StoreCartCard({
    required this.cart,
    required this.isMutating,
    required this.money,
  });

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
              context.read<OrdersBloc>().add(
                SelectStoreCartEvent(cartId: cartId),
              );
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
