import 'package:dllni_user_app/features/rs_discover/view/models/store_product_item.dart';
import 'package:flutter/material.dart';

import 'favourite_empty_state.dart';
import 'favourite_product_placeholder_card.dart';

class FavouriteProductsTab extends StatelessWidget {
  const FavouriteProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final demoProducts = [
      StoreProductItem(
        name: 'برغر دبل',
        description: 'لحم مشوي، جبنة، وخضار طازجة',
        priceText: '7.50 د.أ',
        oldPriceText: '8.50 د.أ',
        category: 'الأكثر طلباً',
      ),
      StoreProductItem(
        name: 'بيتزا مارجريتا',
        description: 'صلصة طماطم وجبن موزاريلا',
        priceText: '6.00 د.أ',
        category: 'بيتزا',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        ...demoProducts.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FavouriteProductPlaceholderCard(product: item),
          ),
        ),
        const SizedBox(height: 8),
        const FavouriteEmptyState(
          title: 'لا توجد وجبات مفضلة حالياً',
          subtitle: 'سيتم عرض المنتجات المفضلة هنا عند توفر الخدمة.',
        ),
      ],
    );
  }
}
