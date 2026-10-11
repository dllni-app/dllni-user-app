import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: Text(
      title,
      textAlign: TextAlign.start,
      style: const TextStyle(
        color: SharedPlatformColors.primary,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}
