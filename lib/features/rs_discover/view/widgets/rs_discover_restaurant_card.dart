import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../screens/rs_restaurant_detail_screen.dart';

class RsDiscoverRestaurantCard extends StatelessWidget {
  const RsDiscoverRestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  final RsRestaurantListItem restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: context.onPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RestaurantImageSection(restaurant: restaurant),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.titleMedium(
                    restaurant.name,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xff111827),
                  ),
                  const SizedBox(height: 2),
                  AppText.labelLarge(
                    restaurant.categoryLabel,
                    color: const Color(0xff6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Color(0xff22C55E)),
                      const SizedBox(width: 4),
                      AppText.labelLarge(
                        restaurant.rating.toStringAsFixed(1),
                        color: const Color(0xff22C55E),
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(width: 8),
                      AppText.labelSmall(
                        '(${restaurant.reviewCountLabel})',
                        color: const Color(0xff9CA3AF),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.navigation_outlined,
                        size: 14,
                        color: Color(0xff9CA3AF),
                      ),
                      const SizedBox(width: 2),
                      AppText.labelSmall(
                        restaurant.distanceLabel,
                        color: const Color(0xff9CA3AF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: Color(0xff9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      AppText.labelMedium(
                        restaurant.deliveryTimeLabel,
                        color: const Color(0xff6B7280),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 15,
                        color: Color(0xff9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      AppText.labelMedium(
                        restaurant.deliveryFeeLabel,
                        color: const Color(0xff6B7280),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantImageSection extends StatelessWidget {
  const _RestaurantImageSection({required this.restaurant});

  final RsRestaurantListItem restaurant;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadiusDirectional.only(
        topStart: Radius.circular(20),
        topEnd: Radius.circular(20),
      ),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 8.8,
            child: Image.network(
              restaurant.heroImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [Color(0xffE5E7EB), Color(0xffD1D5DB)],
                    ),
                  ),
                );
              },
            ),
          ),
          PositionedDirectional(
            top: 10,
            start: 10,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(235),
                shape: BoxShape.circle,
              ),
              child: Icon(
                restaurant.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: restaurant.isFavorite
                    ? const Color(0xffEF4444)
                    : const Color(0xff6B7280),
                size: 19,
              ),
            ),
          ),
          if (restaurant.discountLabel != null)
            PositionedDirectional(
              bottom: 10,
              start: 10,
              child: _Badge(
                text: restaurant.discountLabel!,
                backgroundColor: context.primaryContainer,
                textColor: context.onPrimary,
              ),
            ),
          if (restaurant.badgeLabel != null)
            PositionedDirectional(
              bottom: 10,
              end: 10,
              child: _Badge(
                text: restaurant.badgeLabel!,
                backgroundColor: context.primary,
                textColor: context.onPrimary,
              ),
            ),
          PositionedDirectional(
            top: 10,
            end: 10,
            child: _Badge(
              text: restaurant.deliveryTimeLabel,
              backgroundColor: Colors.white.withAlpha(225),
              textColor: context.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 4),
        child: AppText.labelMedium(
          text,
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
