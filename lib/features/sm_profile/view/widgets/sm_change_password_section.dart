import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'rs_filled_text_field.dart';

class SmChangePasswordSection extends StatelessWidget {
  const SmChangePasswordSection({
    super.key,
    required this.currentController,
    required this.newController,
    required this.confirmController,
    required this.obscureCurrent,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onToggleConfirm,
    this.passwordMismatch,
    this.onPasswordChanged,
  });

  final TextEditingController currentController;
  final TextEditingController newController;
  final TextEditingController confirmController;
  final bool obscureCurrent;
  final bool obscureNew;
  final bool obscureConfirm;
  final VoidCallback onToggleCurrent;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final bool? passwordMismatch;
  final VoidCallback? onPasswordChanged;

  @override
  Widget build(BuildContext context) {
    final mismatch = passwordMismatch == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RsFilledTextField(
          label: 'كلمة المرور الحالية',
          controller: currentController,
          obscureText: obscureCurrent,
          onChanged: (_) => onPasswordChanged?.call(),
          suffixIcon: IconButton(
            icon: Icon(
              obscureCurrent
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xff6B7280),
            ),
            onPressed: onToggleCurrent,
          ),
        ),
        const SizedBox(height: 14),
        RsFilledTextField(
          label: 'كلمة المرور الجديدة',
          controller: newController,
          obscureText: obscureNew,
          hasError: mismatch,
          onChanged: (_) => onPasswordChanged?.call(),
          suffixIcon: IconButton(
            icon: Icon(
              obscureNew
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xff6B7280),
            ),
            onPressed: onToggleNew,
          ),
        ),
        const SizedBox(height: 14),
        RsFilledTextField(
          label: 'تأكيد كلمة المرور',
          controller: confirmController,
          obscureText: obscureConfirm,
          hasError: mismatch,
          onChanged: (_) => onPasswordChanged?.call(),
          suffixIcon: IconButton(
            icon: Icon(
              obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xff6B7280),
            ),
            onPressed: onToggleConfirm,
          ),
        ),
        if (mismatch) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: context.error),
              const SizedBox(width: 6),
              Expanded(
                child: AppText.bodySmall(
                  'كلمة المرور غير متطابقة',
                  color: context.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
