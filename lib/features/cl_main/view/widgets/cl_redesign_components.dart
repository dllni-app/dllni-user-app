import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';

class ClRedesignStepHeader extends StatelessWidget {
  const ClRedesignStepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    this.subtitle,
  });

  final int currentStep;
  final int totalSteps;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps <= 0
        ? 0.0
        : (currentStep / totalSteps).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppText.labelLarge(
                title,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172033),
                ),
              ),
            ),
            AppText.labelSmall(
              '$currentStep من $totalSteps',
              style: const TextStyle(
                color: Color(0xFF667085),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          AppText.bodySmall(
            subtitle!,
            textAlign: TextAlign.start,
            style: const TextStyle(color: Color(0xFF667085), height: 1.45),
          ),
        ],
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE8ECF2),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF12B8C4)),
          ),
        ),
      ],
    );
  }
}

class ClRedesignCard extends StatelessWidget {
  const ClRedesignCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.selected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? const Color(0xFF12B8C4) : const Color(0xFFE7EAF0),
          width: selected ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D101828),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: card,
    );
  }
}

class ClRedesignCounter extends StatelessWidget {
  const ClRedesignCounter({
    super.key,
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.icon,
  });

  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ClRedesignCard(
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE9F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF0F8E98)),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: AppText.labelMedium(
              label,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.remove,
            onPressed: value > 0 ? onDecrement : null,
          ),
          SizedBox(
            width: 42,
            child: Center(
              child: AppText.labelLarge(
                '$value',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172033),
                ),
              ),
            ),
          ),
          _CounterButton(icon: Icons.add, onPressed: onIncrement),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: onPressed == null
              ? const Color(0xFFF3F4F6)
              : AppColors.primary,
          foregroundColor: onPressed == null
              ? const Color(0xFF98A2B3)
              : Colors.white,
        ),
      ),
    );
  }
}

class ClRedesignStickyActions extends StatelessWidget {
  const ClRedesignStickyActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.primaryEnabled = true,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool primaryEnabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE7EAF0))),
        ),
        child: Row(
          children: [
            if (secondaryLabel != null) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: onSecondary,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: Color(0xFFD0D5DD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(secondaryLabel!),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: secondaryLabel == null ? 1 : 2,
              child: FilledButton(
                onPressed: primaryEnabled ? onPrimary : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  primaryLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClRedesignSegmentedChoice<T> extends StatelessWidget {
  const ClRedesignSegmentedChoice({
    super.key,
    required this.values,
    required this.selected,
    required this.labelFor,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < values.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onChanged(values[index]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                constraints: const BoxConstraints(minHeight: 46),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected == values[index]
                      ? const Color(0xFFE9F9FA)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected == values[index]
                        ? const Color(0xFF12B8C4)
                        : const Color(0xFFD0D5DD),
                  ),
                ),
                child: Text(
                  labelFor(values[index]),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected == values[index]
                        ? const Color(0xFF0B7480)
                        : const Color(0xFF344054),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
