import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppSimpleAppBar extends StatelessWidget {
  const AppSimpleAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      decoration: BoxDecoration(
        color: context.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [BoxShadow(offset: Offset(0, 4), blurRadius: 7.3, color: Color(0x40000000))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          AppText(
            title,
            style: TextStyle(color: context.onPrimary, fontWeight: FontWeight.w500, fontSize: 20),
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
    this.onSearchTap,
    this.searchHintText = "ابحث عن سوبر ماركت أو نوع منتج معين...",
  });

  final String title;
  final void Function(String value) onSearchChanged;
  final void Function()? onSearchTap;
  final String searchHintText;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light, statusBarBrightness: Brightness.dark));
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
          AppText(
            title,
            style: TextStyle(color: context.primary, fontSize: 24, fontWeight: FontWeight.w700, height: 32 / 24),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SearchField(hintText: searchHintText, onChanged: onSearchChanged, onTap: onSearchTap),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged, this.onTap, required this.hintText});

  final void Function(String value) onChanged;
  final void Function()? onTap;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: context.primary,
          selectionColor: context.primary.withValues(alpha: 0.3),
          selectionHandleColor: context.primary,
        ),
      ),
      child: TextField(
        style: TextStyle(fontSize: 15, color: Color(0xff9CA3AF)),
        onTap: onTap,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.w500, fontSize: 12, color: Color(0xff9CA3AF)),
          filled: true,
          fillColor: context.surface,
          contentPadding: EdgeInsets.fromLTRB(16, 14, 44, 13),
          prefixIconConstraints: BoxConstraints(maxWidth: 44),
          prefixIcon: Padding(
            padding: EdgeInsets.only(right: 16, left: 8),
            child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16, color: Color(0xff9CA3AF)),
          ),
          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(24))),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(24))),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(24))),
        ),
        onSubmitted: onChanged,
      ),
    );
  }
}
