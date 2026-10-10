import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class HomeDetailsAppBar extends StatelessWidget {
  const HomeDetailsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: EdgeInsets.fromLTRB(
        16,
        16 + MediaQuery.paddingOf(context).top,
        16,
        20,
      ),
      decoration: BoxDecoration(
        color: SharedPlatformColors.surface,
        border: Border(
          bottom: BorderSide(color: SharedPlatformColors.cleaning, width: 2),
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: AppText(
        'تفاصيل الطلب',
        textAlign: TextAlign.start,
        style: TextStyle(
          color: SharedPlatformColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          height: 32 / 24,
        ),
      ),
    );
  }
}
