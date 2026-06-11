import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';

enum CleaningCompletionDecision { confirmed, rejected, extensionRequested }

class _ExtensionTimeOption {
  const _ExtensionTimeOption({required this.minutes, required this.price});

  final int minutes;
  final int price;

  String get label => '$minutes دقيقة - ${price.formatWithComma()} ل.س';
}

const List<_ExtensionTimeOption> _mockExtensionOptions = <_ExtensionTimeOption>[
  _ExtensionTimeOption(minutes: 30, price: 10000),
  _ExtensionTimeOption(minutes: 60, price: 18000),
  _ExtensionTimeOption(minutes: 90, price: 25000),
  _ExtensionTimeOption(minutes: 120, price: 32000),
];

class CleaningCompletionDecisionSheet {
  static Future<CleaningCompletionDecision?> show(
    BuildContext context, {
    required Future<String?> Function() onConfirm,
    required Future<String?> Function(String? reason) onReject,
    required Future<String?> Function(int minutes) onExtend,
    bool useRootNavigator = true,
  }) async {
    return showModalBottomSheet<CleaningCompletionDecision>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CleaningCompletionDecisionSheetBody(
        onConfirm: onConfirm,
        onReject: onReject,
        onExtend: onExtend,
      ),
    );
  }
}

class _CleaningCompletionDecisionSheetBody extends StatefulWidget {
  const _CleaningCompletionDecisionSheetBody({
    required this.onConfirm,
    required this.onReject,
    required this.onExtend,
  });

  final Future<String?> Function() onConfirm;
  final Future<String?> Function(String? reason) onReject;
  final Future<String?> Function(int minutes) onExtend;

  @override
  State<_CleaningCompletionDecisionSheetBody> createState() =>
      _CleaningCompletionDecisionSheetBodyState();
}

class _CleaningCompletionDecisionSheetBodyState
    extends State<_CleaningCompletionDecisionSheetBody> {
  bool _submitting = false;
  String? _error;

  Future<void> _run(
    Future<String?> Function() action,
    CleaningCompletionDecision decision,
  ) async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final err = await action();
    if (!mounted) return;
    if (err != null && err.isNotEmpty) {
      setState(() {
        _submitting = false;
        _error = err;
      });
      return;
    }
    Navigator.of(context).pop(decision);
  }

  Future<void> _onExtendPressed() async {
    final selected = await showDialog<_ExtensionTimeOption>(
      context: context,
      useRootNavigator: true,
      builder: (_) =>
          const _ExtensionTimePickerDialog(options: _mockExtensionOptions),
    );
    if (selected == null) return;
    await _run(
      () => widget.onExtend(selected.minutes),
      CleaningCompletionDecision.extensionRequested,
    );
  }

  Future<void> _onRejectPressed() async {
    final reasonController = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        title: const Text('العمل لم يكتمل بعد'),
        content: TextField(
          controller: reasonController,
          minLines: 2,
          maxLines: 3,
          maxLength: 500,
          decoration: const InputDecoration(hintText: 'اكتب ملاحظتك (اختياري)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    final reason = reasonController.text.trim();
    reasonController.dispose();
    if (accepted != true) return;
    await _run(
      () => widget.onReject(reason.isEmpty ? null : reason),
      CleaningCompletionDecision.rejected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
          const Icon(
            Icons.verified_outlined,
            color: Color(0xff20B7C4),
            size: 74,
          ),
          const SizedBox(height: 12),
          AppText.titleLarge(
            'مقدم الخدمة قد أنهى المهمة',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
            color: const Color(0xff374151),
          ),
          const SizedBox(height: 4),
          AppText.titleMedium(
            'يرجى التأكيد',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
            color: const Color(0xff374151),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            AppText.bodySmall(
              _error!,
              textAlign: TextAlign.center,
              color: context.error,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('completion_extend_button'),
            onPressed: _submitting ? null : _onExtendPressed,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xff20B7C4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : AppText.labelLarge(
                    'أرغب في تمديد الوقت',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting ? null : _onRejectPressed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff9CA3AF),
                    side: const BorderSide(color: Color(0xffD1D5DB)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: AppText.labelLarge(
                    'لا، العمل لم ينته بعد',
                    color: const Color(0xff9CA3AF),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _submitting
                      ? null
                      : () => _run(
                          widget.onConfirm,
                          CleaningCompletionDecision.confirmed,
                        ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff1E2A78),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: AppText.labelLarge(
                    'نعم، أؤكد انتهاء العمل',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExtensionTimePickerDialog extends StatefulWidget {
  const _ExtensionTimePickerDialog({required this.options});

  final List<_ExtensionTimeOption> options;

  @override
  State<_ExtensionTimePickerDialog> createState() =>
      _ExtensionTimePickerDialogState();
}

class _ExtensionTimePickerDialogState
    extends State<_ExtensionTimePickerDialog> {
  _ExtensionTimeOption? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.options.isNotEmpty) {
      _selected = widget.options.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('طلب تمديد وقت إضافي'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.options.map((option) {
            final isSelected = _selected == option;
            return InkWell(
              key: Key('extension_option_${option.minutes}'),
              onTap: () => setState(() => _selected = option),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xffE6F9FB)
                      : const Color(0xffF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xff20B7C4)
                        : const Color(0xffE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? const Color(0xff20B7C4)
                          : const Color(0xff9CA3AF),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppText.bodyMedium(
                        option.label,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff374151),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('extension_cancel'),
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          key: const Key('extension_submit'),
          onPressed: _selected == null
              ? null
              : () => Navigator.pop(context, _selected),
          child: const Text('إرسال'),
        ),
      ],
    );
  }
}
