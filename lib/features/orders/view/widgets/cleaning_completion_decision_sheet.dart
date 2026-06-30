import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_orders_api_models.dart';

enum CleaningCompletionDecision { confirmed, rejected, extensionRequested }

class _ExtensionTimeOption {
  const _ExtensionTimeOption({required this.minutes, required this.label, this.price, this.currency});

  final int minutes;
  final String label;
  final double? price;
  final String? currency;

  String get formattedPrice {
    final amount = price;
    if (amount == null) return '';
    final resolvedCurrency = switch ((currency ?? '').toUpperCase()) {
      'SYP' => 'ل.س',
      final value when value.isNotEmpty => value,
      _ => 'ل.س',
    };
    return '${amount.formatWithComma()} $resolvedCurrency';
  }
}

class CleaningCompletionDecisionSheet {
  static Future<CleaningCompletionDecision?> show(
    BuildContext context, {
    required Future<String?> Function() onConfirm,
    required Future<String?> Function(String? reason) onReject,
    required Future<String?> Function(int minutes) onExtend,
    required Future<List<CleaningExtensionRangeModel>> Function() fetchExtensionTimeRanges,
    bool useRootNavigator = true,
  }) async {
    return showModalBottomSheet<CleaningCompletionDecision>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _CleaningCompletionDecisionSheetBody(
        onConfirm: onConfirm,
        onReject: onReject,
        onExtend: onExtend,
        fetchExtensionTimeRanges: fetchExtensionTimeRanges,
      ),
    );
  }
}

class _CleaningCompletionDecisionSheetBody extends StatefulWidget {
  const _CleaningCompletionDecisionSheetBody({required this.onConfirm, required this.onReject, required this.onExtend, required this.fetchExtensionTimeRanges});

  final Future<String?> Function() onConfirm;
  final Future<String?> Function(String? reason) onReject;
  final Future<String?> Function(int minutes) onExtend;
  final Future<List<CleaningExtensionRangeModel>> Function() fetchExtensionTimeRanges;

  @override
  State<_CleaningCompletionDecisionSheetBody> createState() => _CleaningCompletionDecisionSheetBodyState();
}

class _CleaningCompletionDecisionSheetBodyState extends State<_CleaningCompletionDecisionSheetBody> {
  bool _submitting = false;
  String? _error;

  Future<void> _run(Future<String?> Function() action, CleaningCompletionDecision decision) async {
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
      builder: (_) => _ExtensionTimePickerDialog(fetchExtensionTimeRanges: widget.fetchExtensionTimeRanges),
    );
    if (selected == null) return;
    if (selected.minutes <= 0) {
      setState(() => _error = 'يرجى اختيار مدة تمديد صالحة.');
      return;
    }
    await _run(() => widget.onExtend(selected.minutes), CleaningCompletionDecision.extensionRequested);
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد')),
        ],
      ),
    );
    final reason = reasonController.text.trim();
    reasonController.dispose();
    if (accepted != true) return;
    await _run(() => widget.onReject(reason.isEmpty ? null : reason), CleaningCompletionDecision.rejected);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 18, right: 18, top: 12, bottom: MediaQuery.viewInsetsOf(context).bottom + 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(onPressed: _submitting ? null : () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
          ),
          const Icon(Icons.verified_outlined, color: Color(0xff20B7C4), size: 74),
          const SizedBox(height: 12),
          AppText.titleLarge('مقدم الخدمة قد أنهى المهمة', textAlign: TextAlign.center, fontWeight: FontWeight.w700, color: const Color(0xff374151)),
          const SizedBox(height: 4),
          AppText.titleMedium('يرجى التأكيد', textAlign: TextAlign.center, fontWeight: FontWeight.w700, color: const Color(0xff374151)),
          if (_error != null) ...[
            const SizedBox(height: 10),
            AppText.bodySmall(_error!, textAlign: TextAlign.center, color: context.error),
          ],
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('completion_extend_button'),
            onPressed: _submitting ? null : _onExtendPressed,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xff20B7C4), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13)),
            child: _submitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : AppText.labelLarge('أرغب في تمديد الوقت', color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting ? null : _onRejectPressed,
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xff9CA3AF), side: const BorderSide(color: Color(0xffD1D5DB)), padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: AppText.labelLarge('لا، العمل لم ينته بعد', color: const Color(0xff9CA3AF)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _submitting ? null : () => _run(widget.onConfirm, CleaningCompletionDecision.confirmed),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xff1E2A78), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: AppText.labelLarge('التأكيد و الانتهاء', color: Colors.white, fontWeight: FontWeight.w700),
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
  const _ExtensionTimePickerDialog({required this.fetchExtensionTimeRanges});

  final Future<List<CleaningExtensionRangeModel>> Function() fetchExtensionTimeRanges;

  @override
  State<_ExtensionTimePickerDialog> createState() => _ExtensionTimePickerDialogState();
}

