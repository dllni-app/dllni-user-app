import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';

class CartSimpleAppBar extends StatelessWidget {
  const CartSimpleAppBar({super.key, this.backTo, required this.title});
  final String? backTo;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Ink(
          width: context.width,
          padding: EdgeInsets.fromLTRB(
            16,
            16 + MediaQuery.paddingOf(context).top,
            16,
            16,
          ),
          decoration: BoxDecoration(color: AppColors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => context.pop(),
                customBorder: CircleBorder(),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Ink(
                      child: FaIcon(
                        FontAwesomeIcons.arrowRight,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              AppText(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 32 / 16,
                ),
              ),
              SizedBox(width: 44, height: 44),
            ],
          ),
        ),
        if (backTo != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            color: Color(0xFFEBEBEB),
            child: Row(
              children: [
                CircleAvatar(radius: 19, backgroundColor: Color(0xFFD9D9D9)),
                SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "العودة إلى ",
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                        TextSpan(text: backTo),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 32 / 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
