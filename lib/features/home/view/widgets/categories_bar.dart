
import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/app_images.dart';

class CategoriesBar extends StatelessWidget {
  const CategoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "ما هي مستلزماتك لليوم؟",
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 24 / 16,
            ),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) => [
              _CategoryItem(imagePath: AppImages.chocolate, title: "شوكولا"),
              _CategoryItem(imagePath: AppImages.vegetables, title: "حواضر"),
              _CategoryItem(imagePath: AppImages.meats, title: "لحوم و دجاج"),
              _CategoryItem(imagePath: AppImages.jam, title: "مربيات"),
              _CategoryItem(imagePath: AppImages.juices, title: "عصائر"),
              _CategoryItem(imagePath: AppImages.pastries, title: "معجنات"),
              _CategoryItem(imagePath: AppImages.detergents, title: "منظفات"),
              _CategoryItem(imagePath: AppImages.legumes, title: "بقوليات"),
            ][index],
            separatorBuilder: (_, _) => SizedBox(width: 16),
            itemCount: 8,
          ),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.imagePath, required this.title});
  final String imagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage(imagePath),
        ),
        SizedBox(height: 8),
        AppText(
          title,
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
          ),
        ),
      ],
    );
  }
}
