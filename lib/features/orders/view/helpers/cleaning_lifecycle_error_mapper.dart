import 'package:common_package/helpers/error_handler.dart';

class CleaningLifecycleErrorMapper {
  CleaningLifecycleErrorMapper._();

  static const int _statusForbidden = 403;
  static const int _statusUnprocessable = 422;
  static const int _statusTooManyRequests = 429;

  static String mapVerificationFailure(Failure failure) {
    final statusCode = failure.statusCode;
    if (statusCode == _statusTooManyRequests) {
      return 'محاولات كثيرة، انتظر دقيقة ثم حاول مجدداً.';
    }
    if (statusCode == _statusForbidden) {
      return 'غير مسموح بتنفيذ التحقق لهذا الطلب حالياً.';
    }
    if (statusCode == _statusUnprocessable) {
      return 'رمز التحقق غير صحيح أو منتهي الصلاحية.';
    }
    return _fallbackFromMessage(failure.message);
  }

  static String mapLifecycleActionFailure(
    Failure failure, {
    String? invalidStateMessage,
  }) {
    final statusCode = failure.statusCode;
    if (statusCode == _statusForbidden) {
      return 'لا تملك صلاحية تنفيذ هذا الإجراء على الطلب.';
    }
    if (statusCode == _statusTooManyRequests) {
      return 'الطلبات كثيرة حالياً، حاول بعد قليل.';
    }
    if (statusCode == _statusUnprocessable) {
      return invalidStateMessage ??
          'تعذر تنفيذ الإجراء بسبب حالة الطلب الحالية.';
    }
    return _fallbackFromMessage(failure.message);
  }

  static String _fallbackFromMessage(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('too many') || normalized.contains('429')) {
      return 'الطلبات كثيرة حالياً، حاول بعد قليل.';
    }
    if (normalized.contains('forbidden') ||
        normalized.contains('403') ||
        normalized.contains('غير مصرح') ||
        normalized.contains('not allowed')) {
      return 'لا تملك صلاحية تنفيذ هذا الإجراء على الطلب.';
    }
    if (normalized.contains('verification') ||
        normalized.contains('code') ||
        normalized.contains('422') ||
        normalized.contains('invalid')) {
      return 'تعذر تنفيذ الإجراء بسبب حالة الطلب الحالية.';
    }
    return message;
  }
}
