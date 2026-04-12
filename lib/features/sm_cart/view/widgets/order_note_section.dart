import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import 'coupon_section.dart';

class OrderNoteSection extends StatelessWidget {
  const OrderNoteSection({super.key});

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
                  FontAwesomeIcons.sheetPlastic,
                  size: 14,
                  color: Color(0xFF6B7280),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    "ملاحظات الطلب",
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
            SizedBox(height: 12),
            CartField(
              hintText: "ملاحظات إضافية للمطعم (اختياري)...",
              maxLines: 2,
              onChanged: (note) {},
            ),
          ],
        ),
      ),
    );
  }
}
