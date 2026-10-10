import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.onTap,
    required this.title,
    this.withShadow = false,
    this.color = AppColors.primary,
    this.icon,
  });
  final void Function()? onTap;
  final String title;
  final bool withShadow;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          color: onTap != null ? color : const Color(0x662F2B3D),
          boxShadow: onTap == null || (onTap != null && !withShadow)
              ? null
              : [
                  BoxShadow(
                    offset: Offset(0, 4),
                    blurRadius: 16,
                    color: const Color(0x16172554),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.42,
              ),
            ),
            if (icon != null) ...[
              SizedBox(width: 6),
              Icon(icon, size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    this.onTap,
    required this.title,
    required this.color,
    this.icon,
    this.withBackground = true,
    this.withShadow = false,
  });
  final void Function()? onTap;
  final String title;
  final bool withBackground;
  final Color color;
  final IconData? icon;
  final bool withShadow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          color: withBackground ? color.withValues(alpha: .08) : null,
          border: Border.all(color: color),
          boxShadow: onTap == null || (onTap != null && !withShadow)
              ? null
              : [
                  BoxShadow(
                    offset: Offset(0, 4),
                    blurRadius: 16,
                    color: const Color(0x16172554),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              title,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.42,
              ),
            ),
            if (icon != null) ...[
              SizedBox(width: 6),
              Icon(icon, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }
}
