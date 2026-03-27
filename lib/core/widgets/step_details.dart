import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class StepDetails extends StatelessWidget {
  const StepDetails({
    super.key,
    required this.number,
    required this.title,
    required this.child,
    this.leading,
  });
  final int number;
  final String title;
  final Widget child;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.all(Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 20,
            spreadRadius: -2,
            color: const Color(0x0D000000),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.accent,
                child: AppText(
                  number.toString(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.42,
                  ),
                ),
              ),
              SizedBox(width: 12),
              AppText(
                title,
                style: TextStyle(
                  color: context.primaryContainer,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.555,
                ),
              ),
              Spacer(),
              ?leading,
            ],
          ),
          SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
