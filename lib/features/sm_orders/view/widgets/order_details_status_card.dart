import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';

class OrderStatus extends StatelessWidget {
  const OrderStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, 13, 16, 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Row(
        spacing: 6,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundImage: AssetImage(AppImages.store),
          ),
          Expanded(
            child: AppText(
              "متجر الأطرش ( فرع الفرقان )",
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 28 / 10,
              ),
            ),
          ),
          Container(
            width: 70,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: .12),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: AppText(
              "مكتمل",
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
