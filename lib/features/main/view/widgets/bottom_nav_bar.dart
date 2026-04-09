import 'package:common_package/common_package.dart';
import 'package:common_package/extensions/size_extensions.dart';
import 'package:flutter/material.dart';

import '../../../../generated/assets.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key, required this.controller});

  final TabController controller;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    List<String> titles = ['الرئيسية', 'طلباتي', 'حسابي'];
    List<String> images = [Assets.images.mainHome.path, Assets.images.mainOrders.path, Assets.images.mainProfile.path];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(27), offset: Offset(0, -2), blurRadius: 12, spreadRadius: 0)],
      ),
      width: context.width,
      height: 70,
      child: Row(
        children: List.generate(
          titles.length,
          (i) => Expanded(
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                widget.controller.animateTo(i);
                setState(() {});
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImage.asset(images[i], color: i == widget.controller.index ? Color(0xff1E2A78) : Color(0xff9CA3AF), width: 20, height: 20),
                  SizedBox(height: 8),
                  AppText.labelMedium(
                    titles[i],
                    fontWeight: FontWeight.w300,
                    color: i == widget.controller.index ? Color(0xff1E2A78) : Color(0xff9CA3AF),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
