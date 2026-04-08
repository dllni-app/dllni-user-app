import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/profile_api_models.dart';

class RestaurantCouponCard extends StatelessWidget {
  const RestaurantCouponCard({super.key, required this.coupon});

  final RestaurantCouponModel coupon;

  String _formatNumber(int? value) {
    if (value == null) return '—';
    final raw = value.toString();
    final result = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final remaining = raw.length - i;
      result.write(raw[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        result.write(',');
      }
    }
    return result.toString();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day} - ${date.month} - ${date.year}';
  }

  String _discountTypeLabel() {
    if (coupon.discountType == 'percentage') return 'نسبة مئوية';
    return 'قيمة ثابتة';
  }

  String _discountValueLabel() {
    final value = coupon.discountValue;
    if (value == null) return '—';
    if (coupon.discountType == 'percentage') {
      final rounded = value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
      return '$rounded%';
    }
    final amount = value % 1 == 0 ? value.toInt() : value.round();
    return '${_formatNumber(amount)} ل.س';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), offset: const Offset(0, 2), blurRadius: 6)],
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(color: const Color(0xffF3F4F6), borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
                    child: AppText.titleSmall(coupon.code ?? '—', color: const Color(0xff065F46), fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xffF3F4F6), borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
                    child: InkWell(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: coupon.code!));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم نسخ الكوبون: ${coupon.code}')));
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsetsDirectional.all(2),
                        child: Icon(Icons.copy_rounded, size: 16, color: Color(0xff4B5563)),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(color: const Color(0xffDCFCE7), borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
                    child: AppText.labelSmall(
                      coupon.isActive ? 'نشط' : 'غير نشط',
                      color: coupon.isActive ? const Color(0xff059669) : const Color(0xff6B7280),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xffE5F3EF), borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
                    child: AppText.labelSmall(_discountTypeLabel(), color: const Color(0xff0F766E), fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if ((coupon.restaurant?.name ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(coupon.restaurant!.imageUrl!)),
                SizedBox(width: 12),
                AppText.labelLarge(coupon.restaurant!.name!, color: const Color(0xff374151), fontWeight: FontWeight.w700),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Container(
            width: context.width,
            decoration: BoxDecoration(color: const Color(0xffF8FAFC), borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsetsDirectional.all(12),
            child: Column(
              children: [
                _CouponInfoRow(title: 'قيمة الخصم', value: _discountValueLabel()),
                const SizedBox(height: 8),
                _CouponInfoRow(title: 'الحد الأدنى للطلب', value: '${_formatNumber(coupon.minOrderAmount)} ل.س'),
                // const SizedBox(height: 8),
                // _CouponInfoRow(title: 'عدد الاستخدامات', value: _usageLabel()),
                const SizedBox(height: 8),
                _CouponInfoRow(title: 'مدة العرض', value: _formatDate(coupon.endsAt)),
              ],
            ),
          ),
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
        AppText.bodyMedium(value, color: const Color(0xff065F46), fontWeight: FontWeight.w700),
      ],
    );
  }
}
