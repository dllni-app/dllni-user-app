class CleaningEventSessionInput {
  final DateTime date;
  final String time;
  final double hours;

  const CleaningEventSessionInput({
    required this.date,
    required this.time,
    required this.hours,
  });

  String get dateApi {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'date': dateApi,
        'time': time,
        'hours': hours,
      };
}

extension CleaningEventSessionInputListX on Iterable<CleaningEventSessionInput> {
  List<CleaningEventSessionInput> get normalized {
    final items = toList(growable: false)
      ..sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return a.time.compareTo(b.time);
      });
    return items;
  }

  double get totalHours => fold<double>(0, (sum, item) => sum + item.hours);

  Map<String, dynamic>? get scheduleJson {
    final items = normalized;
    if (items.length < 2) return null;
    return <String, dynamic>{
      'mode': 'multi_day',
      'sessions': items.map((item) => item.toJson()).toList(growable: false),
    };
  }
}
