import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'product_card.dart';

class ProductsSection extends StatelessWidget {
  const ProductsSection({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
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
          itemCount: 2,
          separatorBuilder: (context, index) => SizedBox(height: 8),
          itemBuilder: (context, index) => ProductCard(),
        ),
      ],
    );
  }
}
