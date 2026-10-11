import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/themes/v7_artwork.dart';
import '../../data/models/platform_coupon_models.dart';

/// Pen V7 coupon ticket backed only by actual coupon resource fields.
class PlatformCouponCard extends StatelessWidget {
  const PlatformCouponCard({super.key, required this.coupon});
  final PlatformCouponModel coupon;

  String _amount(double? value) {
    if (value == null) return 'غير محدد';
    return (value % 1 == 0
            ? value.toStringAsFixed(0)
            : value.toStringAsFixed(2)) +
        ' ل.س';
  }

  String _date(DateTime? value) {
    if (value == null) return 'دون تاريخ انتهاء';
    return value.day.toString().padLeft(2, '0') +
        '/' +
        value.month.toString().padLeft(2, '0') +
        '/' +
        value.year.toString();
  }

  Color get _soft => switch (coupon.section) {
    'cleaning' => const Color(0xFFE9F9FA),
    'restaurant' => const Color(0xFFFFF1F1),
    'supermarket' => const Color(0xFFEAF7F1),
    _ => const Color(0xFFF1F2FA),
  };
  String get _section => switch (coupon.section) {
    'cleaning' => 'التنظيفات',
    'restaurant' => 'المطاعم',
    'supermarket' => 'السوبرماركت',
    _ => 'جميع الخدمات',
  };
  String get _discount {
    final value = coupon.discountValue;
    if (value == null) return 'قيمة الخصم غير محددة';
    if (coupon.discountType == 'percentage') {
      return (value % 1 == 0
              ? value.toStringAsFixed(0)
              : value.toStringAsFixed(1)) +
          '%';
    }
    return _amount(value);
  }

  @override
  Widget build(BuildContext context) {
    final code = (coupon.code ?? '').trim();
    final restrictions = <String>[
      if (coupon.appliesTo.propertyTypes.isNotEmpty) 'عقارات محددة',
      if (coupon.appliesTo.cleaningModes.isNotEmpty) 'أنواع تنظيف محددة',
      if (coupon.appliesTo.eventTypes.isNotEmpty) 'مناسبات محددة',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EBF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              V7ArtTile(
                asset: V7Artwork.coupon,
                size: 56,
                background: _soft,
                radius: 13,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title.isNotEmpty ? coupon.title : 'قسيمة خصم',
                      style: const TextStyle(
                        fontSize: 15,
                        color: SharedPlatformColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _section,
                      style: const TextStyle(
                        color: SharedPlatformColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _discount,
                style: const TextStyle(
                  color: Color(0xFF087D88),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (coupon.description.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              coupon.description,
              style: const TextStyle(
                color: SharedPlatformColors.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
          if (code.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      code,
                      style: const TextStyle(
                        fontSize: 14,
                        color: SharedPlatformColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: code));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ رمز الكوبون')),
                      );
                    },
                    tooltip: 'نسخ الرمز',
                    icon: const Icon(
                      Icons.copy_outlined,
                      color: SharedPlatformColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 14, color: Color(0xFFE9EDF1)),
          _CouponDetail(
            label: 'الحد الأدنى للطلب',
            value: _amount(coupon.minimumOrderAmount),
          ),
          if (coupon.maximumDiscountAmount != null)
            _CouponDetail(
              label: 'الحد الأقصى للخصم',
              value: _amount(coupon.maximumDiscountAmount),
            ),
          _CouponDetail(label: 'الصلاحية', value: _date(coupon.endsAt)),
          if (restrictions.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              restrictions.join(' • '),
              style: const TextStyle(
                color: Color(0xFF986421),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CouponDetail extends StatelessWidget {
  const _CouponDetail({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: SharedPlatformColors.muted,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: SharedPlatformColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}
