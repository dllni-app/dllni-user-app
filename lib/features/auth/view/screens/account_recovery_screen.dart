import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/helpers/phone_number_helper.dart';
import 'package:dllni_user_app/core/widgets/app_phone_number_field.dart';
import 'package:dllni_user_app/features/auth/domain/repository/auth_repo.dart';
import 'package:dllni_user_app/features/auth/domain/usecases/auth_phone_params.dart';
import 'package:dllni_user_app/features/auth/view/manager/bloc/auth_bloc.dart';
import 'package:dllni_user_app/features/auth/view/widgets/auth_chrome.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:toastification/toastification.dart';

@AutoRoutePage(path: '/account-recovery')
class AccountRecoveryScreen extends StatefulWidget {
  const AccountRecoveryScreen({super.key});

  @override
  State<AccountRecoveryScreen> createState() => _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends State<AccountRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneFieldKey = GlobalKey<AppPhoneNumberFieldState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  PhoneNumber? _phone;
  bool _loading = false;
  bool _codeSent = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  static const Color _iconGray = Color(0xff6B7280);

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<String?> _getPhone() async {
    final phoneError = await _phoneFieldKey.currentState?.validate();
    if (!mounted) return null;
    if (phoneError != null) {
      AppToast.showToast(context: context, message: phoneError, type: ToastificationType.error);
      return null;
    }

    return formatPhoneForApi(_phone);
  }

  Future<void> _requestCode() async {
    FocusScope.of(context).unfocus();
    final phone = await _getPhone();
    if (phone == null) return;

    setState(() => _loading = true);
    final response = await getIt<AuthRepo>().requestAccountRecovery(AuthPhoneParams(phone: phone));
    if (!mounted) return;
    setState(() => _loading = false);

    response.fold(
      (failure) => AppToast.showToast(
        context: context,
        message: authFlowMessage(failure.message, fallback: 'تعذر إرسال رمز التحقق'),
        type: ToastificationType.error,
      ),
      (result) {
        setState(() => _codeSent = true);
        AppToast.showToast(
          context: context,
          message: result.message ?? 'تم إرسال رمز التحقق إلى رقم الهاتف.',
          type: ToastificationType.success,
        );
      },
    );
  }

  Future<void> _confirm() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = await _getPhone();
    if (phone == null) return;

    setState(() => _loading = true);
    final response = await getIt<AuthRepo>().confirmAccountRecovery(
      ResetPasswordConfirmParams(
        phone: phone,
        otp: _codeController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
      ),
    );
    if (!mounted) return;
    setState(() => _loading = false);

    response.fold(
      (failure) => AppToast.showToast(
        context: context,
        message: authFlowMessage(failure.message, fallback: 'تعذر تحديث كلمة المرور'),
        type: ToastificationType.error,
      ),
      (result) {
        AppToast.showToast(
          context: context,
          message: result.message ?? 'تم تحديث كلمة المرور بنجاح.',
          type: ToastificationType.success,
        );
        Navigator.of(context).pop();
      },
    );
  }

  String? _validateCode(String? value) {
    final code = value?.trim() ?? '';
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return 'أدخل رمز التحقق المكوّن من 6 أرقام';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final raw = value ?? '';
    if (raw.length < 8) return 'كلمة المرور يجب ألا تقل عن 8 أحرف';
    return null;
  }

  String? _validatePasswordConfirm(String? value) {
    if (value != _passwordController.text) return 'كلمتا المرور غير متطابقتين';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenChrome(
      title: 'استعادة الحساب',
      cardChild: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPhoneNumberField(
              key: _phoneFieldKey,
              label: 'رقم الجوال',
              isRequired: true,
              enabled: !_loading && !_codeSent,
              variant: AppPhoneFieldVariant.auth,
              onChanged: (number) => _phone = number,
            ),
            if (_codeSent) ...[
              const SizedBox(height: 18),
              AuthLabeledField(
                label: 'رمز التحقق',
                isRequired: true,
                controller: _codeController,
                hintText: 'أدخل رمز التحقق',
                keyboardType: TextInputType.number,
                enabled: !_loading,
                validator: _validateCode,
                prefixIcon: const Icon(Icons.numbers_rounded, color: _iconGray, size: 22),
              ),
              const SizedBox(height: 18),
              AuthLabeledField(
                label: 'كلمة المرور الجديدة',
                isRequired: true,
                controller: _passwordController,
                hintText: 'أدخل كلمة المرور الجديدة',
                obscureText: _obscurePassword,
                enabled: !_loading,
                validator: _validatePassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: _iconGray, size: 22),
                suffixIcon: IconButton(
                  onPressed: _loading ? null : () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: _iconGray, size: 22),
                ),
              ),
              const SizedBox(height: 18),
              AuthLabeledField(
                label: 'تأكيد كلمة المرور',
                isRequired: true,
                controller: _passwordConfirmController,
                hintText: 'أعد إدخال كلمة المرور',
                obscureText: _obscurePasswordConfirm,
                enabled: !_loading,
                validator: _validatePasswordConfirm,
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: _iconGray, size: 22),
                suffixIcon: IconButton(
                  onPressed: _loading ? null : () => setState(() => _obscurePasswordConfirm = !_obscurePasswordConfirm),
                  icon: Icon(_obscurePasswordConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: _iconGray, size: 22),
                ),
              ),
            ],
          ],
        ),
      ),
      primaryButton: AuthGradientButton(
        label: _loading ? 'جاري المعالجة...' : (_codeSent ? 'تحديث كلمة المرور' : 'إرسال رمز التحقق'),
        onPressed: _loading ? null : (_codeSent ? _confirm : _requestCode),
      ),
      belowPrimary: Column(
        children: [
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _loading ? null : () => Navigator.of(context).pop(),
            child: AppText.labelLarge(
              'العودة لتسجيل الدخول',
              fontWeight: FontWeight.w700,
              color: context.secondary,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          const AuthTrailing(),
        ],
      ),
    );
  }
}
