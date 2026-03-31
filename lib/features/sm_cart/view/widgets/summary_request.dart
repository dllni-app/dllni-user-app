import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';

class SummaryRequest extends StatelessWidget {
  const SummaryRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            "ملخص الطلب",
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 24 / 16,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              border: Border.all(color: Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 1),
                  color: Color(0x0D000000),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Column(
              spacing: 12,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      "المبلغ الإجمالي",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      "الضريبة",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      "الخصم (كوبون)",
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      "المجموع النهائي",
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 20 / 14,
                      ),
                    ),
                    AppText(
                      "1250 ل.س",
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
