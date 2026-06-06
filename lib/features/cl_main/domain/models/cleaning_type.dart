enum CleaningType {
  deepCleaning,
  regularCleaning,
}

extension CleaningTypeX on CleaningType {
  String get apiValue {
    switch (this) {
      case CleaningType.deepCleaning:
        return 'deep_cleaning';
      case CleaningType.regularCleaning:
        return 'regular_cleaning';
    }
  }

  String get cleaningModeValue {
    switch (this) {
      case CleaningType.deepCleaning:
        return 'deep';
      case CleaningType.regularCleaning:
        return 'regular';
    }
  }

  String get title {
    switch (this) {
      case CleaningType.deepCleaning:
        return 'تنظيف عميق';
      case CleaningType.regularCleaning:
        return 'تنظيف عادي';
    }
  }

  String get subtitle {
    switch (this) {
      case CleaningType.deepCleaning:
        return 'يشمل شطف الارضيات ومسح الجدران والاسقف ومسح الغبرا';
      case CleaningType.regularCleaning:
        return 'يشمل مسح الغبرا ومسح الارضيات';
    }
  }
}
