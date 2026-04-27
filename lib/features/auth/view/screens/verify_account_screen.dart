import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/auth/view/widgets/auth_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

class VerifyAccountRouteArgs {
  const VerifyAccountRouteArgs({
    this.message,
    this.expiresAt,
  });

  final String? message;
  final String? expiresAt;
}

/// OTP-only UI; verification API not wired yet.
@AutoRoutePage(path: '/verify-account')
class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key, required this.args});

  final VerifyAccountRouteArgs args;

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  static const Color _iconGray = Color(0xff6B7280);

  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
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

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(_otp)) {
      AppToast.showToast(context: context, message: 'أدخل رمز التحقق المكوّن من 6 أرقام', type: ToastificationType.warning);
      return;
    }
    AppToast.showToast(
      context: context,
      message: 'تم التحقق محلياً — ربط الخادم سيُضاف لاحقاً',
      type: ToastificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.args.message;

    return AuthScreenChrome(
      title: 'تفعيل الحساب',
      cardChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.bodyMedium(
            'أدخل رمز التحقق المكوّن من 6 أرقام المرسل إلى',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _iconGray, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 8),
          AppText.bodyMedium(
            'email',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
            style: TextStyle(color: context.primary, fontSize: 15),
          ),
          if (hint != null && hint.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppText.bodySmall(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _iconGray, fontSize: 12, height: 1.35),
            ),
          ],
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              return SizedBox(
                width: 46,
                child: TextField(
                  controller: _otpControllers[i],
                  focusNode: _otpFocus[i],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xff2F2B3D)),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: authFieldDecoration(
                    context,
                    hasError: false,
                    hintText: '•',
                  ).copyWith(
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (v) => _onOtpChanged(i, v),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                AppToast.showToast(context: context, message: 'إعادة الإرسال ستُفعّل مع الخادم لاحقاً', type: ToastificationType.info);
              },
              child: AppText.bodySmall('لم تستلم الرمز؟ إعادة الإرسال', color: context.secondary, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      primaryButton: AuthGradientButton(
        label: 'تأكيد',
        onPressed: _submit,
      ),
      belowPrimary: Column(
        children: [
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: context.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: context.secondary.withAlpha(25),
                border: Border.all(color: context.secondary.withAlpha(220), width: 1),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: AppText.labelLarge('العودة لتسجيل الدخول', fontWeight: FontWeight.w700, color: context.secondary),
            ),
          ),
          const SizedBox(height: 32),
          const AuthTrailing(),
        ],
      ),
    );
  }
}
