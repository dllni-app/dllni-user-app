import 'package:intl_phone_number_input/intl_phone_number_input.dart';

const String defaultPhoneIsoCode = 'SY';
const String syrianDialCode = '963';
const String syrianDialPrefix = '+$syrianDialCode';

final RegExp _syrianMobileRegex = RegExp(r'^\+9639\d{8}$');

String? _normalizeToSyrianPhone(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;

  if (digits.startsWith(syrianDialCode) && digits.length == 12) {
    final normalized = '+$digits';
    return _syrianMobileRegex.hasMatch(normalized) ? normalized : null;
  }

  if (digits.startsWith('0') && digits.length == 10) {
    final normalized = '$syrianDialPrefix${digits.substring(1)}';
    return _syrianMobileRegex.hasMatch(normalized) ? normalized : null;
  }

  if (digits.length == 9) {
    final normalized = '$syrianDialPrefix$digits';
    return _syrianMobileRegex.hasMatch(normalized) ? normalized : null;
  }

  return null;
}

/// Parses a stored phone string (E.164 or local) into [PhoneNumber].
Future<PhoneNumber?> parseInitialPhone(String? stored) async {
  final normalized = _normalizeToSyrianPhone(stored);
  if (normalized == null) return null;
  return PhoneNumber(
    isoCode: defaultPhoneIsoCode,
    dialCode: syrianDialPrefix,
    phoneNumber: normalized,
  );
}

/// Returns E.164 Syrian phone string for API submission.
String? formatPhoneForApi(PhoneNumber? number) {
  return _normalizeToSyrianPhone(number?.phoneNumber);
}

/// Validates [number] for forms; returns Arabic error message or null.
Future<String?> validatePhoneNumber(PhoneNumber? number) async {
  final raw = number?.phoneNumber?.trim() ?? '';
  if (raw.isEmpty) return 'أدخل رقم الجوال';
  return _normalizeToSyrianPhone(raw) == null ? 'رقم جوال سوري غير صالح' : null;
}

/// Synchronous empty check for [InternationalPhoneNumberInput.validator].
String? validatePhoneNumberText(String? value) {
  if (value == null || value.trim().isEmpty) return 'أدخل رقم الجوال';
  if (_normalizeToSyrianPhone(value) == null) return 'رقم جوال سوري غير صالح';
  return null;
}
