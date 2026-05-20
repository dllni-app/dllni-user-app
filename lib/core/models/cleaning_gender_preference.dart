enum CleaningGenderPreference {
  any('any'),
  male('male'),
  female('female');

  const CleaningGenderPreference(this.apiValue);

  final String apiValue;

  static CleaningGenderPreference fromApi(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'male':
        return CleaningGenderPreference.male;
      case 'female':
        return CleaningGenderPreference.female;
      case 'any':
      default:
        return CleaningGenderPreference.any;
    }
  }
}

extension CleaningGenderPreferenceArabicLabel on CleaningGenderPreference {
  String get arabicLabel {
    switch (this) {
      case CleaningGenderPreference.any:
        return 'لا يهم';
      case CleaningGenderPreference.male:
        return 'عامل';
      case CleaningGenderPreference.female:
        return 'عاملة';
    }
  }
}
