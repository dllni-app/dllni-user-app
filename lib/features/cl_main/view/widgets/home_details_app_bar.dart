import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// Unified V6 booking header. Existing caller still controls navigation.
class HomeDetailsAppBar extends StatelessWidget {
  const HomeDetailsAppBar({
    super.key,
    this.onBack,
    this.title = 'تنظيف المنزل',
    this.subtitle = 'أكمل تفاصيل خدمتك خطوة بخطوة',
  });
  final VoidCallback? onBack;
  final String title, subtitle;

  @override
  Widget build(BuildContext context) => AppPageHeader(
    title: title,
    subtitle: subtitle,
    section: AppSection.cleaning,
    onBack: onBack ?? () => Navigator.of(context).maybePop(),
  );
}
