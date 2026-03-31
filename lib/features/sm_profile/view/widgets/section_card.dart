import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.containerColor,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color containerColor;
  final Widget image;
  final String title;
  final String subtitle;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: containerColor),
            padding: EdgeInsetsDirectional.all(13),
            child: image,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMedium(title, fontWeight: FontWeight.bold),
                AppText.labelLarge(subtitle, fontWeight: FontWeight.w400, color: Color(0xff6B7280)),
              ],
            ),
          ),
          SizedBox(width: 12),
          Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }
}
