import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

/// Used only when there are no server-managed cleaning banners.
/// The button delegates navigation/auth to the parent screen.
class ClCleaningLandingHero extends StatelessWidget {
  const ClCleaningLandingHero({super.key, required this.onBookApartment});

  final VoidCallback onBookApartment;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('cl_cleaning_landing_fallback_hero'),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF122044), SharedPlatformColors.primary],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cleaning_services_outlined,
                size: 19,
                color: SharedPlatformColors.cleaning,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ع الندهة • التنظيفات',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            'بيتك أنظف، ووقتك إلك',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'اختر المكان وخصص تفاصيل الخدمة والموعد المناسب لك.',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.83),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              key: const Key('cl_cleaning_hero_apartment_booking'),
              onPressed: onBookApartment,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('احجز تنظيف شقة'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: SharedPlatformColors.primary,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
