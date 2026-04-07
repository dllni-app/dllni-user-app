import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/cart/cart_products_count_cubit.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/rs_discover/domain/usecases/add_restaurant_cart_item_use_case.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/store_product_item.dart';
import 'package:dllni_user_app/features/rs_favourite/view/widgets/favourite_product_placeholder_card.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../data/models/fetch_rs_offers_products_model.dart';

class RsOffersProductCardWidget extends StatelessWidget {
  final FetchRsOffersProductsModelDataItem product;

  const RsOffersProductCardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final mapped = _toStoreProductItem(product);
    return FavouriteProductPlaceholderCard(
      product: mapped,
      onAddToCart: () async {
        final productId = mapped.id;
        if (productId == null || productId <= 0) {
          AppToast.showToast(
            context: context,
            message: 'تعذر تحديد المنتج',
            type: ToastificationType.error,
          );
          return;
        }

        final res = await getIt<AddRestaurantCartItemUseCase>()(
          AddRestaurantCartItemParams(
            productId: productId,
            quantity: 1,
            modifierIds: const [],
            substituteProductId: null,
            specialInstructions: '',
          ),
        );

        if (!context.mounted) return;
        res.fold(
          (failure) => AppToast.showToast(
            context: context,
            message: failure.message,
            type: ToastificationType.error,
          ),
          (result) {
            getIt<CartProductsCountCubit>().refreshAfterAdd();
            AppToast.showToast(
              context: context,
              message: (result.message ?? '').trim().isNotEmpty
                  ? result.message!
                  : 'تمت إضافة المنتج إلى السلة',
              type: ToastificationType.success,
            );
          },
        );
      },
    );
  }
}

StoreProductItem _toStoreProductItem(FetchRsOffersProductsModelDataItem product) {
  final activeOffers = (product.activeOffers ?? []).where((offer) => offer.isActive == true).toList();
  final activeOffer = activeOffers.isNotEmpty ? activeOffers.first : null;
  final displayPrice = product.displayPrice;
  final originalPrice = product.originalPrice;
  final currency = (product.currency ?? '').trim();

  String? formatPrice(num? value) {
    if (value == null) return null;
    final normalized = value % 1 == 0 ? value.toInt().toString() : value.toString();
    return '$normalized $currency'.trim();
  }

  return StoreProductItem(
    id: product.id,
    name: product.name ?? '-',
    description: product.description ?? product.restaurant?.name ?? '',
    priceText: formatPrice(displayPrice) ?? '-',
    oldPriceText: formatPrice(originalPrice),
    category: product.category?.name ?? activeOffer?.badgeText ?? '',
    displayPriceValue: displayPrice,
    oldPriceValue: originalPrice,
    currency: currency.isEmpty ? null : currency,
    imageUrl: product.primaryImageUrl,
    restaurantName: product.restaurant?.name,
    offer: activeOffer?.badgeText,
    offerName: activeOffer?.name,
    offerBadgeText: activeOffer?.badgeText,
    offerUrgencyTag: activeOffer?.urgencyTag,
    offerDiscountType: activeOffer?.discountType,
    offerDiscountValue: activeOffer?.discountValue,
    isOfferActive: activeOffer?.isActive,
  );
}
