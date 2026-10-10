import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

class ClCounterRowWidget extends StatelessWidget {
  const ClCounterRowWidget({
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    required this.icon,
    super.key,
  });

  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: SharedPlatformColors.cleaningSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 21, color: SharedPlatformColors.cleaningInk),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppText.bodyMedium(
            label,
            textAlign: TextAlign.start,
            color: SharedPlatformColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        _StepControl(
          icon: Icons.remove,
          enabled: value > 0,
          onPressed: onDecrement,
        ),
        SizedBox(
          width: 40,
          child: Center(
            child: AppText.bodyLarge(
              '$value',
              color: SharedPlatformColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _StepControl(icon: Icons.add, onPressed: onIncrement),
      ],
    );
  }
}

class _StepControl extends StatelessWidget {
  const _StepControl({
    required this.icon,
    required this.onPressed,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? SharedPlatformColors.cleaningSoft
          : SharedPlatformColors.neutralSoft,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 21,
            color: enabled
                ? SharedPlatformColors.cleaningInk
                : SharedPlatformColors.subtle,
          ),
        ),
      ),
    );
  }
}
