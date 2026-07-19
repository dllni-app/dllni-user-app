import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/platform_coupon_models.dart';

class PlatformCouponCard extends StatelessWidget {
  const PlatformCouponCard({super.key, required this.coupon});

  final PlatformCouponModel coupon;

  String _formatAmount(double? value) {
    if (value == null) return '—';
    final digits = value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    return '$digits ل.س';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'بدون تاريخ انتهاء';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get _sectionLabel => switch (coupon.section) {
        'cleaning' => 'التنظيف',
        'restaurant' => 'المطاعم',
        'supermarket' => 'السوبر ماركت',
        _ => 'جميع الأقسام',
      };

  String get _discountLabel {
    final value = coupon.discountValue;
    if (value == null) return '—';
    if (coupon.discountType == 'percentage') {
      final percent = value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
      return '$percent%';
    }
    return _formatAmount(value);
  }

  String? get _restrictionLabel {
    final appliesTo = coupon.appliesTo;
    final labels = <String>[];
    if (appliesTo.propertyTypes.isNotEmpty) labels.add('عقارات محددة');
    if (appliesTo.cleaningModes.isNotEmpty) labels.add('أنواع تنظيف محددة');
    if (appliesTo.eventTypes.isNotEmpty) labels.add('مناسبات محددة');
    return labels.isEmpty ? null : labels.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final code = coupon.code ?? '';

    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), offset: const Offset(0, 2), blurRadius: 6)],
      ),
      padding: const EdgeInsetsDirectional.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.titleMedium(
                      coupon.title.isEmpty ? 'كوبون خصم' : coupon.title,
                      color: const Color(0xff111827),
                      fontWeight: FontWeight.w700,
                    ),
                    if (coupon.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      AppText.bodySmall(
                        coupon.description,
                        color: const Color(0xff6B7280),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(color: const Color(0xffFFF7ED), borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
                child: AppText.labelSmall(_sectionLabel, color: const Color(0xffC2410C), fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(color: const Color(0xffF3F4F6), borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: AppText.titleSmall(code.isEmpty ? '—' : code, color: const Color(0xff065F46), fontWeight: FontWeight.w700),
                ),
                InkWell(
                  onTap: code.isEmpty
                      ? null
                      : () async {
                          await Clipboard.setData(ClipboardData(text: code));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم نسخ الكوبون: $code')));
                        },
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsetsDirectional.all(4),
                    child: Icon(Icons.copy_rounded, size: 18, color: Color(0xff4B5563)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _CouponInfoRow(title: 'قيمة الخصم', value: _discountLabel),
          const SizedBox(height: 8),
          _CouponInfoRow(title: 'الحد الأدنى للطلب', value: _formatAmount(coupon.minimumOrderAmount)),
          if (coupon.maximumDiscountAmount != null) ...[
            const SizedBox(height: 8),
            _CouponInfoRow(title: 'الحد الأقصى للخصم', value: _formatAmount(coupon.maximumDiscountAmount)),
          ],
          const SizedBox(height: 8),
          _CouponInfoRow(title: 'ينتهي في', value: _formatDate(coupon.endsAt)),
          if (_restrictionLabel case final restriction?) ...[
            const SizedBox(height: 10),
            AppText.bodySmall(restriction, color: const Color(0xff9A3412), fontWeight: FontWeight.w600),
          ],
        ],
      ),
    );
  }
}

class _CouponInfoRow extends StatelessWidget {
  const _CouponInfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.bodyMedium(title, color: const Color(0xff6B7280), fontWeight: FontWeight.w500, textAlign: TextAlign.start),
        const SizedBox(width: 12),
        Flexible(child: AppText.bodyMedium(value, color: const Color(0xff065F46), fontWeight: FontWeight.w700)),
      ],
    );
  }
}
