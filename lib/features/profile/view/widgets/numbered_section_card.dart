import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';

/// V7 form grouping, keeping the public constructor for existing forms.
class NumberedSectionCard extends StatelessWidget {
  const NumberedSectionCard({
    super.key,
    required this.sectionNumber,
    required this.title,
    required this.child,
  });
  final String sectionNumber, title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE7EBF0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: SharedPlatformColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}
