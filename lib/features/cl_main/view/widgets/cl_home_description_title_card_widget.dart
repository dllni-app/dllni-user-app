import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClHomeDescriptionTitleCardWidget extends StatelessWidget {
  const ClHomeDescriptionTitleCardWidget({required this.title, required this.subtitle, required this.step, super.key, required this.child});

  final String title;
  final String subtitle;
  final int step;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            spacing: 14,
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFF11B9C8),
                child: AppText.labelLarge('$step', color: Colors.white, fontWeight: FontWeight.w700),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMedium(title, textAlign: TextAlign.start, fontWeight: FontWeight.w700, color: const Color(0xFF242424)),
                    const SizedBox(height: 3),
                    AppText.labelLarge(subtitle, textAlign: TextAlign.start, color: const Color(0xFF8A8A8A)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Color(0xffF3F4F6), thickness: 1),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
