import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';
import 'cl_service_section_card_widget.dart';

class ClServiceWorkerCountSelectorWidget extends StatelessWidget {
  // Backend contract: numberOfWorkers has a maximum of 20.
  static const int maxSupportedWorkers = 20;

  const ClServiceWorkerCountSelectorWidget({
    required this.count,
    required this.maxCount,
    required this.onChanged,
    super.key,
  });

  final int count;
  final int maxCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeMax = maxCount.clamp(1, maxSupportedWorkers);
    final safeCount = count.clamp(1, safeMax);

    return ClServiceSectionCardWidget(
      title: 'عدد العمال المطلوب',
      step: 0,
      showStepBadge: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodySmall(
            'الحد الأقصى $safeMax عامل (حسب عدد الغرف والمساحات)',
            color: SharedPlatformColors.muted,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepButton(
                icon: Icons.remove,
                enabled: safeCount > 1,
                onTap: () => onChanged(safeCount - 1),
              ),
              const SizedBox(width: 20),
              Container(
                width: 72,
                height: 64,
                decoration: BoxDecoration(
                  color: SharedPlatformColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SharedPlatformColors.border),
                ),
                alignment: Alignment.center,
                child: AppText.headlineSmall(
                  '$safeCount',
                  color: SharedPlatformColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 20),
              _StepButton(
                icon: Icons.add,
                enabled: safeCount < safeMax,
                onTap: () => onChanged(safeCount + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? SharedPlatformColors.cleaningSoft
          : SharedPlatformColors.neutralSoft,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: enabled
                ? SharedPlatformColors.cleaningInk
                : SharedPlatformColors.subtle,
          ),
        ),
      ),
    );
  }
}
