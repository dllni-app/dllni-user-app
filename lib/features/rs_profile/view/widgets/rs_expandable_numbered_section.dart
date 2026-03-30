import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class RsExpandableNumberedSection extends StatelessWidget {
  const RsExpandableNumberedSection({
    super.key,
    required this.sectionNumber,
    required this.title,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.child,
  });

  final String sectionNumber;
  final String title;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accent = context.primaryContainer;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: context.onPrimary,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), offset: const Offset(0, 4), blurRadius: 18, spreadRadius: -2)],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onHeaderTap,
            borderRadius: BorderRadius.circular(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: accent,
                  radius: 15,
                  child: AppText.labelLarge(sectionNumber, color: context.onPrimary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText.titleMedium(title, color: accent, fontWeight: FontWeight.w700, textAlign: TextAlign.start),
                ),
                const SizedBox(width: 10),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xff9CA3AF)),
              ],
            ),
          ),
          if (isExpanded) ...[const SizedBox(height: 16), child],
        ],
      ),
    );
  }
}
