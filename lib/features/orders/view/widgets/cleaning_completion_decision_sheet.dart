import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CleaningCompletionDecision { confirmed, rejected, extensionRequested }

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
    final controller = TextEditingController(text: '30');
    final accepted = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        title: const Text('طلب تمديد وقت إضافي'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'عدد الدقائق (1-480)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
    final raw = controller.text.trim();
    controller.dispose();
    if (accepted != true) return;
    final minutes = int.tryParse(raw);
    if (minutes == null || minutes < 1 || minutes > 480) {
      setState(() => _error = 'أدخل عدد دقائق بين 1 و 480');
      return;
    }
    await _run(
      () => widget.onExtend(minutes),
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
