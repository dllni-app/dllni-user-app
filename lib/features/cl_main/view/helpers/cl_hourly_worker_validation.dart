/// Validation rules used by the hourly-worker request form.
abstract final class ClHourlyWorkerValidation {
  const ClHourlyWorkerValidation._();

  static const int minimumDescriptionLength = 20;
  static const int maximumDescriptionLength = 2000;

  static String? description(String? value) {
    final normalized = (value ?? '').trim();
    if (normalized.isEmpty) return 'وصف العمل مطلوب.';
    if (normalized.length < minimumDescriptionLength) {
      return 'يجب أن يحتوي الوصف على 20 حرفاً على الأقل.';
    }
    return null;
  }
}
