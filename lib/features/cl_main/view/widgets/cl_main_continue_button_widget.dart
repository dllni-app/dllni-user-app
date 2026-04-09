import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

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
          backgroundColor: const Color(0xFF11B9C8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        child: AppText.bodyMedium(
          label,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
