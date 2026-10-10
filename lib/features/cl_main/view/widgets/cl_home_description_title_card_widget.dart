import 'package:flutter/material.dart';

import 'cl_service_section_card_widget.dart';

/// Compatibility wrapper for the existing multi-step home description flow.
class ClHomeDescriptionTitleCardWidget extends StatelessWidget {
  const ClHomeDescriptionTitleCardWidget({
    required this.title,
    required this.subtitle,
    required this.step,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final int step;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClServiceSectionCardWidget(
      title: title,
      subtitle: subtitle,
      step: step,
      child: child,
    );
  }
}
