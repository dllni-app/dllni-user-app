import 'package:flutter/material.dart';

import '../../data/models/cleaning_orders_api_models.dart';

enum PreferredWorkerRejectionDecisionAction { convertToOpen, cancel }

class PreferredWorkerRejectionDecisionDialog {
  const PreferredWorkerRejectionDecisionDialog._();

  static Future<PreferredWorkerRejectionDecisionAction?> show(
    BuildContext context, {
    required CleaningOrderModel order,
    required Future<String?> Function() onConvertToOpen,
    required Future<String?> Function() onCancel,
  }) {
    return showDialog<PreferredWorkerRejectionDecisionAction>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: PreferredWorkerRejectionDecisionDialogContent(
          order: order,
          onConvertToOpen: onConvertToOpen,
          onCancel: onCancel,
        ),
      ),
    );
  }
}

class PreferredWorkerRejectionDecisionDialogContent extends StatefulWidget {
  const PreferredWorkerRejectionDecisionDialogContent({
    super.key,
    required this.order,
    required this.onConvertToOpen,
    required this.onCancel,
  });

  final CleaningOrderModel order;
  final Future<String?> Function() onConvertToOpen;
  final Future<String?> Function() onCancel;

  @override
  State<PreferredWorkerRejectionDecisionDialogContent> createState() =>
      _PreferredWorkerRejectionDecisionDialogContentState();
}

class _PreferredWorkerRejectionDecisionDialogContentState
    extends State<PreferredWorkerRejectionDecisionDialogContent> {
  bool _submitting = false;
  String? _error;

  Future<void> _run(
    PreferredWorkerRejectionDecisionAction action,
    Future<String?> Function() submit,
  ) async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    final error = await submit();
    if (!mounted) return;
    if (error != null && error.trim().isNotEmpty) {
      setState(() {
        _submitting = false;
        _error = error;
      });
      return;
    }

    Navigator.of(context, rootNavigator: true).pop(action);
  }

  @override
  Widget build(BuildContext context) {
    final bookingNumber = widget.order.bookingNumber?.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text(
          'رفض العامل المخصص الطلب',
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (bookingNumber != null && bookingNumber.isNotEmpty) ...[
                Text(
                  'رقم الطلب: $bookingNumber',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
              ],
              const Text(
                'العامل الذي اخترته لهذا الطلب رفضه. يمكنك تحويل الطلب إلى طلب عام ليظهر لعمال آخرين ونبدأ البحث عن عامل بديل، أو إلغاء الطلب الآن بدون أي رسوم.',
                textAlign: TextAlign.center,
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffFECACA)),
                  ),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xffB91C1C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                key: const Key('preferred-worker-rejection-convert-button'),
                onPressed: _submitting
                    ? null
                    : () => _run(
                        PreferredWorkerRejectionDecisionAction.convertToOpen,
                        widget.onConvertToOpen,
                      ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('نعم، ابحث عن عامل بديل'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('preferred-worker-rejection-cancel-button'),
                onPressed: _submitting
                    ? null
                    : () => _run(
                        PreferredWorkerRejectionDecisionAction.cancel,
                        widget.onCancel,
                      ),
                child: const Text('لا، إلغاء الطلب'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
