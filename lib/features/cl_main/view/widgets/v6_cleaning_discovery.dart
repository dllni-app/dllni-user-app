import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// These are tab explanations, not booking steps or unbound mode selectors.
class V6CleaningDiscoveryIntro extends StatelessWidget {
  const V6CleaningDiscoveryIntro({super.key, required this.onBookApartment});
  final VoidCallback onBookApartment;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        key: const Key('pencil_cleaning_discovery_hero'),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppSection.cleaning.soft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AlnadhaTokens.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نظافة على مقاس بيتك',
                    style: AlnadhaTokens.title.copyWith(
                      color: AppSection.cleaning.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'اختَر المكان، وحدّد التنظيف المناسب لكل غرفة.',
                    style: AlnadhaTokens.body,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AlnadhaTokens.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 38,
                    color: AppSection.cleaning.accent,
                  ),
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    top: 7,
                    end: 8,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 17,
                      color: AppSection.cleaning.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const AppSectionHeading(
        title: 'وين بدك ننظّف؟',
        description: 'اختيار المكان يبدأ حجزك في 7 خطوات واضحة.',
      ),
      const SizedBox(height: 10),
    ],
  );
}

class V6CleaningOccasionIntro extends StatelessWidget {
  const V6CleaningOccasionIntro({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _TabInformation(
        icon: Icons.info_outline_rounded,
        title: 'متى تختار مساعدة في المناسبات؟',
        description:
            'عندما تستضيف ضيوفاً أو تنظم مناسبة وتحتاج فريقاً للمساعدة في التجهيز أو الضيافة أو الترتيب بعدها.',
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
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE4EE)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF2FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 21, color: AlnadhaTokens.primary),
          ),
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
