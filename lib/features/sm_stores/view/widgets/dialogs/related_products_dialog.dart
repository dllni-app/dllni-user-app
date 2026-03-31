import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/utils/app_images.dart';

class RelatedProductsDialog extends StatelessWidget {
  const RelatedProductsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0xFFF3F4F6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  "نتائج المقارنة",
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.pop();
                  },
                  customBorder: CircleBorder(),
                  child: Ink(
                    width: 24,
                    height: 24,
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.x,
                        size: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (_, _) => Container(
                padding: EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                ),
                child: Row(
                  children: [
                    AppImage.asset(
                      AppImages.products,
                      width: 64,
                      height: 61,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                "خبز سياحي ( الخيرات )",
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 20 / 14,
                                ),
                              ),
                              AppText(
                                "35 ل.س",
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 20 / 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 23,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: .14),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                                child: AppText(
                                  "متجر النور",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    height: 20 / 12,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppText(
                                      "عرض المنتج",
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        height: 20 / 10,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    FaIcon(
                                      FontAwesomeIcons.angleLeft,
                                      size: 10,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 8),
                                  ],
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
              separatorBuilder: (_, _) => SizedBox(height: 12),
            ),
          ],
        ),
      ),
    );
  }
}
