import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/app_colors.dart';
import '../utils/app_images.dart';

class AppSimpleAppBar extends StatelessWidget {
  const AppSimpleAppBar({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      width: width,
      padding: EdgeInsets.fromLTRB(
        16,
        16 + MediaQuery.paddingOf(context).top,
        16,
        32,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 7.3,
            color: Color(0x40000000),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          // const ArrowBackButton(),
          AppText(
            title,
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class AppSimpleAppBarWithSearch extends StatelessWidget {
  const AppSimpleAppBarWithSearch({
    super.key,
    required this.title,
    required this.onSearchChanged,
    required this.onFilterTap,
  });
  final String title;
  final void Function(String value) onSearchChanged;
  final void Function() onFilterTap;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Container(
      width: context.width,
      padding: EdgeInsets.fromLTRB(
        16,
        16 + MediaQuery.paddingOf(context).top,
        16,
        20,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title,
            style: textTheme.titleSmall!.copyWith(
              color: AppColors.white,
              fontSize: 20,
            ),
          ),
          //  TextStyle(fontSize: 24, color: context.primary, fontWeight: FontWeight.w700)),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SearchField(
                  hintText: "ابحث عن سوبر ماركت أو نوع منتج معين...",
                  onChanged: onSearchChanged,
                ),
              ),
              SizedBox(width: 12),
              _FilterButton(onTap: onFilterTap),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap});
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(24)),
      child: Container(
        alignment: Alignment.center,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          // color: context.primary,
          gradient: LinearGradient(
            colors: [const Color(0x996C63FF), AppColors.primary],
            stops: [.3, .9],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: AppImage.asset(AppImages.filter, width: 16, height: 16),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged, required this.hintText});
  final void Function(String value) onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: "Cairo",
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: AppColors.white,
        ),
        filled: true,
        fillColor: AppColors.filledInputBackgroundColor,
        contentPadding: EdgeInsets.fromLTRB(16, 14, 44, 13),
        prefixIcon: Padding(
          padding: EdgeInsets.only(right: 12),
          child: AppImage.asset(
            AppImages.search,
            size: 16,
            color: AppColors.white,
          ),
        ),
        // prefixIcon: Icon(Icons.search, size: 32),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      onSubmitted: onChanged,
    );
  }
}
