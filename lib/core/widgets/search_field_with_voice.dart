import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../themes/app_colors.dart';

class SearchFieldWithVoice extends StatelessWidget {
  const SearchFieldWithVoice({
    super.key,
    this.onTap,
    required this.onSearch,
    required this.onVoiceTap,
    this.controller,
    this.backgroundColor = const Color(0xFFF9FAFB),
    this.hintText,
    this.isListening = false,
  });
  final void Function(String search) onSearch;
  final void Function() onVoiceTap;
  final Color backgroundColor;
  final void Function()? onTap;
  final TextEditingController? controller;
  final String? hintText;
  final bool isListening;
  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: onTap,
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSearch,
      style: TextStyle(
        color: Color(0xFF111827),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 26 / 14,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 11),
        filled: true,
        fillColor: backgroundColor,
        hintText: hintText ?? "ابحث عن متجر أو منتج..",
        hintStyle: TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 26 / 14,
        ),
        prefixIconConstraints: BoxConstraints(maxWidth: 50),
        prefixIcon: Padding(
          padding: EdgeInsets.only(right: 16, left: 12),
          child: FaIcon(
            FontAwesomeIcons.magnifyingGlass,
            size: 18,
            color: Color(0xFF1E2A78),
          ),
        ),
        suffixIconConstraints: BoxConstraints(maxWidth: 44),
        suffixIcon: Padding(
          padding: EdgeInsets.only(left: 16),
          child: InkWell(
            onTap: onVoiceTap,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isListening
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: FaIcon(
                FontAwesomeIcons.microphone,
                size: 14,
                color: isListening ? Colors.red : AppColors.primary,
              ),
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
        ),
      ),
    );
  }
}
