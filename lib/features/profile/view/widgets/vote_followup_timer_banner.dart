import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'dart:ui' as ui;

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class VoteFollowupTimerBanner extends StatelessWidget {
  const VoteFollowupTimerBanner({super.key, required this.formattedTime});

  final String formattedTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: AppText.displayMedium(
        formattedTime,
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
        color: SharedPlatformColors.restaurant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
