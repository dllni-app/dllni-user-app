import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../helpers/phone_number_helper.dart';

enum AppPhoneFieldVariant { auth, profile }

class AppPhoneNumberField extends StatefulWidget {
  const AppPhoneNumberField({
    super.key,
    this.label,
    this.isRequired = false,
    this.hintText = 'أدخل رقم الجوال',
    this.initialValue,
    this.onChanged,
    this.enabled = true,
    this.variant = AppPhoneFieldVariant.profile,
    this.showLabel = true,
    this.validator,
  });

  final String? label;
  final bool isRequired;
  final String hintText;
  final PhoneNumber? initialValue;
  final ValueChanged<PhoneNumber>? onChanged;
  final bool enabled;
  final AppPhoneFieldVariant variant;
  final bool showLabel;
  final Future<String?> Function(PhoneNumber?)? validator;

  @override
  State<AppPhoneNumberField> createState() => AppPhoneNumberFieldState();
}

class AppPhoneNumberFieldState extends State<AppPhoneNumberField> {
  PhoneNumber? _phone;

  PhoneNumber? get phone => _phone;

  Future<String?> validate() async {
    if (widget.validator != null) {
      return widget.validator!(_phone);
    }
    return validatePhoneNumber(_phone);
  }

  @override
  void initState() {
    super.initState();
    _phone = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant AppPhoneNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _phone = widget.initialValue;
    }
  }

  InputDecoration _decoration(BuildContext context) {
    const borderColor = Color(0xffE5E7EB);
    const fillColor = Color(0xffF9FAFB);
    const iconGray = Color(0xff6B7280);

    if (widget.variant == AppPhoneFieldVariant.auth) {
      return InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        prefixIcon: const Icon(Icons.phone_rounded, color: iconGray, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.primary, width: 1.2),
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

    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xff15803D), size: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.primary, width: 1.2),
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

  @override
  Widget build(BuildContext context) {
    final input = Directionality(
      textDirection: TextDirection.ltr,
      child: InternationalPhoneNumberInput(
        initialValue: widget.initialValue ?? _phone,
        onInputChanged: (number) {
          _phone = number;
          widget.onChanged?.call(number);
        },
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.DROPDOWN,
          showFlags: true,
          useEmoji: true,
          leadingPadding: 8,
          trailingSpace: false,
        ),
        ignoreBlank: false,
        autoValidateMode: AutovalidateMode.disabled,
        formatInput: true,
        keyboardType: TextInputType.phone,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        inputDecoration: _decoration(context),
        selectorTextStyle: const TextStyle(
          color: Color(0xff2F2B3D),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        textStyle: const TextStyle(
          color: Color(0xff2F2B3D),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        countries: const ['SY'],
        validator: (value) => validatePhoneNumberText(value),
        isEnabled: widget.enabled,
        locale: 'ar',
      ),
    );

    final field = widget.enabled ? input : AbsorbPointer(child: input);

    if (!widget.showLabel || widget.label == null) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText.bodyMedium(widget.label!, fontWeight: FontWeight.w500),
            if (widget.isRequired)
              AppText.bodyMedium(
                '*',
                color: context.error,
                fontWeight: FontWeight.w500,
              ),
          ],
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
