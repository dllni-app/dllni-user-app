import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/store_product_item.dart';
import 'package:flutter/material.dart';

class FavouriteProductPlaceholderCard extends StatelessWidget {
  const FavouriteProductPlaceholderCard({super.key, required this.product});

  final StoreProductItem product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 18, 14, 14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFF1F2937), fontSize: 17, fontWeight: FontWeight.w700, height: 24 / 17),
                          ),
                          const SizedBox(height: 8),
                          AppText(
                            product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              AppText(
                                product.priceText,
                                style: const TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w700, height: 28 / 18),
                              ),
                              const SizedBox(width: 8),
                              if (product.oldPriceText != null)
                                AppText(
                                  product.oldPriceText!,
                                  style: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 24 / 16,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(10)),
                  child: AppText(
                    'قريباً',
                    style: TextStyle(color: Color(0xFF4B5563), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: const BoxDecoration(
                color: Color(0xFFFF7A00),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomRight: Radius.circular(16)),
              ),
              child: AppText(
                'نموذج',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, height: 16 / 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
