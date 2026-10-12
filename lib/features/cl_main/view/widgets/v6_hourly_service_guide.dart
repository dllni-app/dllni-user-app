import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// Guidance only: no promise of specific worker skills, price or availability.
class V6HourlyServiceGuide extends StatelessWidget {
  const V6HourlyServiceGuide({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const AppSectionHeading(
        title: 'متى تختار عاملاً بالساعة؟',
        description:
            'إذا كنت تحتاج مساعدة لوقت محدد بدلاً من طلب تنظيف منزل كامل.',
      ),
      const SizedBox(height: 12),
      const _GuidePoint(
        icon: Icons.room_service_outlined,
        title: 'مهام منزلية محددة',
        description: 'عندما تريد وصف مهام بعينها وتحتاج مساعدة لإنجازها.',
      ),
      const SizedBox(height: 10),
      const _GuidePoint(
        icon: Icons.schedule_outlined,
        title: 'مدة تناسب احتياجك',
        description: 'عندما تفضّل تحديد عدد العمال والمدة المتوقعة قبل الحجز.',
      ),
      const SizedBox(height: 10),
      const _GuidePoint(
        icon: Icons.event_available_outlined,
        title: 'مساعدة في يوم مزدحم',
        description:
            'عندما تحتاج دعماً مؤقتاً في المنزل دون اختيار برنامج تنظيف كامل.',
      ),
      const SizedBox(height: 18),
      const AppSectionHeading(
        title: 'كيف يعمل الحجز؟',
        description: 'ثلاث خطوات بسيطة قبل تأكيد الطلب',
      ),
      const SizedBox(height: 12),
      const _GuideStep(
        number: '1',
        title: 'اختر الوقت وعدد العمال',
        description: 'حدّد الموعد والمدة التي تتوقع احتياجها.',
      ),
      const SizedBox(height: 10),
      const _GuideStep(
        number: '2',
        title: 'أضف العنوان ووصف المهام',
        description: 'اكتب المطلوب بوضوح ليكون ضمن تفاصيل الطلب.',
      ),
      const SizedBox(height: 10),
      const _GuideStep(
        number: '3',
        title: 'راجع تقدير التكلفة',
        description:
            'يظهر التقدير من النظام؛ ترتبط الفوترة النهائية بالمدة الفعلية المسجلة.',
      ),
      const SizedBox(height: 16),
      AppSurfaceCard(
        section: AppSection.cleaning,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: AppSection.cleaning.ink,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'متى أختار التنظيف العادي أو العميق؟',
                    style: AlnadhaTokens.sectionTitle,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'إذا أردت تنظيف غرف ومرافق المنزل وفق خدمة واضحة، اختر «التنظيفات». أما إذا كانت حاجتك لساعات ومهام محددة، فابدأ من «بالساعة».',
                    style: AlnadhaTokens.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}

class _GuidePoint extends StatelessWidget {
  const _GuidePoint({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppSection.cleaning.soft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppSection.cleaning.ink, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AlnadhaTokens.sectionTitle),
              Text(description, style: AlnadhaTokens.caption),
            ],
          ),
        ),
      ],
    ),
  );
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.title,
    required this.description,
  });
  final String number;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppSection.cleaning.soft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          number,
          style: AlnadhaTokens.body.copyWith(
            color: AppSection.cleaning.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AlnadhaTokens.body),
              Text(description, style: AlnadhaTokens.caption),
            ],
          ),
        ),
      ),
    ],
  );
}
