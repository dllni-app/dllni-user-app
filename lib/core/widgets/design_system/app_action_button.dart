import 'package:flutter/material.dart';
import 'alnadha_tokens.dart';

enum AppActionVariant { primary, secondary, outlined, text, danger }

/// Unified action. Only visual state is managed here; caller owns eligibility.
class AppActionButton extends StatelessWidget {
  const AppActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppActionVariant.primary,
    this.section = AppSection.platform,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppActionVariant variant;
  final AppSection section;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = !loading && onPressed != null;
    final isSecondary = variant == AppActionVariant.secondary;
    final isDanger = variant == AppActionVariant.danger;
    final foreground = isSecondary
        ? section.ink
        : (isDanger || variant == AppActionVariant.primary)
        ? Colors.white
        : AlnadhaTokens.primary;
    final fill = isSecondary
        ? section.soft
        : isDanger
        ? AlnadhaTokens.danger
        : AlnadhaTokens.primary;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AlnadhaTokens.buttonRadius),
    );
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        else if (icon != null)
          Icon(icon, size: 20),
        if (loading || icon != null) const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AlnadhaTokens.button,
          ),
        ),
      ],
    );
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
      shape: WidgetStatePropertyAll(shape),
    );
    Widget control;
    switch (variant) {
      case AppActionVariant.primary:
      case AppActionVariant.secondary:
      case AppActionVariant.danger:
        control = FilledButton(
          onPressed: enabled ? onPressed : null,
          style: style.copyWith(
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled) ? null : fill,
            ),
            foregroundColor: WidgetStatePropertyAll(foreground),
          ),
          child: content,
        );
      case AppActionVariant.outlined:
        control = OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: style.copyWith(
            foregroundColor: const WidgetStatePropertyAll(
              AlnadhaTokens.primary,
            ),
            side: const WidgetStatePropertyAll(
              BorderSide(color: AlnadhaTokens.border),
            ),
          ),
          child: content,
        );
      case AppActionVariant.text:
        control = TextButton(
          onPressed: enabled ? onPressed : null,
          style: style.copyWith(
            foregroundColor: const WidgetStatePropertyAll(
              AlnadhaTokens.primary,
            ),
          ),
          child: content,
        );
    }
    return Semantics(
      button: true,
      enabled: enabled,
      child: SizedBox(width: expand ? double.infinity : null, child: control),
    );
  }
}
