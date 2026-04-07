import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class StoreInfoSection extends StatelessWidget {
  const StoreInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            "معلومات المتجر",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 28 / 20,
            ),
          ),
          SizedBox(height: 20),
          AppText(
            "عن المتجر",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 24 / 16,
            ),
          ),
          SizedBox(height: 8),
          AppText(
            "متجر النور هو سلسلة من المتاجر يحوي كل ما تحتاجه العائلة من منتجات تغذية و منظفات لتسالي و أجود أنواع المكسرات. نفخر بتقديم الخدمة لكم بأسعار منافسة.",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 23 / 14,
            ),
          ),
          SizedBox(height: 20),
          AppText(
            "معلومات المتجر",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 28 / 20,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                "السبت - الأربعاء",
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
              AppText(
                "10:00 ص - 2:00 ص",
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
