import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/di/injection.dart';
import '../helpers/cleaning_security_code_display.dart';
import 'package:url_launcher/url_launcher.dart';

import '../manager/bloc/orders_bloc.dart';

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
  final Future<String?> Function(String code) onSubmit;

  final int? bookingId;
  final String? bookingNumber;
  final String? dateTime;
  final String? workerAvatarUrl;

  const _CleaningStartVerificationDialogContent({
    required this.onSubmit,
    this.bookingId,
    this.bookingNumber,
    this.dateTime,
    this.workerAvatarUrl,
  });

  @override
  State<_CleaningStartVerificationDialogContent> createState() =>
      _CleaningStartVerificationDialogContentState();
}

class _CleaningStartVerificationDialogContentState
    extends State<_CleaningStartVerificationDialogContent> {
  static const Color _primary = Color(0xff1DBCC8);
  static const Color _navy = Color(0xff1E2A78);
  static const Color _muted = Color(0xff6B7280);
  static const Color _surface = Color(0xffF9FAFB);
  static const Color _border = Color(0xffE5E7EB);

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final ScrollController _scrollController;
  bool _submitting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height -
        mediaQuery.viewInsets.vertical -
        mediaQuery.padding.vertical -
        48;
    final maxDialogHeight = availableHeight < 260 ? 260.0 : availableHeight;
    final hasBookingInfo =
        widget.bookingId != null ||
        (widget.bookingNumber ?? '').trim().isNotEmpty ||
        (widget.dateTime ?? '').trim().isNotEmpty;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxDialogHeight, maxWidth: 360),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: IconButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close, color: _muted, size: 22),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              _DialogWorkerAvatar(workerAvatarUrl: widget.workerAvatarUrl),
              const SizedBox(height: 16),
              AppText.titleMedium(
                'تأكيد بدء العمل',
                textAlign: TextAlign.center,
                color: _navy,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 8),
              AppText.bodyMedium(
                'اطلب رمز البدء من العامل، ثم أدخله هنا للسماح له ببدء المهمة.',
                textAlign: TextAlign.center,
                color: _muted,
                fontWeight: FontWeight.w500,
              ),
              if (hasBookingInfo) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    children: [
                      if (widget.bookingId != null ||
                          (widget.bookingNumber ?? '').trim().isNotEmpty)
                        AppText.bodySmall(
                          'رقم الحجز: ${formatCleaningBookingLabel(bookingId: widget.bookingId, bookingNumber: widget.bookingNumber)}',
                          textAlign: TextAlign.center,
                          color: const Color(0xff374151),
                          fontWeight: FontWeight.w600,
                        ),
                      if ((widget.dateTime ?? '').trim().isNotEmpty) ...[
                        if (widget.bookingId != null ||
                            (widget.bookingNumber ?? '').trim().isNotEmpty)
                          const SizedBox(height: 4),
                        AppText.bodySmall(
                          formatCleaningSecurityCodeDateTime(widget.dateTime),
                          textAlign: TextAlign.center,
                          color: _muted,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              AppText.labelMedium(
                'رمز البدء',
                textAlign: TextAlign.center,
                color: _navy,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 12),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(4, (index) {
                    final hasFocus = _focusNodes[index].hasFocus;
                    final hasValue = _controllers[index].text.isNotEmpty;
                    final isActive = hasFocus || hasValue;
                    return Container(
                      width: 52,
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _navy,
                        ),
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: isActive
                              ? const Color(0xffF0FDFE)
                              : _surface,
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isActive ? _primary : _border,
                              width: isActive ? 1.5 : 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _primary,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
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
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xffFECACA)),
                  ),
                  child: AppText.bodySmall(
                    _error!,
                    textAlign: TextAlign.center,
                    color: context.error,
                  ),
                ),
              ],
              TextButton(
                child: AppText.labelMedium(
                  'إلغاء الطلب',
                  textAlign: TextAlign.center,
                  color: const Color(0xffE51C28),
                  fontWeight: FontWeight.w600,
                ),
                onPressed: () async {
                  await showCancelOrderWarningDialog(context,orderId: widget.bookingId!);
                },
              ),

              if (_submitting) ...[
                const SizedBox(height: 16),
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      4,
      (_) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(4, (_) => FocusNode());
    _scrollController = ScrollController();
    for (final node in _focusNodes) {
      node.addListener(() => setState(() {}));
    }
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

  Future<void> _submit() async {
    if (_submitting) return;
    final code = _controllers.map((e) => e.text).join();
    if (code.length != 4 || int.tryParse(code) == null) {
      setState(() => _error = 'أدخل 4 أرقام');
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
      message: 'تم التأكيد. سيبدأ العامل العمل قريباً.',
      type: ToastificationType.success,
    );
    Navigator.of(context).pop(true);
  }
}

