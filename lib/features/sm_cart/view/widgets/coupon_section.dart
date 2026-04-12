import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';

class CouponSection extends StatelessWidget {
  const CouponSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0D000000))
          ]
        ),
        child: Column(
          children: [
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.ticket,
                  size: 18,
                  color: AppColors.accent,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    "هل لديك كود حسم ؟",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 24 / 16,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              spacing: 8,
              children: [
                Expanded(child: CartField(
                  hintText: "أدخل كود الخصم هنا",
                  onChanged: (coupon) {})),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: AppText(
                      "تطبيق",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 24 / 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF0FDF4),
                border: Border.all(color: Color(0xFFDCFCE7)),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.solidCircleCheck,
                    size: 14,
                    color: Color(0xFF10B981),
                  ),
                  SizedBox(width: 8),
                  AppText(
                    "تم تطبيق الكوبون بنجاح! خصم 20% (250 ل.س)",
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
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

class CartField extends StatelessWidget {
  const CartField({super.key, required this.onChanged, this.maxLines = 1, this.hintText});
  final void Function(String coupon) onChanged;
  final int maxLines;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      maxLines: maxLines,
      style: TextStyle(
        color: Color(0xFF111827),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 26 / 14,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 26 / 14,
        ),
        filled: true,
        fillColor: Color(0xFFF9FAFB),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
    );
  }
}
