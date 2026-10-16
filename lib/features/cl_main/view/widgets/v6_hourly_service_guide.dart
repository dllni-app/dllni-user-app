import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// Only explains when to choose this tab, not how booking is performed.
class V6HourlyServiceGuide extends StatelessWidget {
  const V6HourlyServiceGuide({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _HourlyInformation(),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(4, 9, 4, 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 23, color: const Color(0xFF354E7D)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AlnadhaTokens.sectionTitle),
              const SizedBox(height: 3),
              Text(description, style: AlnadhaTokens.caption),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HourlyInformation extends StatelessWidget {
  const _HourlyInformation();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFDCE4EE)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline_rounded, color: Color(0xFF172554)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'متى تختار عاملاً بالساعة؟',
                style: AlnadhaTokens.sectionTitle,
              ),
              const SizedBox(height: 5),
              Text(
                'عندما تكون حاجتك مساعدة منزلية مؤقتة في مهام محددة، ولا تحتاج طلب تنظيف شامل.',
                style: AlnadhaTokens.caption,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
