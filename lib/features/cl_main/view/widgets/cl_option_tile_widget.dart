import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClOptionTileWidget extends StatelessWidget {
  const ClOptionTileWidget({required this.title, this.subtitle, required this.value, required this.onChanged, super.key});

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            activeColor: const Color(0xFF11B9C8),
            side: const BorderSide(color: Color(0xFFB9B9B9)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodySmall(title, textAlign: TextAlign.start, fontWeight: FontWeight.w600),
                if (subtitle != null) AppText.labelLarge(subtitle!, textAlign: TextAlign.start, color: const Color(0xFF8A8A8A)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
