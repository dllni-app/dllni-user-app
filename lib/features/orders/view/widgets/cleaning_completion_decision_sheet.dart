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
  }) async {
    return showModalBottomSheet<CleaningCompletionDecision>(
      context: context,
      isScrollControlled: true,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Icon(
            Icons.verified_rounded,
            color: Color(0xff2CB8C4),
            size: 64,
          ),
          const SizedBox(height: 10),
          AppText.titleMedium(
            'مقدم الخدمة قد أنهى المهمة',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 2),
          AppText.bodyMedium(
            'يرجى التأكيد',
            textAlign: TextAlign.center,
            color: const Color(0xff6B7280),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            AppText.bodySmall(
              _error!,
              textAlign: TextAlign.center,
              color: context.error,
            ),
          ],
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _submitting
                ? null
                : () async {
                    final controller = TextEditingController(text: '30');
                    final accepted = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('طلب وقت إضافي'),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'دقائق إضافية (1–480)',
                          ),
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
                  },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xff2CB8C4),
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
                  ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _submitting
                ? null
                : () => _run(
                    widget.onConfirm,
                    CleaningCompletionDecision.confirmed,
                  ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xff1E2A78),
            ),
            child: AppText.labelLarge(
              'نعم، أؤكد انتهاء العمل',
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _submitting
                ? null
                : () async {
                    final controller = TextEditingController();
                    final accepted = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('العمل لم يكتمل بعد'),
                        content: TextField(
                          controller: controller,
                          minLines: 2,
                          maxLines: 3,
                          maxLength: 500,
                          decoration: const InputDecoration(
                            hintText: 'سبب اختياري',
                          ),
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
                    final reason = controller.text.trim();
                    controller.dispose();
                    if (accepted != true) return;
                    await _run(
                      () => widget.onReject(reason.isEmpty ? null : reason),
                      CleaningCompletionDecision.rejected,
                    );
                  },
            child: AppText.labelLarge('لا، العمل لم ينته بعد'),
          ),
        ],
      ),
    );
  }
}
