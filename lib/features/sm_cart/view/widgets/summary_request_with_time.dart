import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';

class SummaryRequestWithTime extends StatelessWidget {
  const SummaryRequestWithTime({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Color(0x0D000000),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              "ملخص الطلب",
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 24 / 16,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  "قيمة الطلب",
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 14,
                    height: 20 / 14,
                  ),
                ),
                AppText(
                  "1250 ل.س",
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  "الإجمالي",
                  style: TextStyle(
                    color: Color(0xFF1E2B5E),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 24 / 16,
                  ),
                ),
                AppText(
                  "1250 ل.س",
                  style: TextStyle(
                    color: Color(0xFF1E2B5E),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 24 / 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFEFF6FF),
                borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: Row(children: [
                FaIcon(FontAwesomeIcons.solidClock, size: 12, color: Color(0xFF1E40AF)),
                SizedBox(width: 8),
                AppText("الوقت المتوقع: 10 - 15 دقيقة", style: TextStyle(
                  color: Color(0xFF1E40AF),
                  fontSize: 12,
                  height: 16 / 12
                ))
              ],)
            )
          ],
        ),
      ),
    );
  }
}
