import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/sm_store_product_summary.dart';
import 'product_card.dart';

class ProductsSection extends StatelessWidget {
  const ProductsSection({
    super.key,
    required this.title,
    required this.products,
  });

  final String title;
  final List<SmStoreProductSummary> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppText(
            title,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 28 / 16,
            ),
          ),
        ),
        ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: products.length,
          separatorBuilder: (context, index) => SizedBox(height: 8),
          itemBuilder: (context, index) =>
              ProductCard(product: products[index]),
        ),
      ],
    );
  }
}
