import 'package:dllni_user_app/core/widgets/app_phone_number_field.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'filled_text_field.dart';

/// Full name and international phone field.
class AccountInfoSection extends StatelessWidget {
  const AccountInfoSection({
    super.key,
    required this.nameController,
    required this.phoneFieldKey,
    required this.initialPhone,
    required this.onPhoneChanged,
    required this.isPhoneVerified,
    this.nameValidator,
  });

  final TextEditingController nameController;
  final GlobalKey<AppPhoneNumberFieldState> phoneFieldKey;
  final PhoneNumber? initialPhone;
  final ValueChanged<PhoneNumber> onPhoneChanged;
  final bool isPhoneVerified;
  final String? Function(String?)? nameValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledTextField(
          label: 'الاسم الكامل',
          controller: nameController,
          isRequired: true,
          validator: nameValidator,
        ),
        const SizedBox(height: 14),
        AppPhoneNumberField(
          key: phoneFieldKey,
          label: 'رقم الهاتف الأساسي',
          isRequired: true,
          initialValue: initialPhone,
          onChanged: onPhoneChanged,
          variant: AppPhoneFieldVariant.profile,
        ),
      ],
    );
  }
}
