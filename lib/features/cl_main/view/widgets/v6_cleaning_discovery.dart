import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// These are tab explanations, not booking steps or unbound mode selectors.
class V6CleaningDiscoveryIntro extends StatelessWidget {
  const V6CleaningDiscoveryIntro({super.key, required this.onBookApartment});
  final VoidCallback onBookApartment;

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppSectionHeading(
        title: 'متى تختار التنظيفات؟',
        description:
            'عندما تحتاج تنظيف غرف ومرافق المنزل أو المكتب، سواء للعناية المعتادة أو لتنظيف شامل.',
      ),
      SizedBox(height: 12),
      _TabInformation(
        icon: Icons.home_work_outlined,
        title: 'مكان يحتاج عناية',
        description:
            'منزل أو مكتب يحتاج تنظيف الغرف والمرافق، لا مجرد مهمة واحدة بالساعة.',
      ),
      SizedBox(height: 18),
      AppSectionHeading(
        title: 'مكان الخدمة',
        description: 'اختر المكان الذي تريد تنظيفه',
      ),
      SizedBox(height: 10),
    ],
  );
}

class V6CleaningOccasionIntro extends StatelessWidget {
  const V6CleaningOccasionIntro({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppSectionHeading(
        title: 'متى تختار مساعدة في المناسبات؟',
        description:
            'عندما تستضيف ضيوفاً أو تنظم مناسبة وتحتاج فريقاً للمساعدة في التجهيز أو الضيافة أو الترتيب بعدها.',
      ),
      SizedBox(height: 12),
      _TabInformation(
        icon: Icons.celebration_outlined,
        title: 'مناسبتك تحتاج فريقاً',
        description:
            'مناسبة في يوم واحد أو عدة أيام، مع مهام وأوقات يختلف احتياجها من جلسة لأخرى.',
      ),
      SizedBox(height: 18),
      AppSectionHeading(
        title: 'اختر المناسبة',
        description: 'اختر المناسبة الأقرب إلى احتياجك',
      ),
      SizedBox(height: 10),
    ],
  );
}

class _TabInformation extends StatelessWidget {
  const _TabInformation({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AlnadhaTokens.primary.withValues(alpha: .045),
        border: Border.all(color: AlnadhaTokens.primary.withValues(alpha: .13)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: AlnadhaTokens.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AlnadhaTokens.sectionTitle),
                const SizedBox(height: 4),
                Text(description, style: AlnadhaTokens.caption),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
