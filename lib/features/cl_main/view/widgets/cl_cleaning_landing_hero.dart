import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/themes/v7_artwork.dart';

/// Promotional editorial fallback, shown only if no admin-managed banners exist.
class ClCleaningLandingHero extends StatelessWidget {
  const ClCleaningLandingHero({super.key, required this.onBookApartment});
  final VoidCallback onBookApartment;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: const Key('cl_cleaning_landing_fallback_hero'),
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: double.infinity,
        height: 212,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(V7Artwork.cleaningPhoto, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xE6172554),
                    Color(0xA6172554),
                    Color(0x11172554),
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
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ع الندهة • التنظيفات',
                        style: TextStyle(
                          color: Color(0xFF8DE4E8),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                      const SizedBox(height: 5),
                      const Text(
                        'حدد المكان والخدمة والموعد الذي يناسبك.',
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        key: const Key('cl_cleaning_hero_apartment_booking'),
                        onPressed: onBookApartment,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('ابدأ طلب تنظيف'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: SharedPlatformColors.primary,
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
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
    );
  }
}
