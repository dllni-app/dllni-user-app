import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class DiscoverTabBarItem {
  final String title;
  final Widget? icon;

  DiscoverTabBarItem({required this.title, this.icon});
}

class DiscoverTabBar extends StatefulWidget {
  const DiscoverTabBar({
    super.key,
    required this.items,
    required this.onChanged,
    this.initialIndex = 0,
  });

  final List<DiscoverTabBarItem> items;
  final void Function(int index) onChanged;
  final int initialIndex;

  @override
  State<DiscoverTabBar> createState() => _DiscoverTabBarState();
}

class _DiscoverTabBarState extends State<DiscoverTabBar> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final maxIndex = widget.items.isEmpty ? 0 : widget.items.length - 1;
    selectedIndex = widget.initialIndex.clamp(0, maxIndex);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38 + 32,
      width: double.infinity,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            if (index != selectedIndex) {
              selectedIndex = index;
              setState(() {});
              widget.onChanged(index);
            }
          },
          child: _CategoryChip(
            isSelected: index == selectedIndex,
            item: widget.items[index],
          ),
        ),
        separatorBuilder: (_, _) => SizedBox(width: 8),
        itemCount: widget.items.length,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.item, required this.isSelected});

  final DiscoverTabBarItem item;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? null : context.onPrimary,
        gradient: isSelected
            ? LinearGradient(
                colors: [context.secondary, context.primary],
                stops: [.3, .9],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : null,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: isSelected ? null : Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          if (item.icon != null) item.icon!,
          Text(
            item.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.42,
              color: isSelected ? context.onPrimary : Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}
