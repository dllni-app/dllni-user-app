import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

enum CleaningOrdersFeedbackKind {
  activeEmpty,
  historyEmpty,
  completedEmpty,
  cancelledEmpty,
  loadError,
}

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
    final isCompleted = kind == CleaningOrdersFeedbackKind.completedEmpty;
    final isCancelled = kind == CleaningOrdersFeedbackKind.cancelledEmpty;
    final title = isError
        ? 'تعذر تحميل طلبات التنظيف'
        : isHistory
        ? 'لا توجد طلبات سابقة'
        : isCompleted
        ? 'لا توجد طلبات مكتملة'
        : isCancelled
        ? 'لا توجد طلبات ملغاة'
        : 'لا توجد طلبات تنظيف في هذا القسم';
    final description = isError
        ? (message?.trim().isNotEmpty == true
              ? message!
              : 'تحقق من اتصال الإنترنت، ثم حاول مجدداً.')
        : isHistory
        ? 'ستظهر هنا الطلبات المكتملة أو الملغاة عند وجودها.'
        : isCompleted
        ? 'ستظهر هنا الخدمات التي أُنجزت بنجاح.'
        : isCancelled
        ? 'ستظهر هنا الطلبات التي أُلغيت فقط.'
        : 'يمكنك إنشاء طلب جديد من الرئيسية ومتابعته هنا.';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: AppEmptyState(
          title: title,
          message: description,
          icon: isError
              ? Icons.wifi_off_outlined
              : isHistory || isCompleted || isCancelled
              ? Icons.history_rounded
              : Icons.receipt_long_outlined,
          actionLabel: isError && onRetry != null ? 'إعادة المحاولة' : null,
          onAction: onRetry,
        ),
      ),
    );
  }
}
