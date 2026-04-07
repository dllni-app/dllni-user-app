import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';

@AutoRoutePage(path: "/sm_address_map")
class SmAddressMapScreen extends StatelessWidget {
  const SmAddressMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: ColoredBox(color: Colors.grey)),
          Positioned(top: 0, child: _MapAppBar(title: "إضافة عنوان جديد")),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.paddingOf(context).bottom + 40,
              ),
              decoration: BoxDecoration(color: AppColors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "محافظة حلب , حلب",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 30 / 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  AppText(
                    "حي الحمدانية",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 30 / 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: context.width,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: AppText(
                        "تأكيد الموقع",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 30 / 16,
                        ),
                      ),
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

class _MapAppBar extends StatelessWidget {
  const _MapAppBar({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: EdgeInsets.fromLTRB(
        16,
        16 + MediaQuery.paddingOf(context).top,
        16,
        21,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: AppColors.primary, width: 2)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => context.pop(),
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: Ink(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: AppText(
                  title,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 37 / 20,
                  ),
                ),
              ),
              Ink(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  border: Border.all(color: Colors.transparent),
                ),
                child: FaIcon(
                  FontAwesomeIcons.arrowRight,
                  size: 12,
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _MapSearch(),
        ],
      ),
    );
  }
}

class _MapSearch extends StatelessWidget {
  const _MapSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 26 / 14,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        hintText: "ابحث عن الموقع ..",
        hintStyle: TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 26 / 14,
        ),
        filled: true,
        fillColor: Color(0xFFF9FAFB),
        prefixIconConstraints: BoxConstraints(maxWidth: 50),
        prefixIcon: Padding(
          padding: EdgeInsets.only(right: 16, left: 8),
          child: FaIcon(
            FontAwesomeIcons.magnifyingGlass,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
    );
  }
}
