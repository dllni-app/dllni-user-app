import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';

class CartMainButton extends StatelessWidget {
  const CartMainButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor = AppColors.accent,
  });
  final String label;
  final Color backgroundColor;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: Container(
        width: context.width,
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 5.2,
              color: Color(0x1F000000),
            ),
          ],
        ),
        child: AppText(
          label,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 32 / 15,
          ),
        ),
      ),
    );
  }
}
