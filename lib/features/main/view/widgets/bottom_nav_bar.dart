import 'package:common_package/common_package.dart';
import 'package:common_package/extensions/size_extensions.dart';
import 'package:dllni_user_app/core/auth/auth_gate.dart';
import 'package:flutter/material.dart';

import '../../../../generated/assets.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key, required this.controller});

  final TabController controller;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _selectTab(int index) {
    widget.controller.animateTo(index);
    setState(() {});
  }

  Future<void> _onTabTap(int index) async {
    if (index == 1) {
      await AuthGate.requireAuth(
        context,
        onAuthenticated: () => _selectTab(index),
        message: 'سجّل الدخول لعرض طلباتك',
      );
      return;
    }

    _selectTab(index);
  }

  @override
  Widget build(BuildContext context) {
    List<String> titles = ['الرئيسية', 'طلباتي', 'حسابي'];
    List<String> images = [Assets.images.mainHome.path, Assets.images.mainOrders.path, Assets.images.mainProfile.path];

    return Container(
      padding: EdgeInsets.only(bottom: context.navigationBarHeight,top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(27), offset: Offset(0, -2), blurRadius: 12, spreadRadius: 0)],
      ),
      width: context.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(
              titles.length,
              (i) => Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => _onTabTap(i),
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
        ],
      ),
    );
  }
}
