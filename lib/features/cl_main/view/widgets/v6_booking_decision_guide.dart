import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';
import '../../../../core/widgets/support_whatsapp_launcher.dart';

/// Small contextual guidance; never decides price, eligibility, or availability.
enum V6BookingDecisionTopic {
  cleaningType,
  appointment,
  recurrence,
  tasksAndExtras,
  teamSelection,
  bookingReview,
  eventRequirements,
  eventSchedule,
  hourlyDuration,
}

class V6DecisionCopy {
  const V6DecisionCopy(this.title, this.summary, this.examples);
  final String title;
  final String summary;
  final List<String> examples;

  static V6DecisionCopy forTopic(
    V6BookingDecisionTopic topic,
  ) => switch (topic) {
    V6BookingDecisionTopic.cleaningType => const V6DecisionCopy(
      'أي نوع تنظيف يناسبك؟',
      'العادي للعناية المعتادة، والعميق عندما تحتاج عناية أشمل وتفاصيل أكثر.',
      [
        'اختر التنظيف العادي إذا كانت حاجتك إلى المهام المنزلية المعتادة.',
        'اختر التنظيف العميق إذا كانت المساحات تحتاج تنظيفاً تفصيلياً أكبر.',
        'راجع الخدمات المضمنة والتقدير قبل الإرسال، فقد تختلف المهام والتكلفة.',
      ],
    ),
    V6BookingDecisionTopic.appointment => const V6DecisionCopy(
      'كيف أختار الموعد؟',
      'اختر اليوم ووقت بدء الخدمة عندما يمكن استقبال العامل في العنوان المحدد.',
      [
        'راجع إمكانية وجود شخص لاستقبال مقدم الخدمة في الوقت المختار.',
        'تأكد من عنوان المنزل والموقع على الخريطة قبل المتابعة.',
        'إذا كنت تحتاج زيارات متعددة، راجع خيار الحجز الدوري وشروطه.',
      ],
    ),
    V6BookingDecisionTopic.recurrence => const V6DecisionCopy(
      'زيارة واحدة أم حجز دوري؟',
      'اختر الدوري فقط إذا كنت بحاجة لزيارات متكررة، وحدّد تواريخها بدقة.',
      [
        'زيارة واحدة تناسب الطلب الذي ترغب بتنفيذه في موعد واحد.',
        'الحجز الدوري يناسب المهام التي تتكرر أسبوعياً أو في أيام مختلفة.',
        'راجع عدد الزيارات والمواعيد وطريقة حساب كل زيارة قبل التأكيد.',
      ],
    ),
    V6BookingDecisionTopic.tasksAndExtras => const V6DecisionCopy(
      'كيف أحدد المهام والإضافات؟',
      'حدّد فقط الأعمال والمواد التي تحتاجها فعلاً؛ قد يتغيّر السعر بحسب الإضافات.',
      [
        'اختر المهام الظاهرة التي ترغب من العامل إنجازها.',
        'اكتب مهمة خاصة إذا لم تجدها ضمن الخيارات المتاحة.',
        'أضف المواد أو الخدمات الخاصة فقط عند الحاجة وراجع تقدير التكلفة المحدث.',
      ],
    ),
    V6BookingDecisionTopic.teamSelection => const V6DecisionCopy(
      'كيف أختار العمال؟',
      'يمكنك اختيار عدد العمال أو تفضيل عامل سابق حسب الخيارات المتاحة.',
      [
        'عدد العمال المناسب يعتمد على حجم المهام والوقت؛ راجع الحد الأدنى المعروض من النظام.',
        'إذا جرّبت عاملاً من قبل وتفضّل التعامل معه، استخدم خيار العامل المفضل عند توفره.',
        'اختيار العامل أو العاملة يتبع التفضيل المدعوم؛ القبول والتوفر يؤكدهما النظام.',
      ],
    ),
    V6BookingDecisionTopic.bookingReview => const V6DecisionCopy(
      'ماذا أراجع قبل تأكيد الطلب؟',
      'راجع العنوان والموعد والمهام والعمال وتقدير التكلفة قبل الإرسال.',
      [
        'تحقق من ملخص الغرف أو المناسبة وعدد الزيارات.',
        'راجع الإضافات والكوبون وصحة السعر المعروض، فهو صادر من الخادم.',
        'الدفع نقدي عند إتمام الخدمة؛ إذا تغيّرت تفاصيل الطلب راجع التقدير مجدداً.',
      ],
    ),
    V6BookingDecisionTopic.eventRequirements => const V6DecisionCopy(
      'كيف أحدد احتياجات المناسبة؟',
      'ابدأ بعدد الضيوف والمهام وساعات المساعدة المتوقعة، ثم أضف متطلباتك الخاصة.',
      [
        'احسب الضيوف المتوقع حضورهم لتوضيح حجم المناسبة.',
        'اكتب طبيعة المساعدة بشكل محدد بدلاً من وصف عام.',
        'اختر الساعات وعدد العمال، وراجع الحد الأدنى والتحقق من النظام قبل المتابعة.',
      ],
    ),
    V6BookingDecisionTopic.eventSchedule => const V6DecisionCopy(
      'كيف أنظم أيام المناسبة؟',
      'حدّد يوم ووقت كل جلسة، ثم راجع العدد الإجمالي للساعات والعمال.',
      [
        'أضف فقط الأيام التي تحتاج فيها إلى مساعدة فعلية.',
        'راجع بداية كل جلسة ومدتها حتى لا تتداخل المواعيد.',
        'تأكد من إجمالي الجلسات والفاتورة التقديرية قبل تأكيد المناسبة.',
      ],
    ),
    V6BookingDecisionTopic.hourlyDuration => const V6DecisionCopy(
      'كيف أقدّر عدد العمال والمدة؟',
      'اختر وقت البدء وعدد العمال والحد المتوقع، مع شرح الأعمال في الوصف.',
      [
        'إذا كانت المهام قليلة ومحددة، ابدأ بعدد عمال يناسبها.',
        'اكتب وصفاً واضحاً كي يعرف العامل المطلوب عند وصوله.',
        'التقدير الأولي مختلف عن الفوترة النهائية التي تعتمد على مدة العمل المسجلة.',
      ],
    ),
  };
}

