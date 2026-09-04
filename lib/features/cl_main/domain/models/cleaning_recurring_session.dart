const int cleaningRecurringMaxWindowDays = 30;

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
