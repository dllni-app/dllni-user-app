const int cleaningRecurringMaxWindowDays = 30;

enum CleaningRecurringPattern { custom, daily, weekly, monthly }

extension CleaningRecurringPatternX on CleaningRecurringPattern {
  bool get isGenerated => this != CleaningRecurringPattern.custom;

  String get labelAr => switch (this) {
    CleaningRecurringPattern.custom => 'تواريخ مخصصة',
    CleaningRecurringPattern.daily => 'يومي',
    CleaningRecurringPattern.weekly => 'أسبوعي',
    CleaningRecurringPattern.monthly => 'شهري',
  };
}

class CleaningRecurringSessionInput {
  final DateTime date;
  final String time;

  const CleaningRecurringSessionInput({required this.date, required this.time});

  String get dateApi {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String get slotKey => '$dateApi|$time';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'date': dateApi,
    'time': time,
  };
}

class CleaningRecurringScheduleGenerator {
  const CleaningRecurringScheduleGenerator._();

  static List<CleaningRecurringSessionInput> generate({
    required CleaningRecurringPattern pattern,
    required DateTime startDate,
    required String time,
    required int occurrences,
  }) {
    if (!pattern.isGenerated) {
      throw ArgumentError.value(
        pattern,
        'pattern',
        'Custom recurring schedules are supplied explicitly.',
      );
    }
    if (occurrences < 2) {
      throw ArgumentError.value(
        occurrences,
        'occurrences',
        'Recurring schedules require at least two visits.',
      );
    }

    final sessions = List<CleaningRecurringSessionInput>.generate(
      occurrences,
      (index) => CleaningRecurringSessionInput(
        date: occurrenceDate(
          pattern: pattern,
          startDate: startDate,
          occurrenceIndex: index,
        ),
        time: time,
      ),
      growable: false,
    );

    if (sessions.exceedsMaxWindow) {
      throw RangeError(
        'Generated recurring schedule exceeds the '
        '$cleaningRecurringMaxWindowDays-day booking window.',
      );
    }

    return sessions.normalized;
  }

  static int maxOccurrencesWithinWindow({
    required CleaningRecurringPattern pattern,
    required DateTime startDate,
  }) {
    if (!pattern.isGenerated) return 0;

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    var count = 1;
    for (var index = 1; index <= cleaningRecurringMaxWindowDays; index++) {
      final occurrence = occurrenceDate(
        pattern: pattern,
        startDate: start,
        occurrenceIndex: index,
      );
      final normalized = DateTime(
        occurrence.year,
        occurrence.month,
        occurrence.day,
      );
      if (normalized.difference(start).inDays > cleaningRecurringMaxWindowDays) {
        break;
      }
      count++;
    }
    return count;
  }

  static DateTime occurrenceDate({
    required CleaningRecurringPattern pattern,
    required DateTime startDate,
    required int occurrenceIndex,
  }) {
    if (occurrenceIndex < 0) {
      throw ArgumentError.value(occurrenceIndex, 'occurrenceIndex');
    }

    return switch (pattern) {
      CleaningRecurringPattern.daily =>
        startDate.add(Duration(days: occurrenceIndex)),
      CleaningRecurringPattern.weekly =>
        startDate.add(Duration(days: occurrenceIndex * 7)),
      CleaningRecurringPattern.monthly => _addMonthsClamped(
        startDate,
        occurrenceIndex,
      ),
      CleaningRecurringPattern.custom => throw ArgumentError.value(
        pattern,
        'pattern',
        'Custom recurring schedules do not generate dates.',
      ),
    };
  }

  static DateTime _addMonthsClamped(DateTime anchor, int monthOffset) {
    final targetMonthStart = DateTime(anchor.year, anchor.month + monthOffset);
    final lastDayOfTargetMonth = DateTime(
      targetMonthStart.year,
      targetMonthStart.month + 1,
      0,
    ).day;
    final targetDay = anchor.day > lastDayOfTargetMonth
        ? lastDayOfTargetMonth
        : anchor.day;

    return DateTime(
      targetMonthStart.year,
      targetMonthStart.month,
      targetDay,
      anchor.hour,
      anchor.minute,
      anchor.second,
      anchor.millisecond,
      anchor.microsecond,
    );
  }
}

extension CleaningRecurringSessionInputListX
    on Iterable<CleaningRecurringSessionInput> {
  List<CleaningRecurringSessionInput> get normalized {
    final items = toList(growable: false)
      ..sort((left, right) {
        final dateCompare = left.date.compareTo(right.date);
        if (dateCompare != 0) return dateCompare;
        return left.time.compareTo(right.time);
      });
    return items;
  }

  int get windowDays {
    final items = normalized;
    if (items.length < 2) return 0;
    final first = DateTime(
      items.first.date.year,
      items.first.date.month,
      items.first.date.day,
    );
    final last = DateTime(
      items.last.date.year,
      items.last.date.month,
      items.last.date.day,
    );
    return last.difference(first).inDays;
  }

  bool get exceedsMaxWindow => windowDays > cleaningRecurringMaxWindowDays;

  Map<String, dynamic>? get scheduleJson {
    final items = normalized;
    if (items.isEmpty) return null;
    return <String, dynamic>{
      'mode': 'recurring',
      'sessions': items.map((item) => item.toJson()).toList(growable: false),
    };
  }
}
