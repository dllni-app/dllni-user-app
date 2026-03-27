import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class FailureWidget extends StatelessWidget {
  const FailureWidget({super.key, required this.message, this.onRetry});
  final String message;
  final void Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final errorMessage = message.length > 200
        ? "${message.substring(0, 200)} ..."
        : message;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText.labelMedium(errorMessage),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            foregroundColor: AppColors.white,
          ),
          child: AppText.labelMedium(
            "إعادة المحاولة",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}
