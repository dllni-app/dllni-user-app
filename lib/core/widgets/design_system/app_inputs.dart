import 'package:flutter/material.dart';
import 'alnadha_tokens.dart';
import 'app_layout.dart';

/// Selection styling only. Caller holds the selected domain value.
class AppChoiceTile extends StatelessWidget {
  const AppChoiceTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.description,
    this.icon,
    this.section = AppSection.cleaning,
    this.enabled = true,
  });
  final String title;
  final String? description;
  final IconData? icon;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  final AppSection section;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    enabled: enabled && onTap != null,
    child: Opacity(
      opacity: enabled ? 1 : .5,
      child: AppSurfaceCard(
        selected: selected,
        section: section,
        onTap: enabled ? onTap : null,
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: selected ? section.ink : AlnadhaTokens.muted),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AlnadhaTokens.sectionTitle),
                  if (description != null)
                    Text(description!, style: AlnadhaTokens.caption),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? section.ink : AlnadhaTokens.muted,
            ),
          ],
        ),
      ),
    ),
  );
}

class AppCounter extends StatelessWidget {
  const AppCounter({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.minimum = 0,
    this.maximum = 99,
  }) : assert(maximum >= minimum);
  final String label;
  final int value;
  final int minimum;
  final int maximum;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    child: Row(
      children: [
        Expanded(child: Text(label, style: AlnadhaTokens.body)),
        IconButton(
          tooltip: 'إنقاص $label',
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          onPressed: value > minimum ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 34,
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: AlnadhaTokens.sectionTitle,
          ),
        ),
        IconButton(
          tooltip: 'زيادة $label',
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          onPressed: value < maximum ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    ),
  );
}

class AppFormTextField extends StatelessWidget {
  const AppFormTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.enabled = true,
  }) : assert(controller == null || initialValue == null);
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    initialValue: initialValue,
    enabled: enabled,
    maxLines: maxLines,
    keyboardType: keyboardType,
    validator: validator,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AlnadhaTokens.border),
      ),
      filled: true,
      fillColor: AlnadhaTokens.surface,
    ),
  );
}

class AppStepProgress extends StatelessWidget {
  const AppStepProgress({
    super.key,
    required this.current,
    required this.total,
    this.section = AppSection.cleaning,
  }) : assert(total > 0),
       assert(current > 0),
       assert(current <= total);
  final int current;
  final int total;
  final AppSection section;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('الخطوة $current من $total', style: AlnadhaTokens.caption),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: current / total,
          minHeight: 6,
          backgroundColor: AlnadhaTokens.border,
          color: section.accent,
          semanticsLabel: 'تقدم الحجز',
        ),
      ),
    ],
  );
}
