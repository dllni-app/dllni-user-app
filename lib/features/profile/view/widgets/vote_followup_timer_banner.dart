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
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        color: context.primaryContainer,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
