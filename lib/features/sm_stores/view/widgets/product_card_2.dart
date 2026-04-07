
import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';

class ProductCard2 extends StatelessWidget {
  const ProductCard2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: AppColors.white),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 23, 11, 13),
            child: Row(
              spacing: 12,
              children: [
                AppImage.asset(
                  AppImages.products,
                  size: 80,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12),
                      AppText(
                        "ربطة خبز سياحي",
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 20 / 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      AppText(
                        "وزن ٩٨٠ غ",
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 16 / 12,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppText(
                            "40 ل.س",
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 16 / 12,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Color(0xFF9CA3AF),
                            ),
                          ),
                          SizedBox(width: 16),
                          AppText(
                            "30 ل.س",
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 16 / 12,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Color(0xFF9CA3AF),
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: .08),
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                            child: AppText(
                              "متجر عماد",
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 16 / 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 11, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
              child: AppText(
                "عرض لفترة محدودة",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 15 / 10,
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: InkWell(
              onTap: () {},
              customBorder: CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: FaIcon(FontAwesomeIcons.heart, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
