import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../features/orders/domain/usecases/delete_cart_item_use_case.dart';
import '../../features/orders/domain/usecases/fetch_restaurant_cart_use_case.dart';
import '../../features/rs_discover/data/models/fetch_restaurant_products_search_model.dart';
import '../../features/rs_discover/domain/usecases/add_restaurant_cart_item_use_case.dart';
import '../cart/cart_products_count_cubit.dart';
import '../di/injection.dart';

class RsAppProductCard extends StatefulWidget {
  const RsAppProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.restaurant,
    required this.price,
    required this.onTap,
    this.isInCart = false,
    this.cartProductsCount = 0,
    this.cartItemId,
    required this.productId,
    required this.offer,
  });

  final String image;
  final String title;
  final String restaurant;
  final String price;
  final int productId;
  final Function() onTap;
  final bool isInCart;
  final int cartProductsCount;
  final int? cartItemId;
  final FetchRestaurantProductsSearchModelActiveOffer? offer;

  @override
  State<RsAppProductCard> createState() => _RsAppProductCardState();
}

class _RsAppProductCardState extends State<RsAppProductCard> {
  int _cartProductsCount = 0;
  int? _cartItemId;
  bool _isMutatingCart = false;

  bool get _hasCartQuantity => _cartProductsCount >= 1;

  @override
  void initState() {
    super.initState();
    _syncInitialCartState();
  }

  @override
  void didUpdateWidget(covariant RsAppProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId ||
        oldWidget.cartProductsCount != widget.cartProductsCount ||
        oldWidget.cartItemId != widget.cartItemId ||
        oldWidget.isInCart != widget.isInCart) {
      _syncInitialCartState();
    }
  }

  void _syncInitialCartState() {
    _cartProductsCount = widget.cartProductsCount > 0 ? widget.cartProductsCount : (widget.isInCart ? 1 : 0);
    _cartItemId = widget.cartItemId;
  }

  @override
  Widget build(BuildContext context) {
    final safeImage = widget.image.trim();
    final isDeleteState = _hasCartQuantity;
    return Container(
      width: 166,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffF3F4F6), width: 1),
        color: context.onPrimary,
      ),
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        safeImage.isEmpty
                            ? Container(
                                width: context.width,
                                height: 100,
                                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)),
                              )
                            : AppImage.network(
                                safeImage,
                                width: context.width,
                                height: 100,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(16),
                                errorWidget: Container(
                                  width: context.width,
                                  height: 100,
                                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)),
                                ),
                              ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Row(
                            spacing: 10,
                            children: [
                              Expanded(child: AppText.bodyMedium(widget.title, fontWeight: FontWeight.bold, maxLines: 1, scrollText: true)),
                              if (widget.offer?.badgeText != null)
                                Container(
                                  decoration: BoxDecoration(color: context.primaryContainer.withAlpha(51), borderRadius: BorderRadius.circular(16)),
                                  padding: EdgeInsetsDirectional.symmetric(horizontal: 4),
                                  child: AppText.labelMedium(widget.offer!.badgeText!, color: context.primaryContainer, fontWeight: FontWeight.bold,),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: AppText.bodyMedium(
                            widget.restaurant,
                            fontWeight: FontWeight.w400,
                            maxLines: 1,
                            scrollText: true,
                            color: const Color(0xff6B7280),
                          ),
                        ),
                        Expanded(child: AppText.bodyMedium(widget.price, fontWeight: FontWeight.bold, maxLines: 1, color: const Color(0xff1E2A78))),
                      ],
                    ),
                  ),
                  if (widget.offer?.title != null)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: context.primaryContainer,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                          ),
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
                          child: AppText.labelSmall(widget.offer!.title!, fontWeight: FontWeight.bold, color: context.onPrimaryContainer),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: InkWell(
              onTap: _isMutatingCart
                  ? null
                  : (isDeleteState
                  ? _onDeleteFromCartPressed
                  : () => _onAddToCartPressed(widget.productId)),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: double.infinity,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isMutatingCart
                      ? const Color(0xFFF3F4F6)
                      : (isDeleteState ? context.onPrimary : context.primary),
                  border: isDeleteState
                      ? Border.all(color: const Color(0xFFEF4444))
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                    );
                  },
                  child: _isMutatingCart
                      ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                    ),
                  )
                      : AppText.bodyMedium(
                    isDeleteState ? 'حذف من السلة' : 'طلب الوجبة',
                    key: ValueKey(isDeleteState),
                    color: isDeleteState
                        ? const Color(0xFFEF4444)
                        : context.onPrimary,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAddToCartPressed(int id) async {
    if (_isMutatingCart) return;
    final previousCount = _cartProductsCount;
    final previousItemId = _cartItemId;

    setState(() {
      _isMutatingCart = true;
      _cartProductsCount = 1;
    });

    final result = await getIt<AddRestaurantCartItemUseCase>()(
      AddRestaurantCartItemParams(productId: id, quantity: 1, quantityMode: 'increment'),
    );

    if (!mounted) return;

    result.fold(
      (_) {
        setState(() {
          _isMutatingCart = false;
          _cartProductsCount = previousCount;
          _cartItemId = previousItemId;
        });
      },
      (response) {
        setState(() {
          _isMutatingCart = false;
          _cartProductsCount = response.quantity ?? 1;
          _cartItemId = response.itemId ?? previousItemId;
        });
        final totalCount = response.cartProductsCount;
        if (totalCount != null) {
          getIt<CartProductsCountCubit>().setCount(totalCount);
        } else {
          getIt<CartProductsCountCubit>().refreshAfterAdd();
        }
      },
    );
  }

  Future<void> _onDeleteFromCartPressed() async {
    if (_isMutatingCart) return;
    final previousCount = _cartProductsCount;
    final previousItemId = _cartItemId;

    setState(() {
      _isMutatingCart = true;
      _cartProductsCount = 0;
    });

    final itemId = previousItemId ?? await _resolveCartItemId();
    if (!mounted) return;

    if (itemId == null) {
      setState(() {
        _isMutatingCart = false;
        _cartProductsCount = previousCount;
        _cartItemId = previousItemId;
      });
      await getIt<CartProductsCountCubit>().refreshAfterAdd();
      return;
    }

    final result = await getIt<DeleteCartItemUseCase>()(DeleteCartItemParams(itemId: itemId));

    if (!mounted) return;

    result.fold(
      (_) {
        setState(() {
          _isMutatingCart = false;
          _cartProductsCount = previousCount;
          _cartItemId = previousItemId;
        });
      },
      (_) {
        setState(() {
          _isMutatingCart = false;
          _cartProductsCount = 0;
          _cartItemId = null;
        });
        getIt<CartProductsCountCubit>().refreshAfterAdd();
      },
    );
  }

  Future<int?> _resolveCartItemId() async {
    final result = await getIt<FetchRestaurantCartUseCase>()(NoParams());

    return result.fold(
      (_) => null,
      (cart) {
        final items = cart.data?.items ?? const [];
        for (final item in items) {
          if (item.productId == widget.productId && item.modifierIds.isEmpty && item.substituteProductId == null) {
            return item.id;
          }
        }
        for (final item in items) {
          if (item.productId == widget.productId) {
            return item.id;
          }
        }
        return null;
      },
    );
  }
}
