import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// V6 booking primitives. Business state and limits stay in each calling screen.
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(title, style: AlnadhaTokens.title)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppSection.cleaning.soft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '$currentStep / $totalSteps',
              textDirection: TextDirection.ltr,
              style: AlnadhaTokens.caption.copyWith(
                color: AppSection.cleaning.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 6),
        Text(subtitle!, style: AlnadhaTokens.caption),
      ],
      const SizedBox(height: 16),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: totalSteps > 0
              ? (currentStep / totalSteps).clamp(0.0, 1.0)
              : 0.0,
          minHeight: 6,
          backgroundColor: AlnadhaTokens.border,
          color: AppSection.cleaning.accent,
          semanticsLabel: 'تقدم الحجز',
        ),
      ),
    ],
  );
}

/// V6 replaces the old shadowed rectangular card with the shared surface.
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
  Widget build(BuildContext context) => AppSurfaceCard(
    padding: padding,
    section: AppSection.cleaning,
    selected: selected,
    onTap: onTap,
    child: child,
  );
}

class ClRedesignCounter extends StatelessWidget {
  const ClRedesignCounter({
    super.key,
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.maxValue,
    this.icon,
  });
  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int? maxValue;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    section: AppSection.cleaning,
    child: Row(
      children: [
        if (icon != null) ...[
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppSection.cleaning.soft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppSection.cleaning.ink, size: 22),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(child: Text(label, style: AlnadhaTokens.body)),
        IconButton(
          tooltip: 'تقليل العدد',
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          onPressed: value > 0 ? onDecrement : null,
          icon: const Icon(Icons.remove_circle_outline_rounded),
          color: AppSection.cleaning.ink,
        ),
        SizedBox(
          width: 30,
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: AlnadhaTokens.sectionTitle,
          ),
        ),
        IconButton(
          tooltip: 'زيادة العدد',
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          onPressed: maxValue == null || value < maxValue! ? onIncrement : null,
          icon: const Icon(Icons.add_circle_outline_rounded),
          color: AppSection.cleaning.ink,
        ),
      ],
    ),
  );
}

/// Back action and primary share one safe-area footer on every booking route.
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
  Widget build(BuildContext context) => AppBottomActionBar(
    child: Row(
      children: [
        if (secondaryLabel != null) ...[
          Expanded(
            child: AppActionButton(
              label: secondaryLabel!,
              variant: AppActionVariant.outlined,
              onPressed: onSecondary,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          flex: secondaryLabel == null ? 1 : 2,
          child: AppActionButton(
            label: primaryLabel,
            onPressed: primaryEnabled ? onPrimary : null,
          ),
        ),
      ],
    ),
  );
}

/// Room-size choice returns the original enum value without state duplication.
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
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 0; index < values.length; index++) ...[
        if (index > 0) const SizedBox(width: 8),
        Expanded(
          child: Semantics(
            button: true,
            selected: selected == values[index],
            label: labelFor(values[index]),
            child: Material(
              color: selected == values[index]
                  ? AppSection.cleaning.soft
                  : AlnadhaTokens.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => onChanged(values[index]),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minHeight: 58),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected == values[index]
                          ? AppSection.cleaning.accent
                          : AlnadhaTokens.border,
                    ),
                  ),
                  child: Text(
                    labelFor(values[index]),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AlnadhaTokens.body.copyWith(
                      fontSize: 13,
                      color: selected == values[index]
                          ? AppSection.cleaning.ink
                          : AlnadhaTokens.ink,
                      fontWeight: selected == values[index]
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ],
  );
}
