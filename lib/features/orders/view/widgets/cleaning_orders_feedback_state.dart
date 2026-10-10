import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

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
              Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isError
                      ? SharedPlatformColors.dangerSoft
                      : SharedPlatformColors.cleaningSoft,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  isError
                      ? Icons.wifi_off_rounded
                      : isHistory
                      ? Icons.history_rounded
                      : Icons.cleaning_services_outlined,
                  color: isError
                      ? SharedPlatformColors.danger
                      : SharedPlatformColors.cleaningInk,
                  size: 32,
                ),
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
