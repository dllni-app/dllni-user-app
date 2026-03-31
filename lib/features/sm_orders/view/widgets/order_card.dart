import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 8.4,
            color: Color(0x29000000),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
            child: Row(
              children: [
                CircleAvatar(radius: 18, backgroundColor: Color(0xFFD9D9D9)),
                SizedBox(width: 6),
                Expanded(
                  child: AppText(
                    "سوبر ماركت النور",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 32 / 12,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      "#45687_755",
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        height: 17 / 8,
                      ),
                    ),
                    AppText(
                      "فيراير 24 2026 2:31 م",
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        height: 15 / 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Color(0x669CA3AF),height: 1,),
          Padding(
            padding: const EdgeInsets.fromLTRB(35, 11, 55, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "4 أصناف",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        height: 15 / 8,
                      ),
                    ),
                    AppText(
                      "22000 ل.س",
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        height: 15 / 8,
                      ),
                    ),
                  ],
                ),
                AppText(
                  "مدفوعة",
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    height: 15 / 8,
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
