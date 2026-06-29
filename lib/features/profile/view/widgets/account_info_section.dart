import 'package:common_package/extensions/theme_extension.dart';
import 'package:common_package/widgets/app_text.dart';
import 'package:dllni_user_app/core/widgets/app_phone_number_field.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../core/widgets/phone_number_widget/my_phone_number_field_widget.dart';
import 'filled_text_field.dart';

/// Full name, optional email, and primary phone field.
class AccountInfoSection extends StatelessWidget {
  const AccountInfoSection({
    super.key,
    required this.nameController,
    required this.emailController,
    this.nameValidator,
    this.emailValidator,
    required this.phoneController,
    required this.initPhoneNumber,
    required this.phoneValue,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String? initPhoneNumber;
  final ValueNotifier<String> phoneValue;
  final String? Function(String?)? nameValidator;
  final String? Function(String?)? emailValidator;

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
        FilledTextField(
          label: 'البريد الإلكتروني',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: emailValidator,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            AppText.bodyMedium(
              'رقم الهاتف الأساسي',
              fontWeight: FontWeight.w500,
            ),
            AppText.bodyMedium(
              '*',
              color: context.error,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),

        // AppPhoneNumberField(
        //   key: phoneFieldKey,
        //   label: 'رقم الهاتف الأساسي',
        //   isRequired: true,
        //   initialValue: initialPhone,
        //
        //   variant: AppPhoneFieldVariant.profile,
        // ),
        MyPhoneNumberInitField(
          internationalPhoneValue: phoneValue,
          initialPhoneNumber: initPhoneNumber,
          controller: phoneController,
          labelText: '',
        ),
      ],
    );
  }
}
