import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

/// Main-platform entry point: services and actions share the same design
/// foundation while retaining their individual accent colours.
class PlatformHomeExperienceV5 extends StatelessWidget {
  const PlatformHomeExperienceV5({
    super.key,
    required this.onCleaning,
    required this.onRestaurants,
    required this.onSupermarket,
  });

  final VoidCallback onCleaning;
  final VoidCallback onRestaurants;
  final VoidCallback onSupermarket;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: const Key('platform_home_v5_hero'),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF172554), Color(0xFF283C7B)],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              PositionedDirectional(
                top: -34,
                end: -26,
                child: IgnorePointer(
                  child: Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      color: SharedPlatformColors.cleaning.withValues(
                        alpha: 0.14,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'ع الندهة',
                    style: TextStyle(
                      color: Color(0xFF8DE4E8),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'كل اللي بتحتاجه، بمكان واحد',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.35,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'خدمات تنظيف، وجبات ومشتريات. اختَر الخدمة وتابع طلبك بكل سهولة.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.84),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilledButton.icon(
                      key: const Key('platform_home_v5_cleaning_cta'),
                      onPressed: onCleaning,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        foregroundColor: SharedPlatformColors.primary,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text(
                        'اطلب خدمة تنظيف',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
          'اختر الخدمة المناسبة لك',
          style: TextStyle(color: SharedPlatformColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        _ServiceTile(
          key: const Key('platform_home_v5_cleaning_tile'),
          title: 'تنظيفات ومناسبات',
          subtitle: 'منزلك ومناسباتك بأيدٍ تساعدك',
          icon: Icons.cleaning_services_rounded,
          accent: SharedPlatformColors.cleaningInk,
          soft: SharedPlatformColors.cleaningSoft,
          onTap: onCleaning,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ServiceTile(
                key: const Key('platform_home_v5_restaurants_tile'),
                title: 'مطاعم',
                subtitle: 'وجبات تحبها',
                icon: Icons.restaurant_menu_rounded,
                accent: SharedPlatformColors.restaurant,
                soft: SharedPlatformColors.restaurantSoft,
                onTap: onRestaurants,
                compact: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ServiceTile(
                key: const Key('platform_home_v5_supermarket_tile'),
                title: 'سوبرماركت',
                subtitle: 'مشتريات بيتك',
                icon: Icons.shopping_basket_rounded,
                accent: SharedPlatformColors.supermarket,
                soft: SharedPlatformColors.supermarketSoft,
                onTap: onSupermarket,
                compact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.soft,
    required this.onTap,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color soft;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SharedPlatformColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: BoxConstraints(minHeight: compact ? 134 : 84),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: SharedPlatformColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_icon(), const SizedBox(height: 12), _labels()],
                )
              : Row(
                  children: [
                    _icon(),
                    const SizedBox(width: 14),
                    Expanded(child: _labels()),
                    const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: SharedPlatformColors.muted,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _icon() => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      color: soft,
      borderRadius: BorderRadius.circular(14),
    ),
    alignment: Alignment.center,
    child: Icon(icon, color: accent, size: 24),
  );

  Widget _labels() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: SharedPlatformColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: SharedPlatformColors.muted,
          fontSize: 11,
          height: 1.4,
        ),
      ),
    ],
  );
}
