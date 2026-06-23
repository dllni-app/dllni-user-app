import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../features/rs_discover/view/manager/bloc/rs_discover_bloc.dart';
import '../../features/sm_discover/view/widgets/smart_search_sheet.dart';
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

class RsAppSimpleAppBarWithSearch extends StatefulWidget {
  final String title;

  final void Function(String value)? onSearchChanged;
  final VoidCallback? onBackTap;
  final String searchHintText;
  final TextEditingController? searchController;
  final bool searchReadOnly;
  final bool isCategory;

  const RsAppSimpleAppBarWithSearch({
    super.key,
    required this.title,
    this.onBackTap,
    this.searchHintText = "ابحث عن مطعم أو وجبة...",
    this.searchController,
    this.searchReadOnly = false,
    this.isCategory = false,
    this.onSearchChanged,
  });

  @override
  State<RsAppSimpleAppBarWithSearch> createState() => _RsAppSimpleAppBarWithSearchState();
}

class _RsAppSimpleAppBarWithSearchState extends State<RsAppSimpleAppBarWithSearch> {
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
              if (widget.onBackTap != null) ...[
                InkWell(
                  onTap: widget.onBackTap,
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
                  widget.title,
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
                  hintText: widget.searchHintText,
                  onChanged: widget.onSearchChanged ?? _onSearchSubmitted,
                  onTap: widget.searchReadOnly ? _openSmartSearchSheet : null,
                  controller: widget.searchController,
                  readOnly: widget.searchReadOnly,
                ),
              ),
            ],
          ),
          if (!widget.isCategory) ...[
            const SizedBox(height: 12),
            BlocBuilder<RsDiscoverBloc, RsDiscoverState>(
              buildWhen: (p, c) => p.activeSearchMode != c.activeSearchMode,
              builder: (context, state) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _SearchModeChip(
                        label: "الوجبات",
                        icon: FontAwesomeIcons.bowlFood,
                        isSelected: state.activeSearchMode == RsDiscoverSearchMode.meal,
                        onTap: () => _onModeSelected(RsDiscoverSearchMode.meal),
                      ),
                      const SizedBox(width: 8),
                      _SearchModeChip(
                        label: "المطاعم",
                        icon: FontAwesomeIcons.store,
                        isSelected: state.activeSearchMode == RsDiscoverSearchMode.restaurant,
                        onTap: () => _onModeSelected(RsDiscoverSearchMode.restaurant),
                      ),
                      const SizedBox(width: 8),
                      _SearchModeChip(
                        label: "بحث ذكي",
                        icon: FontAwesomeIcons.microphone,
                        isSelected: state.activeSearchMode == RsDiscoverSearchMode.smart,
                        onTap: () => _onModeSelected(RsDiscoverSearchMode.smart),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _dispatchSearchForMode(String value, RsDiscoverSearchMode mode) {
    final bloc = context.read<RsDiscoverBloc>();
    if (mode == RsDiscoverSearchMode.restaurant) {
      bloc.add(DiscoverSearchQueryChangedEvent(value));
      return;
    }
    bloc.add(DiscoverProductSearchQueryChangedEvent(value, resultingMode: mode == RsDiscoverSearchMode.smart ? RsDiscoverSearchMode.smart : null));
  }

  Future<void> _openSmartSearchSheet() async {
    final words = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SmartSearchSheet(isSupermarket: false,),
    );
    if (!mounted || words == null || words.isEmpty) return;
    final query = words.join(' , ');
    setState(() {
      widget.searchController!.text = query;
      widget.searchController!.selection = TextSelection.collapsed(offset: query.length);
    });
    context.read<RsDiscoverBloc>().add(DiscoverProductSearchQueryChangedEvent(query, resultingMode: RsDiscoverSearchMode.smart));
  }

  void _onSearchSubmitted(String value) {
    final currentMode = context.read<RsDiscoverBloc>().state.activeSearchMode;
    _dispatchSearchForMode(value, currentMode);
  }

  void _onModeSelected(RsDiscoverSearchMode mode) {
    final bloc = context.read<RsDiscoverBloc>();
    bloc.add(DiscoverSearchModeChangedEvent(mode));
    if (mode == RsDiscoverSearchMode.smart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openSmartSearchSheet();
      });
      return;
    }
    _dispatchSearchForMode(widget.searchController!.text, mode);
  }
}

class _SearchModeChip extends StatelessWidget {
  const _SearchModeChip({required this.label, required this.icon, required this.isSelected, required this.onTap});

  final String label;
  final FaIconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: isSelected ? context.primary : const Color(0xFFDADCEA), borderRadius: BorderRadius.circular(24)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isSelected ? context.onPrimary.withValues(alpha: .24) : context.primary,
              child: FaIcon(icon, size: 12, color: isSelected ? context.onPrimary : Colors.white),
            ),
            const SizedBox(width: 8),
            AppText(
              label,
              style: TextStyle(color: isSelected ? context.onPrimary : context.primary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
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

  const _SearchField({required this.onChanged, this.onTap, required this.hintText, this.controller, this.readOnly = false});

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
