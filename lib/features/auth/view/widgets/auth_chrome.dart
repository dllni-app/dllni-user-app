import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/legal_links_launcher.dart';
import '../../../../core/widgets/support_whatsapp_launcher.dart';
import '../../../../generated/assets.dart';

/// Shared background, title, card container, and footer for auth screens.
class AuthScreenChrome extends StatelessWidget {
  const AuthScreenChrome({
    super.key,
    required this.title,
    required this.cardChild,
    required this.primaryButton,
    this.belowPrimary,
  });

  final String title;
  final Widget cardChild;
  final Widget primaryButton;
  final Widget? belowPrimary;

  @override
  Widget build(BuildContext context) {
    final subtitle = title == 'تسجيل الدخول'
        ? 'سجّل الدخول لمتابعة طلباتك وخدماتك.'
        : title == 'إنشاء حساب جديد'
        ? 'أنشئ حسابك لتجربة أسرع وأكثر تخصيصاً.'
        : title == 'تفعيل الحساب'
        ? 'أكّد رقم الجوال لإكمال إعداد حسابك.'
        : 'استعد الوصول إلى حسابك بخطوات آمنة.';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsetsDirectional.fromSTEB(
              24,
              MediaQuery.paddingOf(context).top + 22,
              24,
              24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  Color(0xFF172554),
                  Color(0xFF1E2A78),
                  Color(0xFF6C63FF),
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(28),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(34)),
                  ),
                  child: AppImage.asset(
                    Assets.images.appLogo.path,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE7E9FF),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      cardChild,
                      const SizedBox(height: 22),
                      primaryButton,
                      if (belowPrimary != null) ...[
                        const SizedBox(height: 18),
                        belowPrimary!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthTrailing extends StatelessWidget {
  const AuthTrailing({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              AppText.bodySmall(
                'هل تواجه مشكلة في تسجيل الدخول؟',
                color: Color(0xff9CA3AF),
                style: const TextStyle(fontSize: 12),
              ),
              GestureDetector(
                onTap: () => launchSupportWhatsApp(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.headset_mic_outlined,
                      size: 16,
                      color: context.secondary,
                    ),
                    const SizedBox(width: 4),
                    AppText.bodySmall(
                      'تواصل مع الدعم الفني',
                      color: context.secondary,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText.bodySmall(
            'جميع الحقوق محفوظة © 2026 تطبيق ع الندهة',
            textAlign: TextAlign.center,
            color: Color(0xff9CA3AF),
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => launchTermsAndConditions(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: AppText.bodySmall(
                  'الشروط والأحكام',
                  color: context.secondary,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppText.bodySmall(
                ' ▪ ',
                color: Color(0xff9CA3AF),
                style: const TextStyle(fontSize: 12),
              ),
              TextButton(
                onPressed: () => launchPrivacyPolicy(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: AppText.bodySmall(
                  'سياسة الخصوصية',
                  color: context.secondary,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AuthGradientButton extends StatelessWidget {
  const AuthGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_ios_rounded,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          decoration: const BoxDecoration(color: Color(0xFF1E2A78)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText.labelLarge(
                  label,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(width: 12),
                Icon(icon, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration authFieldDecoration(
  BuildContext context, {
  required bool hasError,
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  const borderColor = Color(0xffE5E7EB);
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
    filled: true,
    fillColor: const Color(0xffF9FAFB),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: hasError ? context.error : borderColor,
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: hasError ? context.error : borderColor,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: hasError ? context.error : context.primary,
        width: 1.2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: context.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: context.error, width: 1.2),
    ),
  );
}

class AuthLabeledField extends StatelessWidget {
  const AuthLabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.isRequired = false,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool isRequired;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText.bodyMedium(label, fontWeight: FontWeight.w500),
            if (isRequired)
              AppText.bodyMedium(
                '*',
                color: context.error,
                fontWeight: FontWeight.w500,
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
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
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
