from pathlib import Path

path = Path('lib/features/cl_main/domain/models/cleaning_recurring_session.dart')
text = path.read_text()
old = """    return <String, dynamic>{
      'mode': 'recurring',
      'calculationMode': calculationMode.apiValue,
      if (normalizedHours != null) 'hoursPerVisit': normalizedHours,
      'sessions': items.map((item) => item.toJson()).toList(growable: false),
    };
"""
new = """    final schedule = <String, dynamic>{
      'mode': 'recurring',
      'calculationMode': calculationMode.apiValue,
      'sessions': items.map((item) => item.toJson()).toList(growable: false),
    };
    if (normalizedHours != null) {
      schedule['hoursPerVisit'] = normalizedHours;
    }
    return schedule;
"""
if text.count(old) != 1:
    raise SystemExit(f'expected one recurring schedule map, found {text.count(old)}')
path.write_text(text.replace(old, new, 1))
