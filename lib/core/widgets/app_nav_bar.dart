import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      padding: EdgeInsets.fromLTRB(8, 2, 8, 14 + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
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
        children: List.generate(items.length, (index) {
          final bool isSelected = selectedIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isSelected
                      ? Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                        )
                      : SizedBox(height: 4),
                  SizedBox(height: 8),
                  FaIcon(
                    items[index].icon,
                    size: 18,
                    color: isSelected ? AppColors.primary : Color(0xFFA5AAC9),
                  ),
                  SizedBox(height: 4),
                  Text(
                    items[index].title,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Color(0xFFA5AAC9),
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class AppNavBarItem {
  final String title;
  final FaIconData icon;

  AppNavBarItem({required this.title, required this.icon});
}
