import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

/// Keeps submission and back actions intact while matching shared foundations.
class ClServiceBottomActionsWidget extends StatelessWidget {
  const ClServiceBottomActionsWidget({
    required this.onBackPressed,
    required this.onSubmitPressed,
    super.key,
  });

  final VoidCallback onBackPressed;
  final VoidCallback? onSubmitPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: onSubmitPressed,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: SharedPlatformColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: AppText.bodyMedium(
              'أرسل الطلب',
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: onBackPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: SharedPlatformColors.primary,
              backgroundColor: SharedPlatformColors.surface,
              side: const BorderSide(color: SharedPlatformColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: AppText.bodyMedium(
              'تراجع',
              color: SharedPlatformColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
