import 'package:intl_phone_number_input/intl_phone_number_input.dart';

const String defaultPhoneIsoCode = 'SY';

/// Parses a stored phone string (E.164 or local) into [PhoneNumber].
Future<PhoneNumber?> parseInitialPhone(String? stored) async {
  final value = stored?.trim() ?? '';
  if (value.isEmpty) return null;

  try {
    return await PhoneNumber.getRegionInfoFromPhoneNumber(value);
  } catch (_) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return PhoneNumber(isoCode: defaultPhoneIsoCode, phoneNumber: digits);
  }
}

/// Returns E.164 phone string for API submission.
String? formatPhoneForApi(PhoneNumber? number) {
  final value = number?.phoneNumber?.trim();
  if (value == null || value.isEmpty) return null;
  return value.startsWith('+') ? value : '+$value';
}

/// Validates [number] for forms; returns Arabic error message or null.
Future<String?> validatePhoneNumber(PhoneNumber? number) async {
  final raw = number?.phoneNumber?.trim() ?? '';
  if (raw.isEmpty) return 'أدخل رقم الجوال';

  try {
    final parsed = await PhoneNumber.getRegionInfoFromPhoneNumber(
      raw,
      number?.isoCode ?? defaultPhoneIsoCode,
    );
    final normalized = parsed.phoneNumber?.trim() ?? '';
    if (normalized.isEmpty) return 'رقم الجوال غير صالح';
    final digits = normalized.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'رقم الجوال غير صالح';
    return null;
  } catch (_) {
    return 'رقم الجوال غير صالح';
  }
}

/// Synchronous empty check for [InternationalPhoneNumberInput.validator].
String? validatePhoneNumberText(String? value) {
  if (value == null || value.trim().isEmpty) return 'أدخل رقم الجوال';
  return null;
}
