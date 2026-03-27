import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.items,
    required this.onChanged,
    required this.selectedIndex,
  });
  final List<AppNavBarItem> items;
  final void Function(int index) onChanged;
  final int selectedIndex;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Container(
      width: width,
      padding: EdgeInsets.fromLTRB(24, 12, 24, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -4),
            blurRadius: 20,
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final bool isSelected = selectedIndex == index;
          return Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              GestureDetector(
                onTap: () => onChanged(index),
                child: Container(
                  width: isSelected ? 48 : 40,
                  height: isSelected ? 48 : 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: .16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                  child: Icon(
                    items[index].icon,
                    size: 20,
                    color: isSelected ? AppColors.accent : Color(0xFFA5AAC9),
                  ),
                ),
              ),
              Text(
                items[index].title,
                style: TextStyle(
                  color: isSelected ? AppColors.accent : Color(0xFFA5AAC9),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class AppNavBarItem {
  final String title;
  final IconData icon;

  AppNavBarItem({required this.title, required this.icon});
}
