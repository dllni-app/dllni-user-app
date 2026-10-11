import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/themes/v7_artwork.dart';

/// The V7 illustration-led, photo-supported service entry, preserving V5 keys
/// for existing deep links/widget tests while refreshing the visual hierarchy.
class PlatformHomeExperienceV5 extends StatelessWidget {
  const PlatformHomeExperienceV5({
    super.key,
    required this.onCleaning,
    required this.onRestaurants,
    required this.onSupermarket,
    this.onDelivery,
  });

  final VoidCallback onCleaning;
  final VoidCallback onRestaurants;
  final VoidCallback onSupermarket;
  final VoidCallback? onDelivery;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'خدماتنا',
          style: TextStyle(
            color: SharedPlatformColors.primary,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'كل اللي تحتاجه من مكان واحد',
          style: TextStyle(color: SharedPlatformColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _V7Category(
                key: const Key('platform_home_v5_cleaning_tile'),
                title: 'التنظيفات',
                description: 'لبيتك ومناسباتك',
                asset: V7Artwork.categoryCleaning,
                color: SharedPlatformColors.cleaningSoft,
                onTap: onCleaning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _V7Category(
                key: const Key('platform_home_v5_restaurants_tile'),
                title: 'المطاعم',
                description: 'وجبات تحبها',
                asset: V7Artwork.categoryRestaurant,
                color: SharedPlatformColors.restaurantSoft,
                onTap: onRestaurants,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _V7Category(
                key: const Key('platform_home_v5_supermarket_tile'),
                title: 'السوبرماركت',
                description: 'مشتريات البيت',
                asset: V7Artwork.categorySupermarket,
                color: SharedPlatformColors.supermarketSoft,
                onTap: onSupermarket,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _V7Category(
                key: const Key('platform_home_v7_delivery_tile'),
                title: 'التوصيل',
                description: onDelivery == null ? 'قريباً' : 'متابعة التوصيل',
                asset: V7Artwork.categoryDelivery,
                color: SharedPlatformColors.deliverySoft,
                onTap: onDelivery,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ClipRRect(
          key: const Key('platform_home_v5_hero'),
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 270,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  V7Artwork.cleaningHome,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const ColoredBox(color: SharedPlatformColors.primary),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xE6172554),
                        Color(0xBF172554),
                        Color(0x18172554),
                      ],
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 245),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'ع الندهة',
                            style: TextStyle(
                              color: Color(0xFF8DE4E8),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'بيتك أنظف، ووقتك إلك',
                            maxLines: 2,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              height: 1.35,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            'اختر التنظيف المناسب لمنزلك بخطوات سهلة.',
                            maxLines: 2,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 9),
                          FilledButton.icon(
                            key: const Key('platform_home_v5_cleaning_cta'),
                            onPressed: onCleaning,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 18,
                            ),
                            label: const Text('استكشف التنظيفات'),
                            style: FilledButton.styleFrom(
                              foregroundColor: SharedPlatformColors.primary,
                              backgroundColor: Colors.white,
                              minimumSize: const Size(0, 44),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _V7Category extends StatelessWidget {
  const _V7Category({
    super.key,
    required this.title,
    required this.description,
    required this.asset,
    required this.color,
    required this.onTap,
  });
  final String title;
  final String description;
  final String asset;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: '$title، $description',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(minHeight: 175),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: SharedPlatformColors.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: V7ArtTile(
                    asset: asset,
                    size: 82,
                    background: color,
                    radius: 20,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SharedPlatformColors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SharedPlatformColors.muted,
                    fontSize: 11,
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
