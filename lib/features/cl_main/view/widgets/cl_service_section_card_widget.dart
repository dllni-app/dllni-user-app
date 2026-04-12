import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClServiceSectionCardWidget extends StatelessWidget {
  const ClServiceSectionCardWidget({
    required this.title,
    required this.step,
    required this.child,
    this.subtitle,
    this.showStepBadge = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final int step;
  final Widget child;
  final bool showStepBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              if (showStepBadge) ...[
                CircleAvatar(
                  radius: 15,
                  backgroundColor: const Color(0xFF11B9C8),
                  child: AppText.bodyMedium(
                    '$step',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.headlineSmall(
                      title,
                      color: const Color(0xFF11B9C8),
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.start,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      AppText.bodySmall(
                        subtitle!,
                        color: const Color(0xFF6B7280),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
