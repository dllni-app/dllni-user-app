import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class OrderVotingModeButton extends StatelessWidget {
  const OrderVotingModeButton({
    super.key,
    required this.title,
    required this.isActive,
    required this.onTap,
    this.activeColor = const Color(0xFF6C63FF),
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isActive ? activeColor : context.onPrimary,
        ),
        child: AppText.labelLarge(
          title,
          textAlign: TextAlign.center,
          color: isActive ? context.onPrimary : const Color(0xff6B7280),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
