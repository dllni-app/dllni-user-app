import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import '../../data/models/fetch_restaurant_home_categories_model.dart';

class CategoriesBar extends StatefulWidget {
  const CategoriesBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categories,
  });

  final int selectedCategory;
  final void Function(int index) onCategorySelected;
  final List<RestaurantHomeCategoryItem> categories;

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
        Text(
          "ماذا تشتهي اليوم؟",
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 24 / 16,
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) => _CategoryItem(
              isSelected: _selectedCategory == index,
              imagePath: widget.categories[index].image ?? Icons.image_outlined,
              title: widget.categories[index].name ?? '-',
              onTap: () {
                _selectedCategory = index;
                widget.onCategorySelected(_selectedCategory);
                setState(() {});
              },
            ),
            separatorBuilder: (_, _) => SizedBox(width: 16),
            itemCount: widget.categories.length,
          ),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.isSelected,
    required this.imagePath,
    required this.title,
    this.onTap,
  });

  final bool isSelected;
  final dynamic imagePath;
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
              border: Border.all(
                color: isSelected
                    ? context.primaryContainer
                    : Colors.transparent,
                width: 2,
              ),
              color: Colors.white,
            ),
            child: (imagePath is String && imagePath != null)
                ? AppImage.network(
                    imagePath.toString(),
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(99),
                  )
                : Icon(imagePath),
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
      ),
    );
  }
}
