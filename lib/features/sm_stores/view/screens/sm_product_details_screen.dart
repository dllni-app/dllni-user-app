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
                          onTap: () {},
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
                    bottom: 12,
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
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: AppColors.white,
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  AppText(
                    "ملاحظات إضافية",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 28 / 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
                    ),
                    decoration: InputDecoration(
                      hintText: "أخبرنا بها",
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
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  AppText(
                    "اكتشفت مشكلة ؟ أخبرنا عنها ؟",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
                    ),
                  ),
                  SizedBox(height: 6),
                  AppText(
                    "ساعدنا لإبقاء القائمة دقيقة و حديثة",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      height: 20 / 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 125),
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
