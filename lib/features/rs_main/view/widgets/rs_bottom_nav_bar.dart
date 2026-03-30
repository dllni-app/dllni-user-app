import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../generated/assets.dart';

class RsBottomNavBar extends StatefulWidget {
  const RsBottomNavBar({super.key, required this.controller});

  final TabController controller;

  @override
  State<RsBottomNavBar> createState() => _RsBottomNavBarState();
}

class _RsBottomNavBarState extends State<RsBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    List<Widget> images(int i) => [
      Assets.images.rsHomeBottomNavBar.svg(color: widget.controller.index == i ? context.primary : Color(0xff9CA3AF), width: 20, height: 20),
      Assets.images.rsDiscoverBottomNavBar.svg(color: widget.controller.index == i ? context.primary : Color(0xff9CA3AF), width: 20, height: 20),
      Assets.images.rsOffersBottomNavBar.svg(color: widget.controller.index == i ? context.primary : Color(0xff9CA3AF), width: 20, height: 20),
      Assets.images.rsOrdersBottomNavBar.image(color: widget.controller.index == i ? context.primary : Color(0xff9CA3AF), width: 20, height: 20),
      Assets.images.rsProfileBottomNavBar.svg(color: widget.controller.index == i ? context.primary : Color(0xff9CA3AF), width: 20, height: 20),
    ];

    List<String> titles = ['الرئيسية', 'اكتشف', 'العروض', 'طلباتي', 'حسابي'];

    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(27), offset: Offset(0, -2), blurRadius: 12, spreadRadius: 0)],
      ),
      width: context.width,
      height: 65,
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (widget.controller.index == i) ...{
                    SizedBox(height: 2),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), color: context.primary),
                      height: 4,
                      width: 40,
                    ).animate(delay: Duration(milliseconds: 200)).fade(),
                    SizedBox(height: 8),
                  },
                  if (widget.controller.index != i) ...{SizedBox(height: 14)},
                  images(i)[i],
                  SizedBox(height: 4),
                  AppText.labelMedium(
                    titles[i],
                    fontWeight: FontWeight.bold,
                    color: widget.controller.index == i ? context.primary : Color(0xff9CA3AF),
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
