import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';

class ProductsBottomNavBar extends StatefulWidget {
  const ProductsBottomNavBar({super.key, required this.onChanged});
  final void Function(int quantity) onChanged;

  @override
  State<ProductsBottomNavBar> createState() => _ProductsBottomNavBarState();
}

class _ProductsBottomNavBarState extends State<ProductsBottomNavBar> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
            children: [
              IconButton(
                icon: FaIcon(FontAwesomeIcons.minus, size: 24),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 5.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  foregroundColor: Color(0xFF374151),
                  backgroundColor: Color(0xFFF3F4F6),
                  fixedSize: Size(32, 32),
                ),
                onPressed: () {
                  if (quantity == 1) return;
                  quantity = quantity - 1;
                  setState(() {});
                  widget.onChanged(quantity);
                },
              ),
              SizedBox(
                width: 80,
                child: AppText(
                  quantity.toString(),
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    height: 40 / 36,
                  ),
                ),
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.plus, size: 24),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 5.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  foregroundColor: AppColors.white,
                  backgroundColor: AppColors.accent,
                  fixedSize: Size(32, 32),
                ),
                onPressed: () {
                  quantity = quantity + 1;
                  setState(() {});
                  widget.onChanged(quantity);
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.all(Radius.circular(12)),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.all(Radius.circular(12)),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 4),
                    blurRadius: 6,
                    spreadRadius: -4,
                    color: Color(0x1A000000),
                  ),
                  BoxShadow(
                    offset: Offset(0, 10),
                    blurRadius: 15,
                    spreadRadius: -3,
                    color: Color(0x1A000000),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  FaIcon(
                    FontAwesomeIcons.cartShopping,
                    size: 16,
                    color: Colors.white,
                  ),
                  AppText(
                    "إضافة إلى السلة",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 24 / 15,
                    ),
                  ),
                  AppText(
                    "95 ل.س",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                      height: 24 / 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
