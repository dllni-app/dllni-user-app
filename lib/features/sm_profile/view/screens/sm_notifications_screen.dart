import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/fetch_notifications_model.dart';
import '../widgets/notification_feed_item.dart';

@AutoRoutePage(path: "/sm_notification")
class SmNotificationsScreen extends StatefulWidget {
  const SmNotificationsScreen({super.key});

  @override
  State<SmNotificationsScreen> createState() => _SmNotificationsScreenState();
}

class _SmNotificationsScreenState extends State<SmNotificationsScreen> {
  late List<FetchNotificationsModelDataItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _seedNotifications();
  }

  List<FetchNotificationsModelDataItem> _seedNotifications() {
    final now = DateTime.now();
    return [
      FetchNotificationsModelDataItem(
        type: 'order',
        title: 'تم استلام طلبك',
        body: 'تم استلام طلبك من مطعم البركة وجاري تجهيزه',
        createdAt: now.subtract(const Duration(minutes: 5)).toIso8601String(),
        isRead: false,
        showTrailingAccent: true,
      ),
      FetchNotificationsModelDataItem(
        type: 'inventory',
        title: 'طلبك في الطريق',
        body: 'السائق فؤاد إليك، الوصول المتوقع خلال 15 دقيقة',
        createdAt: now.subtract(const Duration(minutes: 20)).toIso8601String(),
        isRead: false,
        showTrailingAccent: true,
      ),
      FetchNotificationsModelDataItem(
        type: 'offers',
        title: 'عرض خاص بالقرب منك',
        body: 'خصم 20% على مطعم البيت الحلبي - صالح لغاية اليوم',
        createdAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
        isRead: false,
        showTrailingAccent: true,
      ),
      FetchNotificationsModelDataItem(
        type: 'order',
        title: 'طلبك أصبح جاهزاً للاستلام',
        body: 'يمكنك استلام طلبك الآن من مطعم الشام - رقم الطلب 4528',
        createdAt: now.subtract(const Duration(hours: 21)).toIso8601String(),
        isRead: true,
      ),
      FetchNotificationsModelDataItem(
        type: 'order',
        title: 'تم توصيل طلبك بنجاح',
        body: 'شكراً لطلبك! نتمنى أن تكون قد استمتعت بوجبتك',
        createdAt: now
            .subtract(const Duration(days: 1, hours: 2))
            .toIso8601String(),
        isRead: true,
      ),
      FetchNotificationsModelDataItem(
        type: 'gift',
        title: 'عرض خاص لك',
        body: 'احصل على توصيل مجاني على طلبك القادم - FREE2024',
        createdAt: now
            .subtract(const Duration(days: 1, hours: 5))
            .toIso8601String(),
        isRead: true,
      ),
      FetchNotificationsModelDataItem(
        type: 'alert',
        title: 'تحديث التطبيق',
        body: 'نسخة جديدة متاحة تتضمن تحسينات وتجربة أسرع',
        createdAt: now
            .subtract(const Duration(days: 2, hours: 4))
            .toIso8601String(),
        isRead: true,
      ),
      FetchNotificationsModelDataItem(
        type: 'system',
        title: 'مطاعم جديدة في منطقتك',
        body: 'اكتشف 5 مطاعم جديدة تم إضافتها مؤخراً هنا',
        createdAt: now.subtract(const Duration(days: 3)).toIso8601String(),
        isRead: true,
      ),
      FetchNotificationsModelDataItem(
        type: 'offers',
        title: 'عروض نهاية الأسبوع',
        body: 'خصومات تصل إلى 40% على مطاعم مختارة',
        createdAt: now.subtract(const Duration(days: 4)).toIso8601String(),
        isRead: true,
      ),
      FetchNotificationsModelDataItem(
        type: 'unknown',
        title: 'تحديث سياسة الخصوصية',
        body: 'تم تحديث سياسة الخصوصية لحسابك، ننصحك بالاطلاع عليها',
        createdAt: now.subtract(const Duration(days: 6)).toIso8601String(),
        isRead: true,
      ),
      FetchNotificationsModelDataItem(
        type: 'safety',
        title: 'إرشادات سلامة مهمة',
        body: 'نرجو اتباع إرشادات السلامة عند استلام الطلب',
        createdAt: now.subtract(const Duration(days: 7)).toIso8601String(),
        isRead: true,
      ),
    ];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _bucketLabel(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(local.year, local.month, local.day);

    if (_isSameDay(today, target)) return 'اليوم';
    if (_isSameDay(today.subtract(const Duration(days: 1)), target)) {
      return 'أمس';
    }
    if (today.difference(target).inDays <= 7) return 'الأسبوع الماضي';
    return 'الأقدم';
  }

  Map<String, List<FetchNotificationsModelDataItem>> _groupNotifications() {
    final grouped = <String, List<FetchNotificationsModelDataItem>>{
      'اليوم': [],
      'أمس': [],
      'الأسبوع الماضي': [],
      'الأقدم': [],
    };

    for (final item in _notifications) {
      final parsed = DateTime.tryParse(item.createdAt ?? '');
      if (parsed == null) continue;
      grouped[_bucketLabel(parsed)]!.add(item);
    }

    return grouped;
  }

  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map((item) => item.copyWith(isRead: true, showTrailingAccent: false))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupNotifications();
    final sections = ['اليوم', 'أمس', 'الأسبوع الماضي', 'الأقدم'];

    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _RsNotificationsAppBar(onReadAll: _markAllRead),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.only(top: 8, bottom: 16),
                children: [
                  for (final section in sections)
                    if (groups[section]!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          10,
                          16,
                          8,
                        ),
                        child: AppText.labelLarge(
                          section,
                          color: const Color(0xff9CA3AF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        color: context.onPrimary,
                        child: Column(
                          children: [
                            for (
                              var i = 0;
                              i < groups[section]!.length;
                              i++
                            ) ...[
                              NotificationFeedItem(
                                notification: groups[section]![i],
                              ),
                              if (i != groups[section]!.length - 1)
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xffF3F4F6),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RsNotificationsAppBar extends StatelessWidget {
  const _RsNotificationsAppBar({required this.onReadAll});

  final VoidCallback onReadAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: context.width,
      decoration: BoxDecoration(
        color: context.onPrimary,
        border: Border(
          bottom: BorderSide(color: context.primaryContainer, width: 2),
        ),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(14),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AppText.headlineMedium(
            'الإشعارات',
            color: context.primary,
            fontWeight: FontWeight.w700,
          ),
          PositionedDirectional(
            start: 12,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.pop(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.onPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffE5E7EB)),
                ),
                child: Icon(Icons.arrow_back, color: context.primary),
              ),
            ),
          ),
          PositionedDirectional(
            end: 12,
            child: ElevatedButton(
              onPressed: onReadAll,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xff6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
              ),
              child: AppText.labelLarge(
                'قراءة الكل',
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
