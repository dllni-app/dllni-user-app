import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.containerColor,
    required this.image,
    required this.title,
    required this.subtitle,
    this.count,
    required this.onTap,
  });

  final Color containerColor;
  final Widget image;
  final String title;
  final String subtitle;
  final int? count;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: containerColor,
            child: image,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                AppText(
                  title,
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
                AppText(
                  subtitle,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
          if (count != null) ...[
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFFEF4444),
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: AppText(
                count.toString(),
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 15 / 10,
                ),
              ),
            ),
          ],
          SizedBox(width: count != null ? 8 : 12),
          Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}
