
import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../sm_cart/view/screens/sm_cart_screen.dart';

class SummaryRequest extends StatelessWidget {
  const SummaryRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                "مجموع المنتجات (3 عناصر)",
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
              AppText(
                "1250 ل.س",
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                "الخصم (كوبون)",
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
              AppText(
                "- 250 ل.س",
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          CustomPaint(
            size: Size(double.infinity, 1),
            painter: DashedLinePainter(),
          ),
          SizedBox(height: 12),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  "المجموع النهائي",
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 28 / 18,
                  ),
                ),
                AppText(
                  "1250 ل.س",
                  style: TextStyle(
                    color: Color(0xFF1A237E),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 28 / 20,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
