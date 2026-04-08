import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/auth/view/auth_form_validators.dart';
import 'package:dllni_user_app/features/auth/view/widgets/auth_chrome.dart';
import 'package:flutter/material.dart';
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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _dialCode = '+963';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  static const List<String> _dialCodes = [
    '+963',
    '+966',
    '+971',
    '+962',
    '+20',
  ];

  static const Color _iconGray = Color(0xff6B7280);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    AppToast.showToast(
      context: context,
      message: 'تم التحقق من البيانات بنجاح (لا يوجد اتصال بالخادم بعد)',
      type: ToastificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenChrome(
      title: 'إنشاء حساب جديد',
      cardChild: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (Navigator.of(context).canPop())
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primary, size: 20),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            if (Navigator.of(context).canPop()) const SizedBox(height: 4),
            AuthLabeledField(
              label: 'الاسم الكامل',
              isRequired: true,
              controller: _nameController,
              hintText: 'أدخل الاسم الكامل',
              validator: AuthFormValidators.fullName,
              prefixIcon: const Icon(Icons.person_outline_rounded, color: _iconGray, size: 22),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMedium('رقم الجوال', fontWeight: FontWeight.w500),
                AppText.bodyMedium('*', color: context.error, fontWeight: FontWeight.w500),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: AuthFormValidators.phoneLocal,
              style: const TextStyle(
                color: Color(0xff2F2B3D),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: authFieldDecoration(
                context,
                hasError: false,
                hintText: 'أدخل رقم الجوال',
                prefixIcon: const Icon(Icons.phone_rounded, color: _iconGray, size: 22),
                suffixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4, end: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _dialCodes.contains(_dialCode) ? _dialCode : _dialCodes.first,
                      isDense: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: _iconGray, size: 20),
                      style: const TextStyle(color: Color(0xff2F2B3D), fontSize: 14),
                      items: _dialCodes
                          .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _dialCode = v);
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _PasswordField(
              label: 'كلمة المرور',
              isRequired: true,
              controller: _passwordController,
              hintText: 'أدخل كلمة المرور',
              obscureText: _obscurePassword,
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
              onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (v) => AuthFormValidators.confirmPassword(v, _passwordController.text),
            ),
          ],
        ),
      ),
      primaryButton: AuthGradientButton(
        label: 'إنشاء الحساب',
        onPressed: _submit,
      ),
      belowPrimary: Column(
        children: [
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          AppText.bodySmall(
            'لديك حساب بالفعل؟',
            color: _iconGray,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.pushRoute('/login');
              }
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.secondary.withAlpha(220)),
              backgroundColor: context.secondary.withAlpha(20),
              foregroundColor: context.secondary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: AppText.labelLarge('قم بتسجيل الدخول', fontWeight: FontWeight.w700),
          ),
        ],
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
  });

  final String label;
  final bool isRequired;
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
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
            if (isRequired)
              AppText.bodyMedium('*', color: context.error, fontWeight: FontWeight.w500),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(
            color: Color(0xff2F2B3D),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          decoration: authFieldDecoration(
            context,
            hasError: false,
            hintText: hintText,
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: _iconGray, size: 22),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: _iconGray,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
