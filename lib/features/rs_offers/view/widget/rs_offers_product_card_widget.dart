import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/widgets/rs_app_product_card.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/product_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/store_product_item.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:flutter/material.dart';

import '../../../rs_discover/data/models/fetch_restaurant_products_search_model.dart';
import '../../data/models/fetch_rs_offers_products_model.dart';

class RsOffersProductCardWidget extends StatelessWidget {
  final FetchRsOffersProductsModelDataItem product;

  const RsOffersProductCardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final mapped = _toStoreProductItem(product);
    final productId = mapped.id ?? 0;
    final offerText = (mapped.offerBadgeText ?? mapped.offer ?? '').trim();
    return RsAppProductCard(
      productId: productId,
      image: (mapped.imageUrl ?? '').trim(),
      title: mapped.name,
      restaurant: (mapped.restaurantName ?? '').trim().isEmpty ? 'مطعم' : mapped.restaurantName!.trim(),
      price: mapped.priceText,
      offer: FetchRestaurantProductsSearchModelActiveOffer(
        badgeText: mapped.offerBadgeText,
        discountType: mapped.offerDiscountType,
        discountValue: mapped.offerDiscountValue,
        title: mapped.offerUrgencyTag,
      ),
      onTap: () {
        if (productId <= 0) return;
        context.pushRoute(
          '/rs_product',
          arguments: ProductDetailsScreenParams(product: ProductPreviewData.fromStoreProduct(mapped, fallbackRestaurantName: mapped.restaurantName)),
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
