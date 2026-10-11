import 'package:flutter/material.dart';

import '../themes/shared_platform_colors.dart';

/// Neutral V7 illustrations for empty/retry/success states. Never used to
/// promise availability, successful payment, or a completed worker assignment.
class V7SpotState extends StatelessWidget {
  const V7SpotState({
    super.key,
    required this.asset,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final String asset;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title، $description',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Image.asset(
                asset,
                width: 118,
                height: 118,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.inbox_outlined,
                  size: 60,
                  color: SharedPlatformColors.muted,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: SharedPlatformColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: SharedPlatformColors.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: SharedPlatformColors.primary,
                  minimumSize: const Size(152, 48),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
