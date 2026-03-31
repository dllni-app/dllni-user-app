import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class CategoriesBar extends StatefulWidget {
  const CategoriesBar({super.key, required this.selectedCategory, required this.onCategorySelected});

  final int selectedCategory;
  final void Function(int index) onCategorySelected;

  @override
  State<CategoriesBar> createState() => _CategoriesBarState();
}

class _CategoriesBarState extends State<CategoriesBar> {
  int _selectedCategory = -1;

  @override
  void initState() {
    _selectedCategory = widget.selectedCategory;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "ما هي مستلزماتك لليوم؟",
            style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 16, fontWeight: FontWeight.w700, height: 24 / 16),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) => _CategoryItem(
              isSelected: _selectedCategory == index,
              imagePath: categoryImages[index],
              title: categories[index],
              onTap: () {
                if (_selectedCategory == index) {
                  _selectedCategory = -1;
                } else {
                  _selectedCategory = index;
                }
                widget.onCategorySelected(_selectedCategory);
                setState(() {});
              },
            ),
            // [
            //   _CategoryItem(imagePath: AppImages.chocolate, title: "شوكولا"),
            //   _CategoryItem(imagePath: AppImages.vegetables, title: "حواضر"),
            //   _CategoryItem(imagePath: AppImages.meats, title: "لحوم و دجاج"),
            //   _CategoryItem(imagePath: AppImages.jam, title: "مربيات"),
            //   _CategoryItem(imagePath: AppImages.juices, title: "عصائر"),
            //   _CategoryItem(imagePath: AppImages.pastries, title: "معجنات"),
            //   _CategoryItem(imagePath: AppImages.detergents, title: "منظفات"),
            //   _CategoryItem(imagePath: AppImages.legumes, title: "بقوليات"),
            // ][index],
            separatorBuilder: (_, _) => SizedBox(width: 16),
            itemCount: 8,
          ),
        ),
      ],
    );
  }

  static const List<String> categories = ["شوكولا", "حواضر", "لحوم و دجاج", "مربيات", "عصائر", "معجنات", "منظفات", "بقوليات"];
  static const List<IconData> categoryImages = [
    Icons.add,
    Icons.add,
    Icons.add,
    Icons.add,
    Icons.add,
    Icons.add,
    Icons.add,
    Icons.add,
  ];
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.isSelected, required this.imagePath, required this.title, this.onTap});

  final bool isSelected;
  final IconData imagePath;
  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? context.primaryContainer : Colors.transparent, width: 2),
            ),
            child: Icon(imagePath),
          ),
          SizedBox(height: 8),
          AppText(
            title,
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12),
          ),
        ],
      ),
    );
  }
}
