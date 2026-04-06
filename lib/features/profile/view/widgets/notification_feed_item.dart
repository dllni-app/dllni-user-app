import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/fetch_notifications_model.dart';

class NotificationFeedItem extends StatefulWidget {
  const NotificationFeedItem({super.key, required this.notification});

  final FetchNotificationsModelDataItem notification;

  @override
  State<NotificationFeedItem> createState() => _NotificationFeedItemState();
}

class _NotificationFeedItemState extends State<NotificationFeedItem> {
  Color notificationStatusColor() {
    if (widget.notification.type == 'order') {
      return const Color(0xff10B981);
    } else if (widget.notification.type == 'inventory') {
      return const Color(0xffF59E0B);
    } else if (widget.notification.type == 'offers') {
      return const Color(0xffD97706);
    } else if (widget.notification.type == 'system') {
      return const Color(0xff6B7280);
    } else if (widget.notification.type == 'gift') {
      return const Color(0xffA855F7);
    } else if (widget.notification.type == 'alert') {
      return const Color(0xff3B82F6);
    } else if (widget.notification.type == 'safety') {
      return const Color(0xff059669);
    } else {
      return const Color(0xff6366F1);
    }
  }

  IconData notificationStatusIcon() {
    if (widget.notification.type == 'order') {
      return Icons.check_circle;
    } else if (widget.notification.type == 'inventory') {
      return Icons.two_wheeler;
    } else if (widget.notification.type == 'offers') {
      return Icons.local_offer;
    } else if (widget.notification.type == 'system') {
      return Icons.restaurant;
    } else if (widget.notification.type == 'gift') {
      return Icons.card_giftcard;
    } else if (widget.notification.type == 'alert') {
      return Icons.notifications_active;
    } else if (widget.notification.type == 'safety') {
      return Icons.shield_outlined;
    } else {
      return Icons.favorite;
    }
  }

  String _relativeTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) {
      return '';
    }

    final now = DateTime.now();
    final diff = now.difference(parsed.toLocal());

    if (diff.inMinutes < 1) {
      return 'الآن';
    }
    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    }
    if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    }
    if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} يوم';
    }
    return 'منذ أسبوع';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = notificationStatusColor();
    final isUnread = widget.notification.isRead != true;

    return Container(
      color: context.onPrimary,
      child: Stack(
        children: [
          if (widget.notification.showTrailingAccent)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(width: 3, color: context.primaryContainer),
            ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notificationStatusIcon(),
                    color: statusColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isUnread) ...[
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsetsDirectional.only(top: 7),
                              decoration: BoxDecoration(
                                color: context.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: AppText.bodyMedium(
                              widget.notification.title ?? '',
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      AppText.bodyMedium(
                        widget.notification.body ?? '',
                        color: const Color(0xFF4B5563),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 4),
                      AppText.labelLarge(
                        _relativeTime(widget.notification.createdAt),
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.start,
                      ),
                    ],
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
