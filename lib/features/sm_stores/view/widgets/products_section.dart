import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';

class ProductsSection extends StatelessWidget {
  const ProductsSection({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppText(
            title,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 28 / 16,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (context, index) => SizedBox(width: 24),
            itemBuilder: (context, index) => ProductCard(),
          ),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 180,
      child: Column(
        children: [
          Stack(
            children: [
              AppImage.asset(
                AppImages.products,
                size: 112,
                borderRadius: BorderRadius.all(Radius.circular(12)),
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 6,
                right: 5,
                child: InkWell(
                  onTap: () {},
                  customBorder: CircleBorder(),
                  child: Container(
                    alignment: Alignment.center,
                    width: 25,
                    height: 25,
                    decoration: ShapeDecoration(
                      shape: CircleBorder(),
                      color: AppColors.white,
                      shadows: [
                        BoxShadow(
                          offset: Offset(0, 4),
                          blurRadius: 4,
                          color: Color(0x40000000),
                        ),
                      ],
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.plus,
                      color: Color(0xFF4B5563),
                      size: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          AppText(
            "هوى الشام لبنة كاملة الدسم",
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 16 / 12,
            ),
          ),
          AppText(
            "5000 ل.س",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 28 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
