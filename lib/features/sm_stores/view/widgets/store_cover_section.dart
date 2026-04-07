import 'dart:ui';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';

class StoreCoverSection extends StatelessWidget {
  const StoreCoverSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280 + MediaQuery.paddingOf(context).top,
      child: Stack(
        children: [
          Positioned.fill(
            child: AppImage.asset(AppImages.store, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0x99000000),
                    Color(0x33000000),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            right: 16,
            child: _ActionButton(
              icon: FontAwesomeIcons.arrowRight,
              onTap: () => context.pop(),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 16,
            child: Row(
              children: [
                _ActionButton(
                  icon: FontAwesomeIcons.solidHeart,
                  color: Color(0xFFCF0E0E),
                  onTap: () {},
                ),
                SizedBox(width: 8),
                _ActionButton(icon: FontAwesomeIcons.shareNodes, onTap: () {}),
              ],
            ),
          ),
          Positioned(
            right: 16,
            left: 16,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: AppImage.asset(AppImages.avatar, fit: BoxFit.contain),
                ),
                SizedBox(width: 12),
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        "سوبر ماركت النور",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 32 / 24,
                        ),
                      ),
                      AppText(
                        "فرع العلياء",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 20 / 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: GestureDetector(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xE5FFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Icon(
                      Icons.fullscreen,
                      size: 22,
                      color: Color(0xFF1F2937),
                    ),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap, this.color});
  final FaIconData icon;
  final Color? color;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: -2,
              color: Color(0x1A000000),
            ),
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 6,
              spreadRadius: -1,
              color: Color(0x1A000000),
            ),
          ],
        ),
        child: FaIcon(icon, size: 18, color: color ?? Color(0xFF1F2937)),
      ),
    );
  }
}
