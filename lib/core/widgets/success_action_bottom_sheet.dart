import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:flutter/material.dart';

/// Reusable success sheet. Both actions keep their existing callbacks.
class SuccessActionBottomSheet extends StatelessWidget {
  final String title;
  final String followUpLabel;
  final String shareLabel;
  final VoidCallback onFollowUp;
  final VoidCallback onShare;
  final Widget? icon;

  const SuccessActionBottomSheet({
    super.key,
    required this.title,
    required this.followUpLabel,
    required this.shareLabel,
    required this.onFollowUp,
    required this.onShare,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon ??
                  const Icon(Icons.verified_rounded, size: 72, color: SharedPlatformColors.success),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SharedPlatformColors.ink,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: onFollowUp,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SharedPlatformColors.primary,
                      side: const BorderSide(color: SharedPlatformColors.border),
                      minimumSize: const Size(136, 52),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(followUpLabel),
                  ),
                  FilledButton(
                    onPressed: onShare,
                    style: FilledButton.styleFrom(
                      backgroundColor: SharedPlatformColors.primary,
                      foregroundColor: SharedPlatformColors.surface,
                      minimumSize: const Size(136, 52),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(shareLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
