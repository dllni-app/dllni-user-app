import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

/// White card with orange numbered circle and section title.
class RsNumberedSectionCard extends StatelessWidget {
  const RsNumberedSectionCard({
    super.key,
    required this.sectionNumber,
    required this.title,
    required this.child,
  });

  final String sectionNumber;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accent = context.primaryContainer;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), offset: const Offset(0, 4), blurRadius: 18, spreadRadius: -2)],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: accent,
                radius: 15,
                child: AppText.labelLarge(sectionNumber, color: context.onPrimary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),
              AppText.titleMedium(title, color: accent, fontWeight: FontWeight.w700),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