class _ExtensionTimePickerDialogState extends State<_ExtensionTimePickerDialog> {
  _ExtensionTimeOption? _selected;
  List<_ExtensionTimeOption> _options = const <_ExtensionTimeOption>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ranges = await widget.fetchExtensionTimeRanges();
      if (!mounted) return;
      final options = ranges.map(_ExtensionTimeOptionMapper.fromRange).where((option) => option != null).cast<_ExtensionTimeOption>().toList(growable: false);
      setState(() {
        _options = options;
        _selected = options.isEmpty ? null : options.first;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _options = const <_ExtensionTimeOption>[];
        _selected = null;
        _loading = false;
        _error = 'تعذر تحميل خيارات التمديد';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('طلب تمديد وقت إضافي'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText.bodySmall('اختر مدة التمديد من الخيارات المتاحة من الخادم.', color: const Color(0xff6B7280)),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Column(mainAxisSize: MainAxisSize.min, children: [
                AppText.bodySmall(_error!, textAlign: TextAlign.center, color: context.error),
                const SizedBox(height: 8),
                TextButton(onPressed: _loadOptions, child: const Text('إعادة المحاولة')),
              ])
            else if (_options.isEmpty)
              AppText.bodySmall('لا توجد خيارات تمديد متاحة حالياً.', textAlign: TextAlign.center, color: const Color(0xff6B7280))
            else
              ..._options.map((option) {
                final isSelected = _selected == option;
                return InkWell(
                  key: Key('extension_option_${option.minutes}'),
                  onTap: () => setState(() => _selected = option),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xffE6F9FB) : const Color(0xffF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? const Color(0xff20B7C4) : const Color(0xffE5E7EB)),
                    ),
                    child: Row(children: [
                      Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xff20B7C4) : const Color(0xff9CA3AF)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        AppText.bodyMedium(option.label, fontWeight: FontWeight.w700, color: const Color(0xff374151)),
                        if (option.formattedPrice.isNotEmpty) ...[const SizedBox(height: 2), AppText.bodySmall(option.formattedPrice, color: const Color(0xff6B7280))],
                      ])),
                    ]),
                  ),
                );
              }),
          ],
        ),
      ),
      actions: [
        TextButton(key: const Key('extension_cancel'), onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(
          key: const Key('extension_submit'),
          onPressed: _loading || _selected == null || _selected!.minutes <= 0 ? null : () => Navigator.pop(context, _selected),
          child: const Text('إرسال'),
        ),
      ],
    );
  }
}

class _ExtensionTimeOptionMapper {
  const _ExtensionTimeOptionMapper._();

  static _ExtensionTimeOption? fromRange(CleaningExtensionRangeModel range) {
    final minutes = range.requestMinutes;
    if (minutes == null || minutes <= 0 || minutes > 90) return null;
    return _ExtensionTimeOption(minutes: minutes, label: _rangeLabel(range, minutes), price: range.price, currency: range.currency);
  }

  static String _rangeLabel(CleaningExtensionRangeModel range, int minutes) {
    final label = range.label?.trim();
    if (label != null && label.isNotEmpty) return label;
    final start = range.startMinutes;
    final end = range.endMinutes;
    if (start != null && end != null) return '$start - $end دقيقة';
    return '$minutes دقيقة';
  }
}
