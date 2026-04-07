import 'dart:math';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';
import '../widgets/dialogs/related_products_dialog.dart';
import '../widgets/products_bottom_nav_bar.dart';

@AutoRoutePage(path: "/product")
class SmProductDetailsScreen extends StatelessWidget {
  const SmProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 340 + MediaQuery.paddingOf(context).top,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AppImage.asset(
                      AppImages.products,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 32,
                    left: 24,
                    right: 24,
                    child: Row(
                      children: [
                        _ActionButton(
                          icon: FontAwesomeIcons.arrowRight,
                          onTap: () => context.pop(),
                        ),
                        Expanded(
                          child: AppText(
                            "ماركت النور",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 24 / 16,
                            ),
                          ),
                        ),
                        _ActionButton(
                          icon: FontAwesomeIcons.solidHeart,
                          onTap: () {},
                        ),
                        SizedBox(width: 8),
                        _ActionButton(
                          icon: FontAwesomeIcons.shareNodes,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 6,
                            spreadRadius: -4,
                            color: Color(0x1A000000),
                          ),
                          BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 15,
                            spreadRadius: -3,
                            color: Color(0x1A000000),
                          ),
                        ],
                      ),
                      child: AppText(
                        "الأكثر طلباً",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 16 / 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: Color(0xFFF3F4F6)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          "خبز سياحي",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 32 / 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => RelatedProductsDialog(),
                          );
                        },
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 4),
                                blurRadius: 6,
                                spreadRadius: -4,
                                color: Color(0x1A000000),
                              ),
                              BoxShadow(
                                offset: Offset(0, 10),
                                blurRadius: 15,
                                spreadRadius: -3,
                                color: Color(0x1A000000),
                              ),
                            ],
                          ),
                          child: Text(
                            "مقارنة السعر",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 16 / 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        "95 ل.س",
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 36 / 30,
                        ),
                      ),
                      AppText(
                        "40.00 ل.س",
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          height: 28 / 18,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: Color(0xFFF3F4F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  AppText(
                    "إضافات ذكية",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 28 / 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  AppText(
                    "اختر ما يناسبك",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) => Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        border: Border.all(color: Color(0xFFE5E7EB), width: 2),
                      ),
                      child: Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  "توست",
                                  style: TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    height: 20 / 14,
                                  ),
                                ),
                                AppText(
                                  "6 قطع من الخبز المحمص ",
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    height: 16 / 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppText(
                            "+3 ل.س",
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 20 / 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    separatorBuilder: (_, _) => SizedBox(height: 12),
                    itemCount: 3,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: Color(0xFFF3F4F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  AppText(
                    "ملاحظات خاصة",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 28 / 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  AppText(
                    "أضف أي طلب خاص",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  TextField(
                    maxLines: 3,
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          "اكتب ملاحظة خاصة بالطلب (اختياري)\nمثل: يرجى اختيار ربطة خبز تازة",
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 20 / 14,
                      ),
                      contentPadding: EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          width: 2,
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          width: 2,
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: ProductsBottomNavBar(onChanged: (quantity) {}),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap});
  final FaIconData icon;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFB),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: FaIcon(icon, size: 18, color: Color(0xFF1F2937)),
      ),
    );
  }
}
