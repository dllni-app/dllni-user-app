import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';
import '../../data/models/orders_api_models.dart';

enum MerchantOrderKind { restaurant, supermarket }

class MerchantOrderSummaryCard extends StatelessWidget {
  const MerchantOrderSummaryCard({
    super.key,
    required this.order,
    required this.kind,
    required this.onTap,
    this.onTrack,
  });

  final OrderResourceModel order;
  final MerchantOrderKind kind;
  final VoidCallback onTap;
  final VoidCallback? onTrack;

  bool get _isRestaurant => kind == MerchantOrderKind.restaurant;

  bool get _isDelivery =>
      (order.fulfillment?.type ?? '').toLowerCase() == 'delivery' ||
      order.deliveryOrderId != null ||
      order.deliverySummary?.enabled == true;

  bool get _isScheduled => (order.fulfillment?.receiveMode ?? '')
      .toLowerCase()
      .contains('scheduled');

  String get _categoryLabel => _isRestaurant ? 'مطعم' : 'سوبرماركت';

  IconData get _categoryIcon =>
      _isRestaurant ? Icons.restaurant_rounded : Icons.shopping_cart_outlined;

  String get _note {
    for (final item in order.items) {
      final note = item.note?.trim();
      if (note != null && note.isNotEmpty) return note;
    }
    return 'لا توجد ملاحظات';
  }

