import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/themes/v7_artwork.dart';

enum CleaningOrdersFeedbackKind { activeEmpty, historyEmpty, loadError }

class CleaningOrdersFeedbackState extends StatelessWidget {
  const CleaningOrdersFeedbackState({
    super.key,
    required this.kind,
    this.message,
    this.onRetry,
  });

  final CleaningOrdersFeedbackKind kind;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isError = kind == CleaningOrdersFeedbackKind.loadError;
    final isHistory = kind == CleaningOrdersFeedbackKind.historyEmpty;
    final title = isError
        ? 'تعذر تحميل طلبات التنظيف'
        : isHistory
        ? 'لا توجد طلبات سابقة'
        : 'لا توجد طلبات تنظيف حالية';
    final subtitle = isError
        ? (message?.trim().isNotEmpty == true
              ? message!
              : 'تحقق من اتصال الإنترنت، ثم حاول مجدداً.')
        : isHistory
        ? 'ستظهر الطلبات المكتملة أو الملغاة هنا.'
        : 'ابدأ طلب تنظيف جديد من الصفحة الرئيسية.';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              V7ArtTile(
                asset: isError ? V7Artwork.offline : V7Artwork.empty,
                size: 96,
                radius: 22,
                background: isError
                    ? SharedPlatformColors.dangerSoft
                    : SharedPlatformColors.cleaningSoft,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: SharedPlatformColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: SharedPlatformColors.muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              if (isError && onRetry != null) ...[
                const SizedBox(height: 18),
                FilledButton.icon(
                  key: const Key('cleaning_orders_retry'),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('إعادة المحاولة'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(160, 48),
                    backgroundColor: SharedPlatformColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
