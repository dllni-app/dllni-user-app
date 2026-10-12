import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// Entry information, not a parallel booking wizard. Actual mode is chosen
/// after property selection and submitted by the existing booking BLoC.
class V6CleaningDiscoveryIntro extends StatelessWidget {
  const V6CleaningDiscoveryIntro({super.key, required this.onBookApartment});
  final VoidCallback onBookApartment;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('شو نوع التنظيف اللي تحتاجه؟', style: AlnadhaTokens.title),
      const SizedBox(height: 4),
      const Text(
        'اختر مكان الخدمة أولاً، وبعدها حدّد طريقة التنظيف والمهام.',
        style: AlnadhaTokens.caption,
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _ModeDescription(
              title: 'تنظيف عادي',
              subtitle: 'للعناية اليومية بالمنزل',
              icon: Icons.cleaning_services_outlined,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ModeDescription(
              title: 'تنظيف عميق',
              subtitle: 'تنظيف أدق وبمهام إضافية',
              icon: Icons.auto_awesome_outlined,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      AppActionButton(
        label: 'ابدأ حجز تنظيف شقة',
        variant: AppActionVariant.secondary,
        section: AppSection.cleaning,
        onPressed: onBookApartment,
      ),
      const SizedBox(height: 16),
      const AppSectionHeading(
        title: 'اختر نوع المكان',
        description: 'يمكنك تخصيص الخدمة في الخطوة التالية',
      ),
      const SizedBox(height: 10),
    ],
  );
}

class _ModeDescription extends StatelessWidget {
  const _ModeDescription({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    section: AppSection.cleaning,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppSection.cleaning.ink, size: 24),
        const SizedBox(height: 8),
        Text(
          title,
          style: AlnadhaTokens.body.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          subtitle,
          style: AlnadhaTokens.caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class V6CleaningOccasionIntro extends StatelessWidget {
  const V6CleaningOccasionIntro({super.key});
  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('مساعدة في المناسبات', style: AlnadhaTokens.title),
      SizedBox(height: 6),
      Text(
        'اختر المناسبة، ثم صف المهام وحدّد الوقت المناسب.',
        style: AlnadhaTokens.caption,
      ),
      SizedBox(height: 16),
    ],
  );
}
