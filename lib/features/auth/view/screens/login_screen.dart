import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_service.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/session/user_session_keys.dart';
import 'package:dllni_user_app/core/session/user_session_prefs.dart';
import 'package:dllni_user_app/features/auth/data/models/login_response_model.dart';
import 'package:dllni_user_app/core/helpers/phone_number_helper.dart';
import 'package:dllni_user_app/core/widgets/app_phone_number_field.dart';
import 'package:dllni_user_app/features/auth/view/manager/bloc/auth_bloc.dart';
import 'package:dllni_user_app/features/auth/view/widgets/auth_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:toastification/toastification.dart';

/// Reference auth layout shared with [RegisterScreen]. Route: `/login`.
@AutoRoutePage(path: '/login')
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

Future<void> persistLoginSessionData(LoginResponseModel result) async {
  final token = result.token?.trim() ?? '';
  if (token.isNotEmpty) {
    await SharedPreferencesHelper.saveData(
      key: UserSessionKeys.token,
      value: token,
    );
  } else {
    await SharedPreferencesHelper.removeData(key: UserSessionKeys.token);
  }
  final customerId = result.data?.id;
  if (customerId != null) {
    await SharedPreferencesHelper.saveData(
      key: UserSessionKeys.customerId,
      value: customerId,
    );
  } else {
    await SharedPreferencesHelper.removeData(key: UserSessionKeys.customerId);
  }

  final user = result.data;
  if (user != null) {
    await UserSessionPrefs.saveUser(user);
  } else {
    await UserSessionPrefs.removeUser();
  }

  await UserSessionPrefs.saveUserProfile(
    name: user?.name,
    email: user?.email,
    phone: user?.phone,
    avatarUrl: _resolveLoginAvatarUrl(user),
    phoneVerifiedAt: user?.phoneVerifiedAt,
  );
}

String? _resolveLoginAvatarUrl(LoggedInUserModel? user) {
  if (user == null) return null;
  final primary = user.primaryImage;
  final primaryUrl = (primary?.url ?? primary?.thumbnailUrl)?.trim();
  if (primaryUrl != null && primaryUrl.isNotEmpty) {
    return primaryUrl;
  }
  for (final image in user.images) {
    final imageUrl = (image.url ?? image.thumbnailUrl)?.trim();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return imageUrl;
    }
  }
  return null;
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneFieldKey = GlobalKey<AppPhoneNumberFieldState>();
  final _passwordController = TextEditingController();

  PhoneNumber? _phone;
  bool _obscurePassword = true;

  static const Color _iconGray = Color(0xff6B7280);

  @override
  void dispose() {
    _passwordController.dispose();
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
      LoginSubmittedEvent(phone: phone, password: _passwordController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            curr.loginStatus == BlocStatus.failed ||
            curr.loginStatus == BlocStatus.success,
        listener: (context, state) async {
          if (state.loginStatus == BlocStatus.failed) {
            AppToast.showToast(
              context: context,
              message: state.errorMessage ?? 'فشل تسجيل الدخول',
              type: ToastificationType.error,
            );
            return;
          }
          if (state.loginStatus == BlocStatus.success) {
            final token = state.loginResult?.token;
            if (token != null && token.isNotEmpty) {
              await persistLoginSessionData(state.loginResult!);
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
            final loading = state.loginStatus == BlocStatus.loading;
            return AuthScreenChrome(
              title: 'تسجيل الدخول',
              cardChild: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppPhoneNumberField(
                      key: _phoneFieldKey,
                      label: 'رقم الجوال',
                      isRequired: true,
                      enabled: !loading,
                      variant: AppPhoneFieldVariant.auth,
                      onChanged: (number) => _phone = number,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        AppText.bodyMedium(
                          'كلمة المرور',
                          fontWeight: FontWeight.w500,
                        ),
                        AppText.bodyMedium(
                          '*',
                          color: context.error,
                          fontWeight: FontWeight.w500,
                        ),
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
                      style: const TextStyle(
                        color: Color(0xff2F2B3D),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: authFieldDecoration(
                        context,
                        hasError: false,
                        hintText: 'أدخل كلمة المرور',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: _iconGray,
                          size: 22,
                        ),
                        suffixIcon: IconButton(
                          onPressed: loading
                              ? null
                              : () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _iconGray,
                            size: 22,
                          ),
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
                    : () async {
                        await _submit(context.read<AuthBloc>());
                      },
              ),
              belowPrimary: Column(
                children: [
                  Divider(height: 1, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  AppText.bodySmall(
                    'ليس لديك حساب؟',
                    color: _iconGray,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: loading
                        ? null
                        : () => context.pushRoute('/register'),
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
                        'إنشاء حساب جديد',
                        fontWeight: FontWeight.w700,
                        color: context.secondary,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
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
