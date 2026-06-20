import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../helpers/cleaning_security_code_display.dart';

class CleaningStartVerificationDialog {
  static Future<bool> show(
    BuildContext context, {
    required Future<String?> Function(String code) onSubmit,
    int? bookingId,
    String? bookingNumber,
    String? dateTime,
    String? workerAvatarUrl,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CleaningStartVerificationDialogContent(
        onSubmit: onSubmit,
        bookingId: bookingId,
        bookingNumber: bookingNumber,
        dateTime: dateTime,
        workerAvatarUrl: workerAvatarUrl,
      ),
    );
    return result ?? false;
  }
}

class _CleaningStartVerificationDialogContent extends StatefulWidget {
  const _CleaningStartVerificationDialogContent({
    required this.onSubmit,
    this.bookingId,
    this.bookingNumber,
    this.dateTime,
    this.workerAvatarUrl,
  });

  final Future<String?> Function(String code) onSubmit;
  final int? bookingId;
  final String? bookingNumber;
  final String? dateTime;
  final String? workerAvatarUrl;

  @override
  State<_CleaningStartVerificationDialogContent> createState() =>
      _CleaningStartVerificationDialogContentState();
}

class _CleaningStartVerificationDialogContentState
    extends State<_CleaningStartVerificationDialogContent> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final ScrollController _scrollController;
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
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final code = _controllers.map((e) => e.text).join();
    if (code.length != 4 || int.tryParse(code) == null) {
      setState(() => _error = 'الرجاء إدخال 4 أرقام');
      _scrollToFeedback();
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final failureMessage = await widget.onSubmit(code);
    if (!mounted) return;
    if (failureMessage != null) {
      AppToast.showToast(
        context: context,
        message: failureMessage,
        type: ToastificationType.error,
      );
      setState(() {
        _submitting = false;
        _error = failureMessage;
      });
      _scrollToFeedback();
      return;
    }
    AppToast.showToast(
      context: context,
      message: 'تم تأكيد رمز الوصول. بانتظار بدء العمل من العامل.',
      type: ToastificationType.success,
    );
    Navigator.of(context).pop(true);
  }

  void _scrollToFeedback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height -
        mediaQuery.viewInsets.vertical -
        mediaQuery.padding.vertical -
        48;
    final maxDialogHeight = availableHeight < 260 ? 260.0 : availableHeight;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxDialogHeight),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ),
                _DialogWorkerAvatar(workerAvatarUrl: widget.workerAvatarUrl),
                const SizedBox(height: 12),
                AppText.titleMedium(
                  'أدخل رمز الأمان لتأكيد بدء العمل',
                  textAlign: TextAlign.center,
                  color: const Color(0xff1DBCC8),
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 8),
                AppText.bodyMedium(
                  'رمز الأمان تحصل عليه من العامل للتأكد من أن هويته\n'
                  'إذا بدأ المهمة لم يتم إعطاؤه رمز الأمان',
                  textAlign: TextAlign.center,
                  color: const Color(0xff6B7280),
                ),
                if (widget.bookingId != null ||
                    (widget.bookingNumber ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  AppText.bodySmall(
                    'رقم الحجز: ${formatCleaningBookingLabel(bookingId: widget.bookingId, bookingNumber: widget.bookingNumber)}',
                    textAlign: TextAlign.center,
                    color: const Color(0xff374151),
                    fontWeight: FontWeight.w600,
                  ),
                ],
                if ((widget.dateTime ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  AppText.bodySmall(
                    formatCleaningSecurityCodeDateTime(widget.dateTime),
                    textAlign: TextAlign.center,
                    color: const Color(0xff6B7280),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(4, (index) {
                    return Container(
                      width: 52,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          counterText: '',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffD1D5DB)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff1E2A78),
                              width: 2,
                            ),
                          ),
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
                  const SizedBox(height: 10),
                  AppText.bodySmall(
                    _error!,
                    textAlign: TextAlign.center,
                    color: context.error,
                  ),
                ],
                if (_submitting) ...[
                  const SizedBox(height: 12),
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogWorkerAvatar extends StatelessWidget {
  const _DialogWorkerAvatar({this.workerAvatarUrl});

  final String? workerAvatarUrl;

  static const _fallbackIcon = Icon(
    Icons.mark_chat_read_outlined,
    size: 74,
    color: Color(0xff1DBCC8),
  );

  @override
  Widget build(BuildContext context) {
    final avatarUrl = workerAvatarUrl?.trim();
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return _fallbackIcon;
    }

    return ClipOval(
      child: SizedBox(
        width: 74,
        height: 74,
        child: AppImage.network(
          avatarUrl,
          fit: BoxFit.cover,
          width: 74,
          height: 74,
          errorWidget: _fallbackIcon,
        ),
      ),
    );
  }
}
