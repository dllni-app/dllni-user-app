import 'package:flutter/material.dart';
import 'alnadha_tokens.dart';
import 'app_action_button.dart';

enum AppStatusIntent { neutral, info, pending, success, warning, danger }

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.intent = AppStatusIntent.neutral,
  });
  final String label;
  final AppStatusIntent intent;

  @override
  Widget build(BuildContext context) {
    final (color, background, icon) = switch (intent) {
      AppStatusIntent.neutral => (
        AlnadhaTokens.muted,
        const Color(0xFFE9ECF1),
        Icons.info_outline,
      ),
      AppStatusIntent.info => (
        AlnadhaTokens.primary,
        const Color(0xFFEEF0FA),
        Icons.info_outline,
      ),
      AppStatusIntent.pending => (
        AlnadhaTokens.warning,
        const Color(0xFFFFF5E5),
        Icons.schedule,
      ),
      AppStatusIntent.success => (
        AlnadhaTokens.success,
        const Color(0xFFE8F6EF),
        Icons.check_circle_outline,
      ),
      AppStatusIntent.warning => (
        AlnadhaTokens.warning,
        const Color(0xFFFFF5E5),
        Icons.warning_amber,
      ),
      AppStatusIntent.danger => (
        AlnadhaTokens.danger,
        const Color(0xFFFCEDEF),
        Icons.error_outline,
      ),
    };
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 10, 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: AlnadhaTokens.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 56, color: AlnadhaTokens.muted),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AlnadhaTokens.sectionTitle,
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AlnadhaTokens.caption,
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 18),
          AppActionButton(
            label: actionLabel!,
            onPressed: onAction,
            expand: false,
          ),
        ],
      ],
    ),
  );
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.message = 'تعذر تحميل البيانات',
    this.onRetry,
    this.offline = false,
  });
  final String message;
  final VoidCallback? onRetry;
  final bool offline;
  @override
  Widget build(BuildContext context) => AppEmptyState(
    icon: offline ? Icons.wifi_off_outlined : Icons.error_outline,
    title: offline ? 'لا يوجد اتصال بالإنترنت' : 'حدث خطأ',
    message: message,
    actionLabel: onRetry == null ? null : 'إعادة المحاولة',
    onAction: onRetry,
  );
}

/// Stable placeholder dimensions prevent major layout jumps while loading.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    this.height = 88,
    this.width = double.infinity,
    this.radius = AlnadhaTokens.cardRadius,
  });
  final double height;
  final double width;
  final double radius;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'جارٍ التحميل',
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECF1),
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}

class AppConfirmSheet extends StatelessWidget {
  const AppConfirmSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.danger = false,
  });
  final String title;
  final String message;
  final String confirmLabel;
  final bool danger;

  static Future<bool> ask(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool danger = false,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => AppConfirmSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        danger: danger,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.fromSTEB(
      20,
      8,
      20,
      20 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AlnadhaTokens.title),
        const SizedBox(height: 8),
        Text(message, style: AlnadhaTokens.body),
        const SizedBox(height: 20),
        AppActionButton(
          label: confirmLabel,
          variant: danger ? AppActionVariant.danger : AppActionVariant.primary,
          onPressed: () => Navigator.pop(context, true),
        ),
        const SizedBox(height: 8),
        AppActionButton(
          label: 'تراجع',
          variant: AppActionVariant.text,
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    ),
  );
}