class _DialogWorkerAvatar extends StatelessWidget {
  static const Color _primary = Color(0xff1DBCC8);

  static const _fallbackIcon = Icon(
    Icons.verified_user_outlined,
    size: 36,
    color: _primary,
  );

  final String? workerAvatarUrl;

  const _DialogWorkerAvatar({this.workerAvatarUrl});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = workerAvatarUrl?.trim();
    final child = avatarUrl == null || avatarUrl.isEmpty
        ? _fallbackIcon
        : ClipOval(
            child: AppImage.network(
              avatarUrl,
              fit: BoxFit.cover,
              width: 72,
              height: 72,
              errorWidget: _fallbackIcon,
            ),
          );

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xffF0FDFE),
        border: Border.all(color: const Color(0xffB8EEF3), width: 2),
      ),
      alignment: Alignment.center,
      child: avatarUrl == null || avatarUrl.isEmpty
          ? child
          : SizedBox(width: 72, height: 72, child: child),
    );
  }
}

Future<bool?> showCancelOrderWarningDialog(
  BuildContext context, {
  required int orderId,
}) {


  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: AppText.titleMedium(
          'تنبيه هام',
          textAlign: TextAlign.center,
          color: Color(0xffE51C28),
          fontWeight: FontWeight.w700,
        ),
        content: CancelOrderWaringWidget(
          orderId: orderId,
        ),


      );
    },
  );
}


class CancelOrderWaringWidget extends StatefulWidget {
  const CancelOrderWaringWidget({
    super.key,
    required this.orderId,
  });

  final int orderId;

  @override
  State<CancelOrderWaringWidget> createState() =>
      _CancelOrderWaringWidgetState();
}

class _CancelOrderWaringWidgetState extends State<CancelOrderWaringWidget> {
  late final OrdersBloc orderBloc;

  final TextEditingController reason = TextEditingController();

  String? _reasonValidationError;
  bool _hasSubmitted = false;

  @override
  void initState() {
    orderBloc = getIt<OrdersBloc>();
    super.initState();
  }

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  void _submit() {
    final reasons = reason.text.trim();

    setState(() {
      _hasSubmitted = true;
    });

    if (reasons.length < 3) {
      setState(() {
        _reasonValidationError =
        'يرجى إدخال سبب إلغاء صالح (3 أحرف على الأقل)';
      });
      return;
    }

    setState(() {
      _reasonValidationError = null;
    });

    orderBloc.add(
      CancelCleaningOrderEvent(
        orderId: widget.orderId,
        reason: reasons,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrdersBloc, OrdersState>(
      bloc: orderBloc,
      listenWhen: (previous, current) =>
      previous.cancelCleaningStatus != current.cancelCleaningStatus,
      listener: (context, state) {
        if (state.cancelCleaningStatus == BlocStatus.success) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إلغاء الطلب بنجاح'),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading =
            state.cancelCleaningStatus == BlocStatus.loading;

        final blocError = (_hasSubmitted &&
            state.cancelCleaningStatus == BlocStatus.failed)
            ? state.cancelCleaningErrorMessage
            : null;

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.bodyMedium(
                'يرجى العلم أن إلغاء الطلب في هذه المرحلة قد يترتب عليه مراجعة من قبل فريقنا المختص، وقد يتم اتخاذ الإجراءات المناسبة وفقاً لسياسة الشركة وشروط الاستخدام المعتمدة.',
                textAlign: TextAlign.center,
                color: const Color(0xff6B7280),
                fontWeight: FontWeight.w500,
              ),
          
              const SizedBox(height: 12),
          
              TextField(
                controller: reason,
                minLines: 3,
                maxLines: 4,
                enabled: !isLoading,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'اكتب سبب الإلغاء',
                  errorText: _reasonValidationError,
                  filled: true,
                  hintStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  fillColor: const Color(0xffF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: Color(0xffD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: Color(0xffD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: Color(0xff9CA3AF)),
                  ),
                ),
              ),
          
              if (blocError != null && blocError.isNotEmpty) ...[
                const SizedBox(height: 8),
                AppText.labelMedium(
                  blocError,
                  color: const Color(0xffB91C1C),
                  textAlign: TextAlign.start,
                ),
              ],
          
              const SizedBox(height: 12),
          
              TextButton(
                onPressed: () async {
                  final uri = Uri.parse(
                    'https://your-company.com/terms',
                  );
          
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: const Text(
                  'الاطلاع على الشروط والأحكام',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          
              const SizedBox(height: 24),
          
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor:
                          const Color(0xffA3A9C6),
                          foregroundColor: Colors.white,
                        ),
                        child: AppText.bodySmall(
                          'تراجع',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          
                  const SizedBox(width: 12),
          
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                            : AppText.bodySmall(
                          'متابعة الإلغاء',
                          color: Color(0xffE51C28),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
