import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';
import '../../../../core/widgets/support_whatsapp_launcher.dart';

/// Decision guidance only. Server continues to own prices, eligibility, and limits.
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
      'أي مستوى تنظيف أحتاج؟',
      'اختر بحسب حالة المنزل، لا بحسب عدد الغرف فقط.',
      [
        'العادي: عندما يكون المنزل معتنى به ويحتاج تنظيفاً معتاداً.',
        'العميق: عند تراكم الأوساخ أو الحاجة لتنظيف تفصيلي بعد فترة طويلة.',
        'إذا كانت الحاجة مهمة محددة فقط، راجع العامل بالساعة بدلاً من تنظيف كامل.',
      ],
    ),
    V6BookingDecisionTopic.appointment => const V6DecisionCopy(
      'أي موعد يناسبك؟',
      'اختر وقتاً يمكنك فيه استقبال العامل وبدء الخدمة.',
      [
        'اختر وقتاً تستطيع فيه فتح المكان واستقبال العامل.',
        'اترك وقتاً كافياً للمهام التي حددتها ولا تفترض انتهاءها في موعد ثابت.',
      ],
    ),
    V6BookingDecisionTopic.recurrence => const V6DecisionCopy(
      'هل أحتاج زيارات متكررة؟',
      'الحجز الدوري مخصص لحاجة تنظيف تتكرر، مو لمجرد اختيار يوم آخر.',
      [
        'زيارة واحدة: لتنظيف المنزل مرة واحدة.',
        'دوري: لزيارات تتكرر يومياً أو أسبوعياً أو شهرياً، أو بتواريخ تحددها.',
        'يمكن أن يختلف العامل بين الزيارات؛ لكل زيارة موعد وتغطية مستقلة.',
      ],
    ),
    V6BookingDecisionTopic.tasksAndExtras => const V6DecisionCopy(
      'متى أضيف خدمات إضافية؟',
      'أضف فقط ما تحتاجه خارج نطاق التنظيف الذي اخترته.',
      [
        'أضف توفير مواد التنظيف إذا لم تتوفر المواد المناسبة لديك.',
        'اختر خدمة خاصة عند الحاجة إلى مهمة متخصصة وليست تنظيفاً معتاداً.',
        'اكتب مهمة خاصة في وصف الطلب إذا كانت متاحة ضمن نوع الحجز؛ راجع التكلفة قبل التأكيد.',
      ],
    ),
    V6BookingDecisionTopic.teamSelection => const V6DecisionCopy(
      'كم عاملاً أحتاج؟',
      'حدد العدد بحسب حجم المهام والوقت المتاح، لا بحسب عدد الضيوف وحده.',
      [
        'عامل واحد مناسب عادةً لمجموعة مهام محدودة يمكن لشخص واحد إنجازها.',
        'عاملان أو أكثر عندما تحتاج تنفيذ مهام متزامنة في أماكن مختلفة.',
        'قد يفرض النظام حداً أدنى بسبب مدة الجلسة أو التغطية؛ راجع العدد المسموح قبل المتابعة.',
      ],
    ),
    V6BookingDecisionTopic.bookingReview => const V6DecisionCopy(
      'هل تفاصيل الطلب صحيحة؟',
      'راجع فقط القرارات التي تؤثر في التنفيذ أو السعر قبل الإرسال.',
      [
        'راجع المهام وعدد العمال وعنوان التنفيذ.',
        'تحقق من الأيام والمواعيد والتقدير الصادر من النظام.',
        'إذا غيّرت أحد الخيارات، راجع السعر الجديد قبل تأكيد الطلب.',
      ],
    ),
    V6BookingDecisionTopic.eventRequirements => const V6DecisionCopy(
      'كم عاملاً وكم ساعة أحتاج للمناسبة؟',
      'قدّر العمل المطلوب في كل جلسة، ثم وزّعه بحسب ما يمكن إنجازه بالتوازي.',
      [
        'حدد المهام: تجهيز المكان، خدمة الضيوف، أو الترتيب بعد المناسبة؛ فلكل مهمة وقت مختلف.',
        'إذا احتجت مهمتين في الوقت نفسه وفي مكانين مختلفين فقد تحتاج عاملين، حتى لو كانت المناسبة قصيرة.',
        'إذا امتدت الجلسة لأكثر من 8 ساعات، فالنظام يطلب أكثر من عامل لتغطية المدة ضمن حد عمل العامل اليومي؛ راجع عدد العمال المسموح.',
      ],
    ),
    V6BookingDecisionTopic.eventSchedule => const V6DecisionCopy(
      'كيف أختار أيام المناسبة؟',
      'حدد الأيام التي ستحتاج فيها مساعدة بالفعل، ولكل يوم وقت ومدة مستقلان.',
      [
        'إن احتجت تجهيز المكان قبل المناسبة، أضف يوم التجهيز ضمن المواعيد.',
        'يمكن أن يختلف وقت البدء والمدة بين يوم وآخر.',
        'راجع عدد العمال لكل يوم؛ فتوفرهم لا يُضمن تلقائياً لجميع الجلسات.',
      ],
    ),
    V6BookingDecisionTopic.hourlyDuration => const V6DecisionCopy(
      'كيف أقدّر عدد العمال والمدة؟',
      'فكّر في المهام التي ستُنجز معاً، ثم اختر سقفاً زمنياً يكفيها.',
      [
        'عامل واحد يناسب المهام القليلة والمتتابعة، مثل ترتيب غرفة ونقل أغراض خفيفة.',
        'اختر أكثر من عامل إذا كانت هناك مهام متزامنة أو حجم عمل لا يناسب شخصاً واحداً.',
        'المدة المختارة تحجز الوقت المتوقع في جدول العامل، وليست فاتورة نهائية: المحاسبة تبدأ بحد أدنى ساعة ثم تقرّب إلى 15 دقيقة وفق الوقت الفعلي.',
      ],
    ),
  };
}

/// A visibly non-interactive information block. Only the help link is actionable.
class V6BookingDecisionGuide extends StatelessWidget {
  const V6BookingDecisionGuide({super.key, required this.topic});
  final V6BookingDecisionTopic topic;

  @override
  Widget build(BuildContext context) {
    final copy = V6DecisionCopy.forTopic(topic);
    return Semantics(
      container: true,
      child: Container(
        key: Key('decision_info_${topic.name}'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AlnadhaTokens.primary.withValues(alpha: .045),
          border: Border.all(
            color: AlnadhaTokens.primary.withValues(alpha: .13),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.lightbulb_outline_rounded,
              size: 23,
              color: AlnadhaTokens.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(copy.title, style: AlnadhaTokens.sectionTitle),
                  const SizedBox(height: 6),
                  Text(
                    copy.summary,
                    style: AlnadhaTokens.body.copyWith(
                      color: AlnadhaTokens.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () =>
                          V6BookingDecisionHelpSheet.show(context, topic),
                      icon: const Icon(Icons.help_outline_rounded, size: 18),
                      label: const Text('لست متأكداً؟'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      backgroundColor: AlnadhaTokens.surface,
      builder: (_) => V6BookingDecisionHelpSheet(topic: topic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = V6DecisionCopy.forTopic(topic);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .84,
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
            const SizedBox(height: 16),
            for (var i = 0; i < copy.examples.length; i++) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AlnadhaTokens.background,
                  border: Border.all(color: AlnadhaTokens.border),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 20,
                      color: AlnadhaTokens.primary,
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
            const SizedBox(height: 10),
            const Text(
              'لم تتأكد من الاختيار؟ يمكن للدعم مساعدتك في تحديد احتياجك.',
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
