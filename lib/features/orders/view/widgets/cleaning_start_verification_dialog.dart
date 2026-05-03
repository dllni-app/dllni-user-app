import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CleaningStartVerificationDialog {
  static Future<bool> show(
    BuildContext context, {
    required Future<String?> Function(String code) onSubmit,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _CleaningStartVerificationDialogContent(onSubmit: onSubmit),
    );
    return result ?? false;
  }
}

class _CleaningStartVerificationDialogContent extends StatefulWidget {
  const _CleaningStartVerificationDialogContent({required this.onSubmit});

  final Future<String?> Function(String code) onSubmit;

  @override
  State<_CleaningStartVerificationDialogContent> createState() =>
      _CleaningStartVerificationDialogContentState();
}

class _CleaningStartVerificationDialogContentState
    extends State<_CleaningStartVerificationDialogContent> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      4,
      (_) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final code = _controllers.map((e) => e.text).join();
    if (code.length != 4 || int.tryParse(code) == null) {
      setState(() => _error = 'الرجاء إدخال 4 أرقام');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final failureMessage = await widget.onSubmit(code);
    if (!mounted) return;
    if (failureMessage != null) {
      setState(() {
        _submitting = false;
        _error = failureMessage;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xffF3F4F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close),
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              Icons.verified_user_outlined,
              size: 72,
              color: context.primaryContainer,
            ),
            const SizedBox(height: 20),
            AppText.titleMedium(
              'أدخل رمز الأمان لتأكيد بدء العمل',
              textAlign: TextAlign.center,
              color: context.primaryContainer,
            ),
            const SizedBox(height: 10),
            AppText.bodyMedium(
              'رمز الأمان تحصل عليه من العامل للتأكد من أن هويته. لا تبدأ المهمة إن لم يعطك رمز الأمان',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(4, (index) {
                return Container(
                  width: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      counterText: '',
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        _focusNodes[index + 1].requestFocus();
                      }
                      if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      final joined = _controllers.map((e) => e.text).join();
                      if (joined.length == 4) {
                        _submit();
                      }
                    },
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              AppText.bodySmall(_error!, color: context.error),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
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
                        'تأكيد الرمز',
                        color: context.onPrimary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
