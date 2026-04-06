import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'filled_text_field.dart';

/// Full name, phone row (country + digits + icon), optional verified banner.
class AccountInfoSection extends StatelessWidget {
  const AccountInfoSection({
    super.key,
    required this.nameController,
    required this.phoneLocalController,
    required this.dialCode,
    required this.dialCodes,
    required this.onDialCodeChanged,
    required this.isPhoneVerified,
    this.nameValidator,
    this.phoneValidator,
  });

  final TextEditingController nameController;
  final TextEditingController phoneLocalController;
  final String dialCode;
  final List<String> dialCodes;
  final ValueChanged<String?> onDialCodeChanged;
  final bool isPhoneVerified;
  final String? Function(String?)? nameValidator;
  final String? Function(String?)? phoneValidator;

  static const Color _phoneIconGreen = Color(0xff15803D);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledTextField(label: 'الاسم الكامل', controller: nameController, isRequired: true, validator: nameValidator),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.bodyMedium('رقم الهاتف الأساسي', fontWeight: FontWeight.w500),
            AppText.bodyMedium('*', color: context.error, fontWeight: FontWeight.w500),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: phoneLocalController,
          keyboardType: TextInputType.phone,
          validator: phoneValidator,
          style: const TextStyle(color: Color(0xff2F2B3D), fontSize: 14, fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            suffixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dialCodes.contains(dialCode) ? dialCode : dialCodes.first,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xff6B7280), size: 20),
                  style: const TextStyle(color: Color(0xff2F2B3D), fontSize: 14),
                  items: dialCodes.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                  onChanged: onDialCodeChanged,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            prefixIcon: Icon(Icons.phone_rounded, color: _phoneIconGreen, size: 22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xffE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xffE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.primary, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
