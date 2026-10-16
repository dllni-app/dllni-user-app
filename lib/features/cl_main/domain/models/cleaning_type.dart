enum CleaningType { deepCleaning, regularCleaning }

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
        return 'تعزيل';
      case CleaningType.regularCleaning:
        return 'حوسة';
    }
  }

  String get subtitle {
    switch (this) {
      case CleaningType.deepCleaning:
        return 'تنظيف شامل للأماكن التي تحتاج عناية إضافية؛ يشمل إزالة الغبار المتراكم وتنظيف الزوايا والأسطح والأرضيات بعمق حسب حالة الغرفة.';
      case CleaningType.regularCleaning:
        return 'ترتيب وتنظيف يومي خفيف للغرفة؛ إزالة الغبار الظاهر ومسح الأسطح والأرضيات من دون نقل الأثاث أو معالجة الاتساخ المتراكم.';
    }
  }
}
