import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

class ClSelectableMenuFieldWidget extends StatelessWidget {
  const ClSelectableMenuFieldWidget({
    required this.value,
    required this.hint,
    required this.onTap,
    super.key,
  });

  final String? value;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: SharedPlatformColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SharedPlatformColors.border),
        ),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppText.bodySmall(
                hasValue ? value! : hint,
                color: hasValue
                    ? const Color(0xFF1F2937)
                    : const Color(0xFF9CA3AF),
                textAlign: TextAlign.start,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
