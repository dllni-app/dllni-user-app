import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// Unified V6 booking header. Existing caller still controls navigation.
class HomeDetailsAppBar extends StatelessWidget {
  const HomeDetailsAppBar({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => AppPageHeader(
    title: 'طلب تنظيف',
    subtitle: 'أكمل تفاصيل خدمتك خطوة بخطوة',
    section: AppSection.cleaning,
    onBack: onBack ?? () => Navigator.of(context).maybePop(),
  );
}
