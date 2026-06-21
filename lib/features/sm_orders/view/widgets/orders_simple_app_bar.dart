import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';

class SimpleAppBarWithTabBar extends StatefulWidget {
  final String title;
  final void Function(int index) onChanged;
  final List<String> items;
  const SimpleAppBarWithTabBar({
    super.key,
    required this.title,
    required this.onChanged,
    required this.items,
  });

  @override
  State<SimpleAppBarWithTabBar> createState() => _SimpleAppBarWithTabBarState();
}

class _SimpleAppBarWithTabBarState extends State<SimpleAppBarWithTabBar> {
  int selectedTab = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: context.width,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: 32 + MediaQuery.paddingOf(context).top,
            bottom: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 4.6,
                color: Color(0x1C000000),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                widget.title,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 32 / 20,
                ),
              ),
              SizedBox(height: 25),
              Row(
                children: List.generate(
                  widget.items.length,
                  (index) => Expanded(
                    child: InkWell(
                      onTap: () {
                        if (selectedTab == index) return;
                        selectedTab = index;
                        setState(() {});
                        widget.onChanged(selectedTab);
                      },
                      child: AppText(
                        widget.items[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedTab == index
                              ? AppColors.primary
                              : Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: selectedTab == index
                              ? FontWeight.w700
                              : FontWeight.w400,
                          height: 32 / 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: List.generate(
            widget.items.length,
            (index) => Expanded(
              child: selectedTab == index
                  ? Divider(height: 1, thickness: 1, color: AppColors.primary)
                  : SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
