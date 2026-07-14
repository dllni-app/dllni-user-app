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
      color: context.onPrimary,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xffE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                offset: const Offset(0, 4),
                blurRadius: 14,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _SuggestionTag(
                    label: item.badge.trim().isEmpty ? 'اقتراح' : item.badge,
                    backgroundColor: const Color(0xffFFF3E8),
                    foregroundColor: const Color(0xffC75A00),
                  ),
                  const SizedBox(width: 8),
                  _SuggestionTag(
                    label: '${item.productsCount} منتجات',
                    backgroundColor: const Color(0xffF3F4F6),
                    foregroundColor: const Color(0xff4B5563),
                  ),
                  const Spacer(),
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xffF9FAFB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 15,
                      color: Color(0xff6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _buildImage(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.titleMedium(
                          item.title.trim().isEmpty ? 'مطعم مقترح' : item.title,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff111827),
                          textAlign: TextAlign.start,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 7),
                        AppText.labelLarge(
                          item.details.trim().isEmpty
                              ? 'اضغط لعرض المنتجات المقترحة.'
                              : item.details,
                          color: const Color(0xff6B7280),
                          fontWeight: FontWeight.w500,
                          textAlign: TextAlign.start,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Container(
                width: double.infinity,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF9FAFB),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 17,
                      color: Color(0xff6B7280),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: AppText.labelLarge(
                        item.secondaryInfo.trim().isEmpty
                            ? 'التفاصيل متاحة داخل الاقتراح'
                            : item.secondaryInfo,
                        color: const Color(0xff4B5563),
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                      ),
                    ),
                    AppText.labelLarge(
                      'عرض المنتجات',
                      color: context.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = item.imageUrl?.trim() ?? '';

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 86,
        height: 86,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Assets.images.mainOrders.image(
              width: 86,
              height: 86,
              fit: BoxFit.cover,
            ),
      );
    }

    return Assets.images.mainOrders.image(
      width: 86,
      height: 86,
      fit: BoxFit.cover,
    );
  }
}

class _SuggestionTag extends StatelessWidget {
  const _SuggestionTag({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: AppText.labelLarge(
        label,
        color: foregroundColor,
        fontWeight: FontWeight.w700,
        maxLines: 1,
      ),
    );
  }
}
