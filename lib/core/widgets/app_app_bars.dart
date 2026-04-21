import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../themes/app_colors.dart';
import 'search_with_type_dropdown.dart';

class AppSimpleAppBar extends StatelessWidget {
  final String title;

  final bool canPop;

  const AppSimpleAppBar({super.key, required this.title, this.canPop = true});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light, statusBarBrightness: Brightness.dark));
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      width: width,
      padding: EdgeInsets.fromLTRB(16, 16 + MediaQuery.paddingOf(context).top, 16, 32),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [BoxShadow(offset: Offset(0, 4), blurRadius: 7.3, color: Color(0x40000000))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          if (canPop) const ArrowBackButton(),
          AppText(
            title,
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class AppSimpleAppBar2 extends StatelessWidget {
  final String title;
  final bool centerTitle;
  final bool canPop;
  final ArrowBackType arrowBackType;

  const AppSimpleAppBar2({super.key, required this.title, this.centerTitle = false, this.arrowBackType = ArrowBackType.material, this.canPop = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Ink(
          width: context.width,
          padding: EdgeInsets.fromLTRB(16, 16 + MediaQuery.paddingOf(context).top, 16, 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            border: Border(bottom: BorderSide(color: AppColors.primary, width: 2)),
            boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0D000000))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (arrowBackType == ArrowBackType.material && canPop)
                InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: Ink(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      border: Border.all(color: AppColors.primary.withValues(alpha: .16)),
                    ),
                    child: FaIcon(FontAwesomeIcons.arrowRight, size: 16, color: Colors.black),
                  ),
                ),
              if (arrowBackType == ArrowBackType.cupertino && canPop)
                InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: Ink(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    child: Icon(Icons.arrow_back_ios_rounded, size: 22, color: Colors.black),
                  ),
                ),
              SizedBox(width: 16),
              Expanded(
                child: AppText(
                  title,
                  textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w700, height: 32 / 24),
                ),
              ),
              Ink(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  border: Border.all(color: Colors.transparent),
                ),
                child: FaIcon(FontAwesomeIcons.arrowRight, size: 12, color: Colors.transparent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AppSimpleAppBarWithSearch extends StatelessWidget {
  final String title;

  final bool isSearchExpand;
  final void Function(SearchType type) onTypeSelected;

  const AppSimpleAppBarWithSearch({super.key, required this.title, this.isSearchExpand = false, required this.onTypeSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: EdgeInsets.fromLTRB(16, 16 + MediaQuery.paddingOf(context).top, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0D000000))],
        border: Border(bottom: BorderSide(color: AppColors.primary, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title,
            style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w700, height: 32 / 24),
          ),
          SizedBox(height: 16),
          SearchWithTypeDropdown(onTypeSelected: onTypeSelected, isExpanded: isSearchExpand),
        ],
      ),
    );
  }
}

class ArrowBackButton extends StatelessWidget {
  const ArrowBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pop(),
      borderRadius: BorderRadius.all(Radius.circular(12)),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(12),
        // decoration: BoxDecoration(
        //   color: Color(0xFFF9FAFB),
        //   borderRadius: BorderRadius.all(Radius.circular(12)),
        //   border: Border.all(color: Color(0x291E2A78)),
        // ),
        child: Icon(Icons.arrow_back_ios, size: 16, color: AppColors.white),
        //AppImage.asset(AppSvgs.arrow, size: 16, color: AppColors.white),
      ),
    );
  }
}

enum ArrowBackType { material, cupertino }

class RsAppSimpleAppBarWithSearch extends StatelessWidget {
  final String title;

  final void Function(String value) onSearchChanged;
  final void Function()? onSearchTap;
  final VoidCallback? onBackTap;
  final String searchHintText;
  final TextEditingController? searchController;
  final bool searchReadOnly;

  const RsAppSimpleAppBarWithSearch({
    super.key,
    required this.title,
    required this.onSearchChanged,
    this.onSearchTap,
    this.onBackTap,
    this.searchHintText = "ابحث عن مطعم أو وجبة...",
    this.searchController,
    this.searchReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: EdgeInsets.fromLTRB(16, 16 + MediaQuery.paddingOf(context).top, 16, 20),
      decoration: BoxDecoration(
        color: context.onPrimary,
        border: Border(bottom: BorderSide(color: context.primaryContainer, width: 2)),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0D000000))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBackTap != null) ...[
                InkWell(
                  onTap: onBackTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Icon(Icons.arrow_back, size: 18, color: context.primary),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: AppText(
                  title,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: context.primary, fontSize: 24, fontWeight: FontWeight.w700, height: 32 / 24),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SearchField(
                  hintText: searchHintText,
                  onChanged: onSearchChanged,
                  onTap: onSearchTap,
                  controller: searchController,
                  readOnly: searchReadOnly,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final void Function(String value) onChanged;

  final void Function()? onTap;
  final String hintText;
  final TextEditingController? controller;
  final bool readOnly;

  const _SearchField({
    required this.onChanged,
    this.onTap,
    required this.hintText,
    this.controller,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(fontSize: 15, color: Colors.black),
      onTap: onTap,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.w500, fontSize: 12, color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: Color(0x0F2F2B3D),
        contentPadding: EdgeInsets.fromLTRB(16, 14, 44, 13),
        prefixIconConstraints: BoxConstraints(maxWidth: 44),
        prefixIcon: Padding(
          padding: EdgeInsets.only(right: 16, left: 12),
          child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16, color: Color(0xFF9CA3AF)),
        ),
        // prefixIcon: Icon(Icons.search, size: 32),
        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(24))),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(24))),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(24))),
      ),
      onSubmitted: onChanged,
    );
  }
}
