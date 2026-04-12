import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/auth/view/auth_form_validators.dart';
import 'package:dllni_user_app/features/auth/view/manager/bloc/auth_bloc.dart';
import 'package:dllni_user_app/features/auth/view/widgets/auth_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

/// Reference auth layout shared with [RegisterScreen]. Route: `/login`.
@AutoRoutePage(path: '/login')
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _dialCode = '+963';
  bool _obscurePassword = true;

  static const List<String> _dialCodes = ['+963'];

  static const Color _iconGray = Color(0xff6B7280);

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthBloc bloc) {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final local = _phoneController.text.trim().replaceAll(' ', '');
    final phone = '$_dialCode$local';
    bloc.add(LoginSubmittedEvent(phone: phone, password: _passwordController.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => curr.loginStatus == BlocStatus.failed || curr.loginStatus == BlocStatus.success,
        listener: (context, state) async {
          if (state.loginStatus == BlocStatus.failed) {
            AppToast.showToast(context: context, message: state.errorMessage ?? 'فشل تسجيل الدخول', type: ToastificationType.error);
            return;
          }
          if (state.loginStatus == BlocStatus.success) {
            final token = state.loginResult?.token;
            if (token != null && token.isNotEmpty) {
              await SharedPreferencesHelper.saveData(key: 'token', value: token);
              if (context.mounted) {
                context.pushRouteAndRemoveUntil('/main');
              }
            } else {
              AppToast.showToast(context: context, message: 'لم يتم استلام رمز الدخول', type: ToastificationType.error);
            }
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final loading = state.loginStatus == BlocStatus.loading;
            return AuthScreenChrome(
              title: 'تسجيل الدخول',
              cardChild: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      enabled: !loading,
                      validator: AuthFormValidators.phoneLocal,
                      style: const TextStyle(color: Color(0xff2F2B3D), fontSize: 14, fontWeight: FontWeight.w400),
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
                              items: _dialCodes.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                              onChanged: loading
                                  ? null
                                  : (v) {
                                      if (v != null) setState(() => _dialCode = v);
                                    },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        AppText.bodyMedium('كلمة المرور', fontWeight: FontWeight.w500),
                        AppText.bodyMedium('*', color: context.error, fontWeight: FontWeight.w500),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !loading,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                        return null;
                      },
                      style: const TextStyle(color: Color(0xff2F2B3D), fontSize: 14, fontWeight: FontWeight.w400),
                      decoration: authFieldDecoration(
                        context,
                        hasError: false,
                        hintText: 'أدخل كلمة المرور',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: _iconGray, size: 22),
                        suffixIcon: IconButton(
                          onPressed: loading ? null : () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: _iconGray, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              primaryButton: AuthGradientButton(
                label: loading ? 'جاري التحميل...' : 'تسجيل الدخول',
                onPressed: loading
                    ? null
                    : () {
                        _submit(context.read<AuthBloc>());
                      },
              ),
              belowPrimary: Column(
                children: [
                  Divider(height: 1, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  AppText.bodySmall('ليس لديك حساب؟', color: _iconGray, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: loading ? null : () => context.pushRoute('/register'),
                    child: Container(
                      width: context.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: context.secondary.withAlpha(25),
                        border: Border.all(color: context.secondary.withAlpha(220), width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: AppText.labelLarge('إنشاء حساب جديد', fontWeight: FontWeight.w700, color: context.secondary),
                    ),
                  ),
                  SizedBox(height: 32,),
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