/// One short card at the decision point; examples only inside a bottom sheet.
class V6BookingDecisionGuide extends StatelessWidget {
  const V6BookingDecisionGuide({super.key, required this.topic});
  final V6BookingDecisionTopic topic;

  @override
  Widget build(BuildContext context) {
    final copy = V6DecisionCopy.forTopic(topic);
    return AppSurfaceCard(
      section: AppSection.cleaning,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tips_and_updates_outlined, color: AppSection.cleaning.ink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(copy.title, style: AlnadhaTokens.sectionTitle),
                const SizedBox(height: 4),
                Text(copy.summary, style: AlnadhaTokens.caption),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () =>
                        V6BookingDecisionHelpSheet.show(context, topic),
                    icon: const Icon(Icons.help_outline, size: 18),
                    label: const Text('لست متأكداً؟'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class V6BookingDecisionHelpSheet extends StatelessWidget {
  const V6BookingDecisionHelpSheet({super.key, required this.topic});
  final V6BookingDecisionTopic topic;

  static Future<void> show(BuildContext context, V6BookingDecisionTopic topic) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => V6BookingDecisionHelpSheet(topic: topic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = V6DecisionCopy.forTopic(topic);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .83,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(copy.title, style: AlnadhaTokens.title),
            const SizedBox(height: 8),
            Text(copy.summary, style: AlnadhaTokens.body),
            const SizedBox(height: 14),
            for (var i = 0; i < copy.examples.length; i++) ...[
              AppSurfaceCard(
                section: AppSection.cleaning,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 22,
                      color: AppSection.cleaning.ink,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(copy.examples[i], style: AlnadhaTokens.body),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
            ],
            const SizedBox(height: 12),
            const Text(
              'إذا لم تتأكد من الاختيار، تواصل مع الدعم الفني لنساعدك على اختيار الأنسب.',
              style: AlnadhaTokens.caption,
            ),
            TextButton.icon(
              key: const Key('booking_decision_contact_support'),
              onPressed: () => launchSupportWhatsApp(context),
              icon: const Icon(Icons.support_agent_outlined),
              label: const Text('تواصل مع الدعم الفني'),
            ),
            const SizedBox(height: 10),
            AppActionButton(
              label: 'فهمت',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
