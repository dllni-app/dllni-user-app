import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// V6 service discovery composition. Historic keys remain stable for routes/tests.
/// No independent business logic is introduced; callbacks are provided by Home.
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const AppSectionHeading(
        title: 'الخدمات',
        description: 'اختر الخدمة التي تحتاجها',
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _ServiceEntry(
              key: const Key('platform_home_v5_cleaning_tile'),
              section: AppSection.cleaning,
              icon: Icons.cleaning_services_outlined,
              title: 'التنظيفات',
              detail: 'تنظيف منزلك ومناسباتك',
              onTap: onCleaning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ServiceEntry(
              key: const Key('platform_home_v5_restaurants_tile'),
              section: AppSection.restaurant,
              icon: Icons.restaurant_outlined,
              title: 'المطاعم',
              detail: 'اطلب وجبتك المفضلة',
              onTap: onRestaurants,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _ServiceEntry(
              key: const Key('platform_home_v5_supermarket_tile'),
              section: AppSection.supermarket,
              icon: Icons.shopping_cart_outlined,
              title: 'السوبرماركت',
              detail: 'تسوّق احتياجاتك',
              onTap: onSupermarket,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ServiceEntry(
              key: const Key('platform_home_v7_delivery_tile'),
              section: AppSection.delivery,
              icon: Icons.local_shipping_outlined,
              title: 'التوصيل',
              detail: 'أرسل واستقبل بسرعة',
              onTap: onDelivery,
            ),
          ),
        ],
      ),
    ],
  );
}

class _ServiceEntry extends StatelessWidget {
  const _ServiceEntry({
    super.key,
    required this.section,
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });
  final AppSection section;
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    enabled: onTap != null,
    label: '$title، $detail',
    child: Opacity(
      opacity: onTap == null ? .55 : 1,
      child: AppSurfaceCard(
        section: section,
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 106),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: section.soft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 21, color: section.ink),
              ),
              const SizedBox(height: 9),
              Text(
                title,
                style: AlnadhaTokens.body.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AlnadhaTokens.caption,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
