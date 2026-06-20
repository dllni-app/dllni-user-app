import 'package:common_package/helpers/error_handler.dart';

class CleaningLifecycleErrorMapper {
  CleaningLifecycleErrorMapper._();

  static const int _statusForbidden = 403;
  static const int _statusUnprocessable = 422;
  static const int _statusTooManyRequests = 429;
  static const String _genericFailureMessage =
      'تعذر تنفيذ الإجراء حالياً. تحقق من حالة الطلب وحاول مرة أخرى.';

  static String mapVerificationFailure(Failure failure) {
    final statusCode = failure.statusCode;
    if (statusCode == _statusTooManyRequests) {
      return 'محاولات كثيرة، انتظر دقيقة ثم حاول مجدداً.';
    }
    if (statusCode == _statusForbidden) {
      return 'غير مسموح بتنفيذ التحقق لهذا الطلب حالياً.';
    }
    if (statusCode == _statusUnprocessable) {
      return _mapVerificationMessage(failure.message);
    }
    return _mapVerificationMessage(failure.message);
  }

  static String _mapVerificationMessage(String message) {
    final normalized = message.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'تعذر تأكيد رمز الوصول. حاول مرة أخرى.';
    }
    if (_looksLikeTranslationKey(normalized) ||
        normalized.contains('nointernet') ||
        normalized.contains('socketexception') ||
        normalized.contains('connection')) {
      if (normalized.contains('nointernet') ||
          normalized.contains('socketexception') ||
          normalized.contains('connection')) {
        return 'لا يوجد اتصال بالإنترنت. تحقق من الاتصال وحاول مرة أخرى.';
      }
      return _genericFailureMessage;
    }
    if (normalized.contains('expired') || normalized.contains('انته')) {
      return 'انتهت صلاحية رمز الوصول. اطلب رمزاً جديداً من العامل.';
    }
    if (normalized.contains('invalid') ||
        normalized.contains('wrong') ||
        normalized.contains('غير صحيح') ||
        normalized.contains('incorrect')) {
      return 'رمز الوصول غير صحيح. تحقق من الرمز وحاول مرة أخرى.';
    }
    if (statusCodeLike422(normalized)) {
      return 'رمز الوصول غير صحيح أو منتهي الصلاحية.';
    }
    return message;
  }

  static bool statusCodeLike422(String normalized) {
    return normalized.contains('422') || normalized.contains('verification');
  }

  static String mapCancelFailure(Failure failure) {
    final statusCode = failure.statusCode;
    final normalized = failure.message.trim().toLowerCase();
    if (statusCode == _statusForbidden) {
      return 'لا تملك صلاحية إلغاء هذا الطلب.';
    }
    if (statusCode == _statusTooManyRequests) {
      return 'الطلبات كثيرة حالياً، حاول بعد قليل.';
    }
    if (statusCode == _statusUnprocessable ||
        normalized.contains('cannot be cancelled') ||
        normalized.contains('current status') ||
        normalized.contains('cancelled in current status')) {
      return 'لا يمكن إلغاء الطلب في الحالة الحالية.';
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
    if (_looksLikeTranslationKey(normalized)) {
      return _genericFailureMessage;
    }
    if (normalized.contains('too many') || normalized.contains('429')) {
      return 'الطلبات كثيرة حالياً، حاول بعد قليل.';
    }
    if (normalized.contains('forbidden') ||
        normalized.contains('403') ||
        normalized.contains('غير مصرح') ||
        normalized.contains('not allowed')) {
      return 'لا تملك صلاحية تنفيذ هذا الإجراء على الطلب.';
    }
    if (normalized.contains('cannot be cancelled') ||
        normalized.contains('current status')) {
      return 'لا يمكن تنفيذ الإجراء بسبب حالة الطلب الحالية.';
    }
    if (normalized.contains('verification') ||
        normalized.contains('code') ||
        normalized.contains('422') ||
        normalized.contains('invalid')) {
      return 'تعذر تنفيذ الإجراء بسبب حالة الطلب الحالية.';
    }
    return message;
  }

  static bool _looksLikeTranslationKey(String value) {
    return value.contains('errormessage.') || value.contains('error_message.');
  }
}
