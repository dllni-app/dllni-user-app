import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ProductRecommendationItem {
  const ProductRecommendationItem({
    required this.id,
    required this.name,
    required this.merchantName,
    this.imageUrl,
    this.description,
    this.displayPrice,
    this.originalPrice,
    this.currency,
    this.isFavorited = false,
    this.masterProductId,
  });

  final int id;
  final String name;
  final String merchantName;
  final String? imageUrl;
  final String? description;
  final num? displayPrice;
  final num? originalPrice;
  final String? currency;
  final bool isFavorited;
  final int? masterProductId;
}

class ProductRecommendationsSection extends StatelessWidget {
  const ProductRecommendationsSection({
    super.key,
    required this.title,
    required this.items,
    required this.onProductTap,
  });

  final String title;
  final List<ProductRecommendationItem> items;
  final ValueChanged<ProductRecommendationItem> onProductTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      color: context.onPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppText(
              title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 24 / 16,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 236,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _ProductRecommendationCard(
                  item: item,
                  onTap: () => onProductTap(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRecommendationCard extends StatelessWidget {
  const _ProductRecommendationCard({required this.item, required this.onTap});

  final ProductRecommendationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final merchant = item.merchantName.trim();
    final description = item.description?.trim() ?? '';
    final oldPrice = item.originalPrice;

    return SizedBox(
      width: 164,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: SizedBox(
                    height: 112,
                    width: double.infinity,
                    child: (item.imageUrl ?? '').trim().isEmpty
                        ? Container(
                            color: const Color(0xFFF3F4F6),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_outlined,
                              color: Color(0xFF9CA3AF),
                              size: 34,
                            ),
                          )
                        : AppImage.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              color: const Color(0xFFF3F4F6),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_outlined,
                                color: Color(0xFF9CA3AF),
                                size: 34,
                              ),
                            ),
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (merchant.isNotEmpty) ...[
                          AppText(
                            merchant,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFFF7A00),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 16 / 11,
                            ),
                          ),
                          const SizedBox(height: 3),
                        ],
                        AppText(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 18 / 13,
                          ),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          AppText(
                            description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 16 / 11,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: AppText(
                                _recommendationPriceText(
                                  item.displayPrice,
                                  item.currency,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 18 / 12,
                                ),
                              ),
                            ),
                            if (oldPrice != null &&
                                oldPrice != item.displayPrice) ...[
                              const SizedBox(width: 5),
                              AppText(
                                _recommendationPriceText(
                                  oldPrice,
                                  item.currency,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
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

String _recommendationPriceText(num? value, String? currency) {
  if (value == null) return '-';
  final clean = value % 1 == 0 ? value.toInt().toString() : value.toString();
  final currencyText = (currency ?? '').trim();
  return currencyText.isEmpty ? clean : '$clean $currencyText';
}
