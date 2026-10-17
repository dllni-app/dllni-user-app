import 'package:flutter/material.dart';

import '../../../../core/widgets/design_system/design_system.dart';
import '../../../../core/widgets/support_whatsapp_launcher.dart';
import '../../domain/models/cleaning_room_size_breakdown.dart';

/// Illustrative advice only. These examples are not backend area thresholds or
/// promises of pricing; the existing quote API remains authoritative.
class RoomSizeGuidance {
  const RoomSizeGuidance({
    required this.roomName,
    required this.small,
    required this.medium,
    required this.large,
  });
  final String roomName;
  final String small;
  final String medium;
  final String large;

  String example(CleaningRoomSize size) => switch (size) {
    CleaningRoomSize.small => small,
    CleaningRoomSize.medium => medium,
    CleaningRoomSize.large => large,
  };

  static RoomSizeGuidance forType(CleaningRoomType type) => switch (type) {
    CleaningRoomType.bedroom => const RoomSizeGuidance(
      roomName: 'غرفة النوم',
      small: 'سرير مفرد وأثاث قليل مع مساحة حركة محدودة.',
      medium: 'سرير مزدوج وخزانة مع مساحة حركة اعتيادية.',
      large: 'غرفة واسعة مع جلسة أو قطع أثاث إضافية.',
    ),
    CleaningRoomType.bathroom => const RoomSizeGuidance(
      roomName: 'الحمام',
      small: 'مغسلة ومرحاض ومساحة حركة محدودة.',
      medium: 'تجهيزات حمام اعتيادية ودش أو حوض استحمام.',
      large: 'حمام واسع مع تجهيزات أو مناطق إضافية.',
    ),
    CleaningRoomType.kitchen => const RoomSizeGuidance(
      roomName: 'المطبخ',
      small: 'مطبخ صغير بخزائن وأسطح تحضير محدودة.',
      medium: 'مطبخ اعتيادي بعدة خزائن وأسطح عمل.',
      large: 'مطبخ واسع مع جزيرة أو مناطق تحضير إضافية.',
    ),
    CleaningRoomType.livingRoom => const RoomSizeGuidance(
      roomName: 'غرفة المعيشة',
      small: 'جلسة صغيرة بعدد قليل من قطع الأثاث.',
      medium: 'أريكة وطاولة مع مساحة حركة اعتيادية.',
      large: 'صالة واسعة بعدة جلسات أو أثاث كثير.',
    ),
    CleaningRoomType.balcony => const RoomSizeGuidance(
      roomName: 'البلكونة',
      small: 'شرفة ضيقة مع مساحة أرضية محدودة.',
      medium: 'شرفة اعتيادية تتسع لكرسيين وطاولة.',
      large: 'تراس واسع مع جلسة أو أثاث خارجي إضافي.',
    ),
    CleaningRoomType.corridor => const RoomSizeGuidance(
      roomName: 'الموزع أو الممر',
      small: 'ممر قصير وضيق.',
      medium: 'ممر اعتيادي يصل بين عدة غرف.',
      large: 'مساحة توزيع واسعة أو ممر طويل.',
    ),
    CleaningRoomType.shed => const RoomSizeGuidance(
      roomName: 'السقيفة',
      small: 'مساحة تخزين صغيرة بأغراض قليلة.',
      medium: 'مكان تخزين اعتيادي بعدة رفوف وأغراض.',
      large: 'مساحة تخزين واسعة بأغراض كثيرة.',
    ),
    _ => const RoomSizeGuidance(
      roomName: 'الغرفة',
      small: 'مساحة صغيرة ذات أثاث وتجهيزات قليلة.',
      medium: 'مساحة متوسطة ذات استخدام اعتيادي.',
      large: 'مساحة واسعة أو ذات تجهيزات متعددة.',
    ),
  };
}

String roomSizeArabic(CleaningRoomSize size) => switch (size) {
  CleaningRoomSize.small => 'صغيرة',
  CleaningRoomSize.medium => 'متوسطة',
  CleaningRoomSize.large => 'كبيرة',
};

class V6RoomSizeIntro extends StatelessWidget {
  const V6RoomSizeIntro({super.key, required this.onHelp});
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    section: AppSection.cleaning,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.tips_and_updates_outlined,
          size: 25,
          color: AppSection.cleaning.ink,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'كيف أحدد حجم الغرفة؟',
                style: AlnadhaTokens.sectionTitle,
              ),
              const SizedBox(height: 5),
              const Text(
                'قارن المساحة المتاحة للحركة وعدد قطع الأثاث. اختر الأقرب إلى غرفتك، وليس بالضرورة قياساً دقيقاً.',
                style: AlnadhaTokens.caption,
              ),
              const SizedBox(height: 6),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: onHelp,
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: const Text('لست متأكداً؟ شاهد أمثلة'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Three short, contextual examples fill useful space under the booking cards.
class _ExampleRow extends StatelessWidget {
  const _ExampleRow({required this.size, required this.text});
  final CleaningRoomSize size;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        switch (size) {
          CleaningRoomSize.small => Icons.crop_square_outlined,
          CleaningRoomSize.medium => Icons.crop_5_4_outlined,
          CleaningRoomSize.large => Icons.aspect_ratio_outlined,
        },
        color: AppSection.cleaning.ink,
        size: 23,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(roomSizeArabic(size), style: AlnadhaTokens.body),
            Text(text, style: AlnadhaTokens.caption),
          ],
        ),
      ),
    ],
  );
}

/// Allows room-specific help while leaving the in-progress wizard underneath.
class V6RoomSizeHelpSheet extends StatelessWidget {
  const V6RoomSizeHelpSheet({super.key, required this.roomType});
  final CleaningRoomType roomType;

  static Future<void> show(BuildContext context, CleaningRoomType type) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => V6RoomSizeHelpSheet(roomType: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guide = RoomSizeGuidance.forType(roomType);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .82,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 6, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'كيف أختار حجم ${guide.roomName}؟',
              style: AlnadhaTokens.title,
            ),
            const SizedBox(height: 7),
            const Text(
              'استعن بالأمثلة التالية بحسب مساحة الحركة والأثاث. هي تقريبية وليست قياسات متر مربع معتمدة.',
              style: AlnadhaTokens.caption,
            ),
            const SizedBox(height: 18),
            for (final size in CleaningRoomSize.values) ...[
              AppSurfaceCard(
                section: AppSection.cleaning,
                child: _ExampleRow(size: size, text: guide.example(size)),
              ),
              const SizedBox(height: 10),
            ],
            const Text(
              'إذا كنت محتاراً، اختر الحجم الأقرب. يمكنك الرجوع وتغيير اختيارك قبل إرسال الطلب.',
              style: AlnadhaTokens.caption,
            ),
            const SizedBox(height: 12),
            const Text(
              'إذا لم تتأكد من الاختيار، تواصل مع الدعم الفني لنساعدك في اختيار الأنسب.',
              style: AlnadhaTokens.caption,
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const Key('room_size_contact_support'),
                onPressed: () => launchSupportWhatsApp(context),
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('تواصل مع الدعم الفني'),
              ),
            ),
            const SizedBox(height: 12),
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
