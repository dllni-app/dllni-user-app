import 'package:flutter/material.dart';

import '../../../rs_offers/data/models/fetch_rs_offers_products_model.dart';
import '../../../rs_offers/view/widget/rs_offers_app_bar.dart';
import '../../../rs_offers/view/widget/rs_offers_empty_widget.dart';
import '../../../rs_offers/view/widget/rs_offers_product_card_widget.dart';
import '../../data/models/fetch_restaurant_home_exclusive_offers_model.dart';

class RsHomeExclusiveOfferProductsScreen extends StatelessWidget {
  const RsHomeExclusiveOfferProductsScreen({super.key, required this.title, required this.products});

  final String title;
  final List<RestaurantHomeExclusiveOfferProduct> products;

  @override
  Widget build(BuildContext context) {
    final mappedProducts = products.map(_mapProduct).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          RsOffersAppBar(title: title.trim().isEmpty ? 'العرض' : title),
          const SizedBox(height: 14),
          Expanded(
            child: mappedProducts.isEmpty
                ? const RsOffersEmptyWidget()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: mappedProducts.length,
                    itemBuilder: (context, index) {
                      return RsOffersProductCardWidget(product: mappedProducts[index]);
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                  ),
          ),
        ],
      ),
    );
  }
}

FetchRsOffersProductsModelDataItem _mapProduct(RestaurantHomeExclusiveOfferProduct product) {
  return FetchRsOffersProductsModelDataItem(
    id: product.id,
    name: product.name,
    description: product.description,
    displayPrice: product.discountedPrice ?? product.price,
    originalPrice: product.discountedPrice != null ? product.price : null,
    currency: 'د.أ',
    isAvailable: product.isAvailableNow ?? product.isAvailable,
    isFavorite: product.isFavorite,
    primaryImageUrl: product.primaryImage,
    category: FetchRsOffersProductsModelCategory(id: product.categoryId),
    activeOffers: const [],
    createdAt: product.createdAt,
  );
}
