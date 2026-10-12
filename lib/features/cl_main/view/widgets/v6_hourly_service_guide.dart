import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// Only explains when to choose this tab, not how booking is performed.
class V6HourlyServiceGuide extends StatelessWidget {
  const V6HourlyServiceGuide({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppSectionHeading(
        title: 'متى تختار عاملاً بالساعة؟',
        description:
            'عندما تكون حاجتك مساعدة منزلية مؤقتة في مهام محددة، ولا تحتاج طلب تنظيف شامل.',
      ),
      SizedBox(height: 12),
      _HourUseCase(
        icon: Icons.home_repair_service_outlined,
        title: 'ترتيب أو تنظيم المنزل',
        description:
            'لمساعدتك في ترتيب الأغراض أو تنظيم مساحة قبل استقبال الضيوف.',
      ),
      SizedBox(height: 10),
      _HourUseCase(
        icon: Icons.inventory_2_outlined,
        title: 'مهام خفيفة ومتنوعة',
        description: 'عند وجود عدة أعمال خفيفة تريد تنفيذها خلال زيارة واحدة.',
      ),
      SizedBox(height: 10),
      _HourUseCase(
        icon: Icons.access_time_rounded,
        title: 'حاجة مؤقتة بمدة غير محسومة',
        description:
            'عندما تعرف موعد البدء، لكن المدة الفعلية ستتضح أثناء العمل.',
      ),
      SizedBox(height: 22),
    ],
  );
}

class _HourUseCase extends StatelessWidget {
  const _HourUseCase({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    section: AppSection.cleaning,
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppSection.cleaning.soft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 24, color: AppSection.cleaning.ink),
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
  );
}
