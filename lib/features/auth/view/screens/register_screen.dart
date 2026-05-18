import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/helpers/phone_number_helper.dart';
import 'package:dllni_user_app/core/widgets/app_phone_number_field.dart';
import 'package:dllni_user_app/features/auth/view/auth_form_validators.dart';
import 'package:dllni_user_app/features/auth/view/manager/bloc/auth_bloc.dart';
import 'package:dllni_user_app/features/auth/view/screens/verify_account_screen.dart';
import 'package:dllni_user_app/features/auth/view/widgets/auth_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:toastification/toastification.dart';

@AutoRoutePage(path: '/register')
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneFieldKey = GlobalKey<AppPhoneNumberFieldState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  PhoneNumber? _phone;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  static const Color _iconGray = Color(0xff6B7280);

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthBloc bloc) async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phoneError = await _phoneFieldKey.currentState?.validate();
    if (!mounted) return;
    if (phoneError != null) {
      AppToast.showToast(
        context: context,
        message: phoneError,
        type: ToastificationType.error,
      );
      return;
    }

    final phone = formatPhoneForApi(_phone);
    if (phone == null) return;

    bloc.add(
      RegisterSubmittedEvent(
        name: _nameController.text.trim(),
        phone: phone,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => curr.registerStatus == BlocStatus.failed || curr.registerStatus == BlocStatus.success,
        listener: (context, state) async {
          if (state.registerStatus == BlocStatus.failed) {
            AppToast.showToast(context: context, message: state.registerErrorMessage ?? 'فشل إنشاء الحساب', type: ToastificationType.error);
            return;
          }
          if (state.registerStatus == BlocStatus.success) {
            final r = state.registerResult;
            if (context.mounted) {
              context.pushRoute(
                '/verify-account',
                arguments: VerifyAccountRouteArgs(message: r?.message, expiresAt: r?.expiresAt),
              );
            }
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final loading = state.registerStatus == BlocStatus.loading;
            return AuthScreenChrome(
              title: 'إنشاء حساب جديد',
              cardChild: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthLabeledField(
                      label: 'الاسم الكامل',
                      isRequired: true,
                      controller: _nameController,
                      hintText: 'أدخل الاسم الكامل',
                      validator: AuthFormValidators.fullName,
                      enabled: !loading,
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: _iconGray, size: 22),
                    ),
                    const SizedBox(height: 18),
                    AppPhoneNumberField(
                      key: _phoneFieldKey,
                      label: 'رقم الجوال',
                      isRequired: true,
                      enabled: !loading,
                      variant: AppPhoneFieldVariant.auth,
                      onChanged: (number) => _phone = number,
                    ),
                    const SizedBox(height: 18),
                    _PasswordField(
                      label: 'كلمة المرور',
                      isRequired: true,
                      controller: _passwordController,
                      hintText: 'أدخل كلمة المرور',
                      obscureText: _obscurePassword,
                      enabled: !loading,
                      onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                      validator: AuthFormValidators.password,
                    ),
                    const SizedBox(height: 18),
                    _PasswordField(
                      label: 'أعد كتابة كلمة المرور',
                      isRequired: true,
                      controller: _confirmPasswordController,
                      hintText: 'أدخل كلمة المرور مرة ثانية',
                      obscureText: _obscureConfirm,
                      enabled: !loading,
                      onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) => AuthFormValidators.confirmPassword(v, _passwordController.text),
                    ),
                  ],
                ),
              ),
              primaryButton: AuthGradientButton(
                label: loading ? 'جاري التحميل...' : 'إنشاء الحساب',
                onPressed: loading
                    ? null
                    : () async {
                        await _submit(context.read<AuthBloc>());
                      },
              ),
              belowPrimary: Column(
                children: [
                  Divider(height: 1, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  AppText.bodySmall('لديك حساب بالفعل؟', color: _iconGray, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: loading ? null : () => context.pushRoute('/login'),
                    child: Container(
                      width: context.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: context.secondary.withAlpha(25),
                        border: Border.all(color: context.secondary.withAlpha(220), width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: AppText.labelLarge(
                        'قم بتسجيل الدخول',
                        fontWeight: FontWeight.w700,
                        color: context.secondary,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthTrailing(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.isRequired,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.validator,
    this.enabled = true,
  });

  final String label;
  final bool isRequired;
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool enabled;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;

  static const Color _iconGray = Color(0xff6B7280);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText.bodyMedium(label, fontWeight: FontWeight.w500),
            if (isRequired) AppText.bodyMedium('*', color: context.error, fontWeight: FontWeight.w500),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          validator: validator,
          style: const TextStyle(color: Color(0xff2F2B3D), fontSize: 14, fontWeight: FontWeight.w400),
          decoration: authFieldDecoration(
            context,
            hasError: false,
            hintText: hintText,
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: _iconGray, size: 22),
            suffixIcon: IconButton(
              onPressed: enabled ? onToggleVisibility : null,
              icon: Icon(obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: _iconGray, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}
