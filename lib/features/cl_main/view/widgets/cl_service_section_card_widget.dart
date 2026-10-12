import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// Form grouping in V6; step belongs to the wizard, not each individual card.
class ClServiceSectionCardWidget extends StatelessWidget {
  const ClServiceSectionCardWidget({
    super.key,
    required this.title,
    required this.step,
    required this.child,
    this.subtitle,
    this.showStepBadge = true,
  });
  final String title;
  final String? subtitle;
  final int step;
  final Widget child;
  final bool showStepBadge;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    section: AppSection.cleaning,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeading(title: title, description: subtitle),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}