  String get _statusLabel {
    final status = (order.status ?? '').toLowerCase().trim();
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'accepted':
        return 'تم القبول';
      case 'preparing':
        return 'قيد التحضير';
      case 'ready_for_pickup':
        return 'جاهز للاستلام';
      case 'picked_up':
        return 'تم الاستلام';
      case 'delivered':
        return 'تم التوصيل';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
      case 'canceled':
        return 'ملغي';
      case 'rejected':
        return 'مرفوض';
      case 'processing':
        return 'قيد المعالجة';
      default:
        final label = order.statusLabel?.trim();
        if (label != null && label.isNotEmpty) return label;
        return status.isEmpty ? 'قيد المعالجة' : status;
    }
  }

  Color get _statusColor {
    final status = (order.status ?? '').toLowerCase().trim();
    if (status == 'completed' || status == 'delivered') {
      return const Color(0xFF159447);
    }
    if (status == 'cancelled' || status == 'canceled' || status == 'rejected') {
      return const Color(0xFFD14343);
    }
    if (status == 'pending' || status == 'preparing') {
      return AppColors.accent;
    }
    return AppColors.primary;
  }

  String _money(double value) {
    final amount = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '$amount ل.س';
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _dateLabel(String? value) {
    final date = _parseDate(value);
    if (date == null) return '—';
    return '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}';
  }

  String _timeLabel(String? value) {
    final date = _parseDate(value);
    if (date == null) return '—';
    return '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  String _scheduledLabel() {
    if (!_isScheduled) return 'فوري';
    final scheduledAt = order.fulfillment?.scheduledAt;
    final date = _dateLabel(scheduledAt);
    final time = _timeLabel(scheduledAt);
    if (date == '—' && time == '—') return 'مجدول';
    return '$date • $time';
  }

  String get _fulfillmentLabel {
    final type = (order.fulfillment?.type ?? '').toLowerCase();
    if (type == 'delivery') return 'توصيل';
    if (type == 'pickup') return 'استلام';
    return type.isEmpty ? '—' : type;
  }

  Future<void> _copyOrderNumber(BuildContext context) async {
    final number = order.orderNumber?.trim();
    if (number == null || number.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: number));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم نسخ رقم الطلب')));
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = const Color(0xFF159447);
    final itemCount = order.items.fold<int>(
      0,
      (sum, item) => sum + (item.quantity > 0 ? item.quantity : 1),
    );
    final canTrack = onTrack != null && _isDelivery;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                offset: Offset(0, 3),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  _Pill(
                    backgroundColor: categoryColor.withValues(alpha: .10),
                    foregroundColor: categoryColor,
                    icon: _categoryIcon,
                    label: _categoryLabel,
                  ),
                  const Spacer(),
                  _Pill(
                    backgroundColor: _statusColor.withValues(alpha: .10),
                    foregroundColor: _statusColor,
                    icon: _statusIcon,
                    label: _statusLabel,
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: Color(0xFF111827),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      'رقم الطلب: ${order.orderNumber ?? '#${order.id ?? '—'}'}',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Color(0xFF53617A),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if ((order.orderNumber ?? '').trim().isNotEmpty)
                    InkWell(
                      onTap: () => _copyOrderNumber(context),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: Color(0xFF53617A),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _MerchantAvatar(imageUrl: null, isRestaurant: _isRestaurant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText(
                      order.merchant?.name ?? '—',
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    _money(order.amounts?.total ?? 0),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFCFE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCell(
                            icon: FontAwesomeIcons.bagShopping,
                            label: itemCount == 1
                                ? 'عنصر واحد'
                                : '$itemCount عناصر',
                          ),
                        ),
                        const _VerticalDivider(),
                        Expanded(
                          child: _InfoCell(
                            icon: FontAwesomeIcons.receipt,
                            label:
                                'الإجمالي: ${_money(order.amounts?.total ?? 0)}',
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCell(
                            icon: _isDelivery
                                ? FontAwesomeIcons.motorcycle
                                : FontAwesomeIcons.store,
                            label: _fulfillmentLabel,
                          ),
                        ),
                        const _VerticalDivider(),
                        Expanded(
                          child: _InfoCell(
                            icon: FontAwesomeIcons.clock,
                            label: _isScheduled
                                ? _scheduledLabel()
                                : 'فوري • ${_timeLabel(order.createdAt)}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFCFE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _BottomInfo(
                              icon: FontAwesomeIcons.calendarDays,
                              title: 'تاريخ الطلب',
                              value: _dateLabel(order.createdAt),
                            ),
                          ),
                          if (_isScheduled) ...[
                            const _VerticalDivider(height: 42),
                            Expanded(
                              child: _BottomInfo(
                                icon: FontAwesomeIcons.calendarCheck,
                                title: 'موعد الطلب',
                                value: _scheduledLabel(),
                              ),
                            ),
                          ] else if (_isDelivery) ...[
                            const _VerticalDivider(height: 42),
                            Expanded(
                              child: _BottomInfo(
                                icon: FontAwesomeIcons.motorcycle,
                                title: 'التوصيل',
                                value:
                                    order.deliveryStatusLabel ??
                                    'متابعة حالة التوصيل',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        10,
                        9,
                        10,
                        9,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.message,
                            size: 14,
                            color: Color(0xFF53617A),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText(
                              _note,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF667085),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            label: canTrack ? 'تتبع الطلب' : 'عرض الطلب',
                            icon: canTrack
                                ? FontAwesomeIcons.locationDot
                                : FontAwesomeIcons.arrowLeft,
                            onTap: canTrack ? onTrack! : onTap,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _statusIcon {
    final status = (order.status ?? '').toLowerCase().trim();
    if (status == 'completed' || status == 'delivered') {
      return Icons.check_circle_outline_rounded;
    }
    if (status == 'cancelled' || status == 'canceled' || status == 'rejected') {
      return Icons.cancel_outlined;
    }
    return Icons.schedule_rounded;
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(9, 6, 9, 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 5),
          AppText(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MerchantAvatar extends StatelessWidget {
  const _MerchantAvatar({required this.imageUrl, required this.isRestaurant});

  final String? imageUrl;
  final bool isRestaurant;

  @override
  Widget build(BuildContext context) {
    final fallback = isRestaurant
        ? const Icon(
            Icons.restaurant_rounded,
            size: 24,
            color: AppColors.primary,
          )
        : AppImage.asset(AppImages.defaultStore, fit: BoxFit.cover, size: 48);
    final url = imageUrl?.trim();

    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ClipOval(
        child: url != null && url.isNotEmpty
            ? AppImage.network(
                url,
                size: 46,
                fit: BoxFit.cover,
                errorWidget: fallback,
              )
            : Center(child: fallback),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.icon, required this.label});

  final FaIconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Row(
        children: [
          FaIcon(icon, size: 14, color: const Color(0xFF53617A)),
          const SizedBox(width: 7),
          Expanded(
            child: AppText(
              label,
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF344054),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomInfo extends StatelessWidget {
  const _BottomInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  final FaIconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .06),
            shape: BoxShape.circle,
          ),
          child: FaIcon(icon, size: 14, color: AppColors.primary),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              AppText(
                value,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF344054),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final FaIconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 10, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(icon, size: 13, color: AppColors.primary),
              const SizedBox(width: 6),
              AppText(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({this.height = 34});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: height, color: const Color(0xFFE5E7EB));
  }
}
