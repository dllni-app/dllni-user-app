import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';

class OrdersSimpleAppBar extends StatelessWidget {
  const OrdersSimpleAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: 32 + MediaQuery.paddingOf(context).top,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.accent),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 4.6,
            color: Color(0x1C000000),
          ),
        ],
      ),
      child: AppText(
        "طلباتي",
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 32 / 20,
        ),
      ),
    );
  }
}
