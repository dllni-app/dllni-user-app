import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_service.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/auth/view/manager/bloc/auth_bloc.dart';
import 'package:dllni_user_app/features/auth/view/screens/login_screen.dart';
import 'package:dllni_user_app/features/auth/view/widgets/auth_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class VerifyAccountRouteArgs {
  const VerifyAccountRouteArgs({
    required this.phone,
    this.message,
    this.expiresAt,
  });

  final String phone;
  final String? message;
  final String? expiresAt;
}

@AutoRoutePage(path: '/verify-account')
class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key, required this.args});

  final VerifyAccountRouteArgs args;

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  static const Color _iconGray = Color(0xff6B7280);
  static const int _resendCooldownSeconds = 60;

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  Timer? _resendTimer;
  int _resendSecondsLeft = 0;

  bool get _canResend => _resendSecondsLeft == 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  void _onOtpChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      _fillFromPaste(index, digits);
      return;
    }
    if (value.isNotEmpty && index < 5) {
      _otpFocus[index + 1].requestFocus();
    }
  }

  void _fillFromPaste(int startIndex, String digits) {
    final only = digits.replaceAll(RegExp(r'\D'), '');
    var i = startIndex;
    for (var k = 0; k < only.length && i <= 5; k++) {
      _otpControllers[i].text = only[k];
      i++;
    }
    if (i <= 5) {
      _otpFocus[i].requestFocus();
    } else {
      _otpFocus[5].requestFocus();
    }
    setState(() {});
  }

  void _submit(AuthBloc bloc) {
    FocusScope.of(context).unfocus();
    if (_otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(_otp)) {
      AppToast.showToast(
        context: context,
        message: 'أدخل رمز التحقق المكوّن من 6 أرقام',
        type: ToastificationType.warning,
      );
      return;
    }

    bloc.add(
      VerifyAccountSubmittedEvent(phone: widget.args.phone, otp: _otp),
    );
  }

  void _handleResendPressed() {
    if (!_canResend) return;

    AppToast.showToast(
      context: context,
      message: 'تم استلام طلبك بنجاح',
      type: ToastificationType.info,
    );

    setState(() => _resendSecondsLeft = _resendCooldownSeconds);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
        return;
      }

      setState(() => _resendSecondsLeft--);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.args.message;

    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            curr.verifyAccountStatus == BlocStatus.failed ||
            curr.verifyAccountStatus == BlocStatus.success,
        listener: (context, state) async {
          if (state.verifyAccountStatus == BlocStatus.failed) {
            AppToast.showToast(
              context: context,
              message: state.verifyAccountErrorMessage ?? 'فشل التحقق من الحساب',
              type: ToastificationType.error,
            );
            return;
          }
          if (state.verifyAccountStatus == BlocStatus.success) {
            final result = state.verifyAccountResult;
            final token = result?.token;
            if (token != null && token.isNotEmpty) {
              await persistLoginSessionData(result!);
              if (context.mounted) {
                final nav = context.pushRouteAndRemoveUntil('/main');
                if (nav != null) await nav;
                await getIt<DeepLinkService>().resumePendingIfAny();
              }
            } else {
              AppToast.showToast(
                context: context,
                message: 'لم يتم استلام رمز الدخول',
                type: ToastificationType.error,
              );
            }
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final loading = state.verifyAccountStatus == BlocStatus.loading;
            final resendEnabled = !loading && _canResend;
            return AuthScreenChrome(
              title: 'تفعيل الحساب',
              cardChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText.bodyMedium(
                    'أدخل رمز التحقق المكوّن من 6 أرقام المرسل إلى رقمك',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _iconGray,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  if (hint != null && hint.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    AppText.bodySmall(
                      hint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _iconGray,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) {
                        return SizedBox(
                          width: 46,
                          child: TextField(
                            controller: _otpControllers[i],
                            focusNode: _otpFocus[i],
                            enabled: !loading,
                            keyboardType: TextInputType.number,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff2F2B3D),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration:
                                authFieldDecoration(
                                  context,
                                  hasError: false,
                                  hintText: '•',
                                ).copyWith(
                                  counterText: '',
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                            onChanged: (v) => _onOtpChanged(i, v),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: resendEnabled ? _handleResendPressed : null,
                      child: AppText.bodySmall(
                        _canResend
                            ? 'لم تستلم الرمز؟ إعادة الإرسال'
                            : 'يمكنك إعادة الإرسال بعد $_resendSecondsLeft ثانية',
                        color: resendEnabled ? context.secondary : _iconGray,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              primaryButton: AuthGradientButton(
                label: loading ? 'جاري التحقق...' : 'تأكيد',
                onPressed: loading
                    ? null
                    : () => _submit(context.read<AuthBloc>()),
              ),
              belowPrimary: Column(
                children: [
                  Divider(height: 1, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: loading ? null : () => Navigator.of(context).pop(),
                    child: Container(
                      width: context.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: context.secondary.withAlpha(25),
                        border: Border.all(
                          color: context.secondary.withAlpha(220),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: AppText.labelLarge(
                        'العودة لتسجيل الدخول',
                        fontWeight: FontWeight.w700,
                        color: context.secondary,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const AuthTrailing(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
