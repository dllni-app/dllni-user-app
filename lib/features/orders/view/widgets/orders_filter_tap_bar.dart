import 'package:common_package/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class CategoriesTabBar extends StatefulWidget {
  const CategoriesTabBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  State<CategoriesTabBar> createState() => _CategoriesTabBarState();
}

class _CategoriesTabBarState extends State<CategoriesTabBar> with TickerProviderStateMixin {
  late TabController _tabController1;

  List<String> titles = ['المتاجر', 'المطاعم', 'التنظيفات'];

  @override
  void initState() {
    _tabController1 = TabController(length: titles.length, vsync: this);
    _tabController1.index = widget.selectedIndex;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CategoriesTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tabController1.index != widget.selectedIndex) {
      _tabController1.index = widget.selectedIndex;
    }
  }

  @override
  void dispose() {
    _tabController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      // isScrollable: true,
      onTap: (i) {
        widget.onChanged(i);
      },
      physics: const BouncingScrollPhysics(),
      dividerHeight: .2,
      // tabAlignment: TabAlignment.start,
      indicatorColor: Color(0xff1E2A78),
      controller: _tabController1,
      labelPadding: EdgeInsetsDirectional.symmetric(vertical: 3, horizontal: 15),
      tabs: List.generate(
        titles.length,
        (i) => Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 10),
          child: AppText.labelLarge(
            titles[i],
            fontWeight: FontWeight.bold,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.fade,
            textAlign: TextAlign.center,
            color: i == widget.selectedIndex ? Color(0xff1E2A78) : null,
          ),
        ),
      ),
      labelColor: Colors.black,
      indicator: MaterialIndicator(height: 3, topLeftRadius: 8, topRightRadius: 8, tabPosition: TabPosition.bottom, color: Color(0xff1E2A78)),
    );
  }
}
