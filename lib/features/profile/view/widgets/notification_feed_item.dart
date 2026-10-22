import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../data/models/fetch_notifications_model.dart';

/// One V7 notification row; all event identity and links are backend-owned.
class NotificationFeedItem extends StatelessWidget {
  const NotificationFeedItem({super.key, required this.notification});
  final FetchNotificationsModelDataItem notification;

  static String _category(FetchNotificationsModelDataItem n) {
    final category = (n.category ?? '').trim().toLowerCase();
    if (category.isNotEmpty) return category;
    final type = n.type.trim().toLowerCase();
    if (type.contains('offer')) return 'offers';
    if (type.contains('order') || type.contains('booking')) return 'orders';
    return 'system';
  }

  Color notificationStatusColor() => switch (_category(notification)) {
    'orders' => const Color(0xFF087D88),
    'offers' => const Color(0xFF97601B),
    'system' => const Color(0xFF475467),
    _ => const Color(0xFF5164B5),
  };
  IconData notificationStatusIcon() => switch (_category(notification)) {
    'orders' => Icons.receipt_long_outlined,
    'offers' => Icons.local_offer_outlined,
    'system' => Icons.info_outline,
    _ => Icons.notifications_none_outlined,
  };
  String _body() {
    final canonical = (notification.canonicalType ?? '').trim().toLowerCase();
    final type = notification.type.trim().toLowerCase();
    if (canonical == 'cleaning.booking.time_extension_rejected' ||
        type == 'time_extension_rejected') {
      for (final key in const [
        'workerRejectMessage',
        'worker_reject_message',
        'message',
      ]) {
        final value = notification.data?[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return 'رد العامل: $value';
      }
    }
    return notification.body ?? '';
  }

  String _time(String? at) {
    if (at == null || at.isEmpty) return '';
    final date = DateTime.tryParse(at);
    if (date == null) return '';
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.isNegative || diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    }
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return 'منذ أسبوع';
  }

  Widget _icon() {
    final url = (notification.icon ?? '').trim();
    final fallback = Icon(
      notificationStatusIcon(),
      color: notificationStatusColor(),
      size: 24,
    );
    if (url.isEmpty) return fallback;
    if (url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        url,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => fallback,
      );
    }
    return Image.network(
      url,
      width: 25,
      height: 25,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => fallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = notification.isRead != true;
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFE9F9FA) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unread ? const Color(0xFF9DDCDF) : const Color(0xFFE6EAF0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: _icon(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title ?? 'إشعار',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SharedPlatformColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF09A9B6),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _body(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SharedPlatformColors.muted,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _time(notification.createdAt),
                  style: const TextStyle(
                    color: SharedPlatformColors.muted,
                    fontSize: 11,
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
