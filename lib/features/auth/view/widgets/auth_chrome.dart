import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../../../generated/assets.dart';

/// Shared background, title, card container, and footer for auth screens.
class AuthScreenChrome extends StatelessWidget {
  const AuthScreenChrome({super.key, required this.title, required this.cardChild, required this.primaryButton, this.belowPrimary});

  final String title;
  final Widget cardChild;
  final Widget primaryButton;
  final Widget? belowPrimary;

  static const Color _pageBg = Color(0xFFF3F4F6);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _linkBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppImage.asset(Assets.images.appLogo.path, width: 160, height: 145),
                    const SizedBox(height: 32),
                    AppText(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.primary, fontSize: 22, fontWeight: FontWeight.w800, height: 1.25),
                    ),
                    const SizedBox(height: 24),
                    Material(
                      elevation: 6,
                      shadowColor: Colors.black26,
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      child: Padding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 24), child: cardChild),
                    ),
                    const SizedBox(height: 20),
                    primaryButton,
                    if (belowPrimary != null) ...[const SizedBox(height: 20), belowPrimary!],
                  ],
                ),
              ),
            ),
          ],
        ),
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
              AppText.bodySmall('هل تواجه مشكلة في تسجيل الدخول؟', color: Color(0xff9CA3AF), style: const TextStyle(fontSize: 12)),
              GestureDetector(
                onTap: () {
                  AppToast.showToast(context: context, message: 'سيتم تفعيل التواصل مع الدعم قريباً', type: ToastificationType.info);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.headset_mic_outlined, size: 16, color: context.secondary),
                    const SizedBox(width: 4),
                    AppText.bodySmall(
                      'تواصل مع الدعم الفني',
                      color: context.secondary,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText.bodySmall(
            'جميع الحقوق محفوظة © 2026 تطبيق دللني',
            textAlign: TextAlign.center,
            color: Color(0xff9CA3AF),
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  AppToast.showToast(context: context, message: 'سيتم عرض الشروط والأحكام قريباً', type: ToastificationType.info);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: AppText.bodySmall('الشروط والأحكام', color: context.secondary, style: const TextStyle(fontSize: 12)),
              ),
              AppText.bodySmall(' ▪ ', color: Color(0xff9CA3AF), style: const TextStyle(fontSize: 12)),
              TextButton(
                onPressed: () {
                  AppToast.showToast(context: context, message: 'سيتم عرض سياسة الخصوصية قريباً', type: ToastificationType.info);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: AppText.bodySmall('سياسة الخصوصية', color: context.secondary, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AuthGradientButton extends StatelessWidget {
  const AuthGradientButton({super.key, required this.label, required this.onPressed, this.icon = Icons.arrow_forward_ios_rounded});

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
          decoration: BoxDecoration(color: context.primary),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText.labelLarge(label, color: Colors.white, fontWeight: FontWeight.w700),
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

InputDecoration authFieldDecoration(BuildContext context, {required bool hasError, String? hintText, Widget? prefixIcon, Widget? suffixIcon}) {
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
      borderSide: BorderSide(color: hasError ? context.error : borderColor, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: hasError ? context.error : borderColor, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: hasError ? context.error : context.primary, width: 1.2),
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
            if (isRequired) AppText.bodyMedium('*', color: context.error, fontWeight: FontWeight.w500),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          validator: validator,
          style: const TextStyle(color: Color(0xff2F2B3D), fontSize: 14, fontWeight: FontWeight.w400),
          decoration: authFieldDecoration(context, hasError: false, hintText: hintText, prefixIcon: prefixIcon, suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}
