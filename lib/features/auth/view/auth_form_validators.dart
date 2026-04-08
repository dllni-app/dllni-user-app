class AuthFormValidators {
  AuthFormValidators._();

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'أدخل الاسم الكامل';
    if (v.length < 2) return 'الاسم قصير جداً';
    return null;
  }

  static String? phoneLocal(String? value) {
    final v = value?.trim().replaceAll(' ', '') ?? '';
    if (v.isEmpty) return 'أدخل رقم الجوال';
    if (!RegExp(r'^\d+$').hasMatch(v)) {
      return 'استخدم أرقاماً فقط';
    }
    if (v.length < 8 || v.length > 10) {
      return 'رقم الجوال غير صالح';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'أدخل كلمة المرور';
    if (v.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!RegExp(r'[A-Za-z\u0600-\u06FF]').hasMatch(v)) {
      return 'يجب أن تحتوي على حرف';
    }
    if (!RegExp(r'\d').hasMatch(v)) {
      return 'يجب أن تحتوي على رقم';
    }
    return null;
  }

  static String? confirmPassword(String? value, String passwordText) {
    final v = value ?? '';
    if (v.isEmpty) return 'أعد إدخال كلمة المرور';
    if (v != passwordText) return 'كلمتا المرور غير متطابقتين';
    return null;
  }
}
