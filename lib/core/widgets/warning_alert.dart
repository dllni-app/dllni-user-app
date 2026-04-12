import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../themes/app_colors.dart';
import '../themes/app_shadows.dart';

class WarningAlert extends StatelessWidget {
  const WarningAlert({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.labelButton,
    this.onTapButton,
  });
  final IconData icon;
  final String title;
  final String description;
  final String labelButton;
  final void Function()? onTapButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF9F4EC),
        borderRadius: BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: Color(0xFFFEE2E2)),
        boxShadow: [AppShadows.shadow],
      ),
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [AppShadows.shadow],
            ),
            child: Icon(icon, size: 18, color: Color(0xFFFF9F43)),
          ),
          Expanded(
            child: Column(
              spacing: 3,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: TextStyle(
                    color: Color(0xFFFF9F43),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.42,
                  ),
                ),
                AppText(
                  description,
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 12,
                    height: 1.625,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onTapButton,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
                boxShadow: [AppShadows.shadow],
              ),
              child: AppText(
                labelButton,
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.333,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
