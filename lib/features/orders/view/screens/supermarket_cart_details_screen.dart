import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../sm_stores/view/screens/sm_store_details_screen.dart';
import '../../data/models/fetch_supermarket_cart_model.dart';
import '../../domain/usecases/fetch_supermarket_cart_use_case.dart';
import '../../domain/usecases/get_single_supermarket_cart_use_case.dart';
import '../manager/bloc/orders_bloc.dart';
import '../widgets/restaurant_cart_checkout_fulfillment_button.dart';
import '../widgets/restaurant_cart_order_summary_section.dart';
import '../widgets/supermarket_cart_checkout_body.dart';
import 'restaurant_order_fulfillment_screen.dart';

class ProductCard extends StatefulWidget {
  final int cartId;
  final int itemId;
  final String imageUrl;
  final String name;
  final String addons;
  final num price;
  final num? discount;
  final num finalPrice;
  final int count;
  final void Function() onDelete;
  const ProductCard({
    super.key,
    required this.cartId,
    required this.itemId,
    required this.imageUrl,
    required this.name,
    required this.addons,
    required this.price,
    this.discount,
    required this.finalPrice,
    required this.count,
    required this.onDelete,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class SupermarketCartDetailsArgs {
  FetchSupermarketCartModelDataItem? cart;
  OrdersBloc? bloc;
  SupermarketCartDetailsArgs({this.cart, this.bloc});
}

@AutoRoutePage()
class SupermarketCartDetailsScreen extends StatefulWidget {
  final SupermarketCartDetailsArgs args;
  const SupermarketCartDetailsScreen({super.key, required this.args});

  @override
  State<SupermarketCartDetailsScreen> createState() =>
      _SupermarketCartDetailsScreenState();
}

class _AddAnotherProducts extends StatelessWidget {
  final void Function() onTap;
  const _AddAnotherProducts({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFB),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: DottedBorder(
          ignoring: false,
          options: RoundedRectDottedBorderOptions(
            radius: Radius.circular(16),
            dashPattern: [12, 6],
            strokeWidth: 2,
            color: Color(0x1F2F2B3D),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.plus,
                  color: Color(0xE52F2B3D),
                  size: 13,
                ),
                SizedBox(width: 4),
                Text(
                  "إضافة منتجات أخرى",
                  style: TextStyle(
                    color: Color(0xE52F2B3D),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCardState extends State<ProductCard> {
  static const Duration _debounceDuration = Duration(milliseconds: 400);

  int _count = 0;

  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OrdersBloc>(),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.all(Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Color(0x0D000000),
                  ),
                ],
              ),
              child: Column(
                spacing: 12,
                children: [
                  Row(
                    children: [
                      AppImage.network(
                        widget.imageUrl,
                        size: 96,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 23 / 18,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: "الإضافات: "),
                                  TextSpan(
                                    text: widget.addons,
                                    style: TextStyle(color: Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 16 / 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: InkWell(
                                onTap: _decrement,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                child: Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.minus,
                                    size: 12,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                              child: Text(
                                _count.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 20 / 14,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: InkWell(
                                onTap: _increment,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                child: Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.plus,
                                    size: 12,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          if (widget.discount != null)
                            Text(
                              "${widget.price.toStringAsFixed(2)} ل.س",
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Color(0xFF6B7280),
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 16 / 12,
                              ),
                            ),
                          Text(
                            "${widget.finalPrice.toStringAsFixed(2)} ل.س",
                            style: TextStyle(
                              color: Color(0xFF1A237E),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 24 / 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Center(
                    child: _TextButtonWithIcon(
                      label: "حذف",
                      icon: FontAwesomeIcons.trash,
                      color: Color(0xFFFF4C51),
                      onTap: widget.onDelete,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _count = widget.count;
    super.initState();
  }

  void _decrement() {
    if (_count == 1) return;
    _count--;
    setState(() {});
    _restartTimer();
  }

  void _increment() {
    setState(() => _count++);
    _restartTimer();
  }

  void _restartTimer() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, _sendRequest);
  }

  void _sendRequest() {
    context.read<OrdersBloc>().add(
      UpdateStoreCartItemEvent(
        cartId: widget.cartId,
        itemId: widget.itemId,
        quantity: _count,
      ),
    );
  }
}

class _SupermarketCartDetailsScreenState
    extends State<SupermarketCartDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.args.bloc ?? getIt<OrdersBloc>(),
      child: Scaffold(
        body: Column(
          children: [
            AppSimpleAppBar2(
              title: 'سلة ${widget.args.cart?.store?.name ?? 'غير معروف'}',
            ),
            Expanded(
              child: BlocConsumer<OrdersBloc, OrdersState>(
                listener: (context, state) {
                  if (state.singleSupermarketCartStatus == BlocStatus.success) {
                    widget.args.cart = state.singleSupermarketCart;
                    setState(() {});
                  }
                },
                buildWhen: (previous, current) =>
                    previous.singleSupermarketCartStatus !=
                    current.singleSupermarketCartStatus,
                builder: (context, state) {
                  // if(state.supermarketCartStatus == BlocStatus.loading) {
                  //   return Center(child: CircularProgressIndicator());
                  // }
                  // else if(state.super)
                  if (state.singleSupermarketCartStatus == BlocStatus.loading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state.singleSupermarketCartStatus ==
                      BlocStatus.failed) {
                    return Center(
                      child: FailureWidget(
                        message: state.errorMessage ?? 'حدث خطأ ما',
                        onRetry: () {
                          context.read<OrdersBloc>().add(
                            GetSingleSupermarketCartEvent(
                              params: GetSingleSupermarketCartParams(
                                cartId: widget.args.cart?.id ?? 0,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<OrdersBloc>().add(
                        GetSingleSupermarketCartEvent(
                          params: GetSingleSupermarketCartParams(
                            cartId: widget.args.cart?.id ?? 0,
                          ),
                        ),
                      );
                    },
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (_, index) => BlocProvider(
                              create: (context) => getIt<OrdersBloc>(),
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                                child: Stack(
                                  children: [
                                    Builder(
                                      builder: (innerContext) {
                                        return ProductCard(
                                          onDelete: () {
                                            innerContext.read<OrdersBloc>().add(
                                              DeleteStoreCartItemEvent(
                                                cartId: widget.args.cart?.id ?? 0,
                                                itemId:
                                                    widget
                                                        .args
                                                        .cart
                                                        ?.items?[index]
                                                        .id ??
                                                    0,
                                              ),
                                            );
                                          },
                                          cartId: widget.args.cart?.id ?? 0,
                                          itemId:
                                              widget
                                                  .args
                                                  .cart
                                                  ?.items?[index]
                                                  .id ??
                                              0,
                                
                                          imageUrl:
                                              widget
                                                  .args
                                                  .cart
                                                  ?.items?[index]
                                                  .product
                                                  ?.primaryImageUrl ??
                                              '',
                                          name:
                                              widget
                                                  .args
                                                  .cart
                                                  ?.items?[index]
                                                  .product
                                                  ?.name ??
                                              '',
                                          addons:
                                              widget
                                                      .args
                                                      .cart
                                                      ?.items?[index]
                                                      .product
                                                      ?.additions
                                                      ?.isEmpty ??
                                                  true
                                              ? 'لا يوجد إضافات'
                                              : widget
                                                        .args
                                                        .cart
                                                        ?.items?[index]
                                                        .product
                                                        ?.additions
                                                        ?.join(', ') ??
                                                    '',
                                          price:
                                              widget
                                                  .args
                                                  .cart
                                                  ?.items?[index]
                                                  .product
                                                  ?.price ??
                                              0,
                                          discount: widget
                                              .args
                                              .cart
                                              ?.items?[index]
                                              .product
                                              ?.discountedPrice,
                                          finalPrice:
                                              widget
                                                  .args
                                                  .cart
                                                  ?.items?[index]
                                                  .product
                                                  ?.finalPrice ??
                                              0,
                                          count:
                                              widget
                                                  .args
                                                  .cart
                                                  ?.items?[index]
                                                  .quantity ??
                                              0,
                                        );
                                      },
                                    ),
                                    BlocConsumer<OrdersBloc, OrdersState>(
                                      buildWhen: (previous, current) =>
                                          previous.deleteStoreCartItemStatus !=
                                          current.deleteStoreCartItemStatus,
                                      listenWhen: (previous, current) =>
                                          previous.deleteStoreCartItemStatus !=
                                          current.deleteStoreCartItemStatus,
                                      listener: (innerContext, state) {
                                        if (state.deleteStoreCartItemStatus ==
                                            BlocStatus.failed) {
                                          AppToast.showToast(
                                            context: innerContext,
                                            message:
                                                state.errorMessage ??
                                                'حدث خطأ ما',
                                            type: ToastificationType.error,
                                          );
                                        }
                                        if (state.deleteStoreCartItemStatus ==
                                            BlocStatus.success) {
                                          widget.args.cart?.items?.removeAt(
                                            index,
                                          );
                                          setState(() {});
                                          if (widget.args.cart?.items?.isEmpty ??
                                              true) {
                                            context.read<OrdersBloc>().add(
                                              FetchSupermarketCartEvent(
                                                params:
                                                    FetchSupermarketCartParams(),
                                              ),
                                            );
                                            AppToast.showToast(
                                              context: context,
                                              message: 'تم حذف سلة بنجاح',
                                              type: ToastificationType.success,
                                            );
                                            innerContext.pop();
                                          } else {
                                            context.read<OrdersBloc>().add(
                                              GetSingleSupermarketCartEvent(
                                                params:
                                                    GetSingleSupermarketCartParams(
                                                      cartId:
                                                          widget.args.cart?.id ??
                                                          0,
                                                    ),
                                              ),
                                            );
                                            AppToast.showToast(
                                              context: innerContext,
                                              message: 'تم حذف المنتج بنجاح',
                                              type: ToastificationType.success,
                                            );
                                          }
                                        }
                                      },
                                      builder: (context, state) {
                                        return state.deleteStoreCartItemStatus ==
                                                BlocStatus.loading
                                            ? Positioned.fill(child: AppLoading())
                                            : SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            separatorBuilder: (_, _) => SizedBox(height: 16),
                            itemCount: widget.args.cart?.items?.length ?? 0,
                          ),
                          SizedBox(height: 20),
                          _AddAnotherProducts(
                            onTap: () async {
                              final s = widget.args.cart?.store;
                              await context.pushRoute(
                                "/store",
                                arguments: SmStoreDetailsScreenArgs(
                                  storeId: s?.id ?? 0,
                                  starter: SmStarterStoreDetailsData(
                                    name: s?.name ?? '',
                                    cover: s?.cover,
                                    logo: s?.logo,
                                    averageRating: null,
                                    totalReviews: null,
                                    distanceKm: null,
                                    description: null,
                                    isFavorite: null,
                                    isActive: null,
                                  ),
                                ),
                              );
                              if (!context.mounted) return;
                              context.read<OrdersBloc>().add(
                                GetSingleSupermarketCartEvent(
                                  params: GetSingleSupermarketCartParams(
                                    cartId: widget.args.cart?.id ?? 0,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          RestaurantCartOrderSummarySection(
                            itemsCount: widget.args.cart?.productsCount ?? 0,
                            subtotal:
                                widget.args.cart?.amounts?.subtotal
                                    ?.toDouble() ??
                                0,
                            discount:
                                (widget.args.cart?.amounts?.total?.toDouble() ??
                                    0) -
                                (widget.args.cart?.amounts?.subtotal
                                        ?.toDouble() ??
                                    0),
                            total:
                                widget.args.cart?.amounts?.total?.toDouble() ??
                                0,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Builder(
            builder: (context) {
              return RestaurantCartCheckoutFulfillmentButton(
                onTap: () {
                  if (widget.args.cart?.id == null) return;
                  context.read<OrdersBloc>().add(
                    SelectStoreCartEvent(cartId: widget.args.cart?.id ?? 0),
                  );
                  context.pushRoute(
                    '/restaurant-order-fulfillment',
                    arguments: RestaurantOrderFulfillmentArgs(
                      bloc: context.read<OrdersBloc>(),
                      cartId: widget.args.cart?.id ?? 0,
                      section: 'supermarket',
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TextButtonWithIcon extends StatelessWidget {
  final String label;
  final FaIconData icon;
  final Color color;
  final void Function()? onTap;
  const _TextButtonWithIcon({
    required this.label,
    required this.icon,
    this.onTap,
    this.color = const Color(0xFF1A237E),
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(Radius.circular(4)),
        splashColor: color.withValues(alpha: .18),
        highlightColor: color.withValues(alpha: .08),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            FaIcon(icon, size: 12, color: color),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 16 / 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// RestaurantCartOrderSummarySection(
//   itemsCount: cart.items.length,
//   subtotal: cart.amounts?.subtotal ?? 0,
//   discount: 0,
//   total: cart.amounts?.total ?? 0,
// ),
// const SizedBox(height: 12),
// RestaurantCartCheckoutFulfillmentButton(
//   onTap: () {
//     if (cartId == null) return;
//     context.read<OrdersBloc>().add(
//       SelectStoreCartEvent(cartId: cartId),
//     );
//     context.pushRoute(
//       '/restaurant-order-fulfillment',
//       arguments: RestaurantOrderFulfillmentArgs(
//         bloc: context.read<OrdersBloc>(),
//         cartId: cartId,
//         section: 'supermarket',
//       ),
//     );
//   },
// ),
