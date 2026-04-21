import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/assets.dart';

class LuckySuggestionItem {
  const LuckySuggestionItem({
    required this.badge,
    required this.productsCount,
    required this.title,
    required this.details,
    required this.secondaryInfo,
    this.imageUrl,
  });

  final String badge;
  final int productsCount;
  final String title;
  final String details;
  final String secondaryInfo;
  final String? imageUrl;
}

class LuckySuggestionCard extends StatelessWidget {
  const LuckySuggestionCard({super.key, required this.item, this.onTap});

  final LuckySuggestionItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.onPrimary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xffF3F4F6)),
              ),
              padding: const EdgeInsetsDirectional.fromSTEB(14, 20, 14, 14),
              child: Column(
                children: [
                  Row(
                    spacing: 14,
                    children: [
                      Expanded(
                        child: AppText.titleMedium(
                          item.title,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff1F2937),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: const Color(0xffFFEDD5), borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3),
                        child: AppText.labelLarge('${item.productsCount} منتجات', color: const Color(0xffB45309), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.labelLarge(item.details, color: const Color(0xff6B7280), fontWeight: FontWeight.w500, textAlign: TextAlign.start),
                            const SizedBox(height: 6),
                            AppText.labelLarge(item.secondaryInfo, color: const Color(0xff9CA3AF)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                            ? Image.network(
                                item.imageUrl!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Assets.images.mainOrders.image(width: 88, height: 88, fit: BoxFit.cover),
                              )
                            : Assets.images.mainOrders.image(width: 88, height: 88, fit: BoxFit.cover),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xffFF7A00),
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(8),
                      topEnd: Radius.circular(8),
                      bottomEnd: Radius.circular(8),
                    ),
                  ),
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 9, vertical: 3),
                  child: AppText.labelLarge(item.badge, color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
