import 'package:common_package/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class CategoriesTabBar extends StatefulWidget {
  const CategoriesTabBar({super.key});

  @override
  State<CategoriesTabBar> createState() => _CategoriesTabBarState();
}

class _CategoriesTabBarState extends State<CategoriesTabBar> with TickerProviderStateMixin {
  late TabController _tabController1;

  int selectedIndex = 0;

  List<String> titles = ['الكل', 'المتاجر', 'المطاعم', 'التنظيفات'];

  @override
  void initState() {
    _tabController1 = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      onTap: (i) {
        setState(() {
          selectedIndex = i;
        });
      },
      physics: const BouncingScrollPhysics(),
      dividerHeight: .2,
      tabAlignment: TabAlignment.start,
      indicatorColor: Color(0xff1E2A78),
      controller: _tabController1,
      labelPadding: EdgeInsetsDirectional.symmetric(vertical: 3, horizontal: 15),
      tabs: List.generate(
        4,
        (i) => Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 10),
          child: AppText.labelLarge(
            titles[i],
            fontWeight: FontWeight.bold,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.fade,
            textAlign: TextAlign.center,
            color: i == selectedIndex ? Color(0xff1E2A78) : null,
          ),
        ),
      ),
      labelColor: Colors.black,
      indicator: MaterialIndicator(height: 3, topLeftRadius: 8, topRightRadius: 8, tabPosition: TabPosition.bottom, color: Color(0xff1E2A78)),
    );
  }
}
