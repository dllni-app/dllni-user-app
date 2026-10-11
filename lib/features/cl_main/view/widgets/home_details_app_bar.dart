import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';

/// Compact booking header. The hosting screens already use SafeArea, so the
/// status bar inset must not be added a second time.
class HomeDetailsAppBar extends StatelessWidget {
  const HomeDetailsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 12, 12),
      decoration: const BoxDecoration(
        color: SharedPlatformColors.surface,
        border: Border(
          bottom: BorderSide(color: SharedPlatformColors.cleaning, width: 2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'طلب تنظيف',
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: SharedPlatformColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'الرجوع',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: SharedPlatformColors.primary,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
    );
  }
}
