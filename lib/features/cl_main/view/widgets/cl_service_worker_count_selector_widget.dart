import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'cl_service_section_card_widget.dart';

class ClServiceWorkerCountSelectorWidget extends StatelessWidget {
  const ClServiceWorkerCountSelectorWidget({
    required this.count,
    required this.maxCount,
    required this.onChanged,
    super.key,
  });

  static const Color _screenBlue = Color(0xFF1E2A78);

  final int count;
  final int maxCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeMax = maxCount < 1 ? 1 : maxCount;
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
            color: const Color(0xFF6B7280),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepButton(
                icon: Icons.remove,
                enabled: safeCount > 1,
                onTap: () => onChanged(safeCount - 1),
              ),
              const SizedBox(width: 24),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _screenBlue, width: 2),
                ),
                alignment: Alignment.center,
                child: AppText.headlineSmall(
                  '$safeCount',
                  color: _screenBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 24),
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
          ? ClServiceWorkerCountSelectorWidget._screenBlue
          : const Color(0xFFE5E7EB),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: enabled ? Colors.white : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
