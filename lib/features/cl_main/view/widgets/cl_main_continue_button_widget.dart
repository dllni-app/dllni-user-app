import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

/// Primary action across the cleaning booking flow. Callback remains caller-owned.
class ClMainContinueButtonWidget extends StatelessWidget {
  const ClMainContinueButtonWidget({
    required this.onPressed,
    this.label = 'متابعة',
    super.key,
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: SharedPlatformColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: AppText.bodyMedium(
          label,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
