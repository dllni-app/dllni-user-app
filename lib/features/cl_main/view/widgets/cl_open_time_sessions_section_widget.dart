import 'package:flutter/material.dart';

import '../../../../core/models/cleaning_service_extras.dart';

class ClOpenTimeSessionsSectionWidget extends StatelessWidget {
  const ClOpenTimeSessionsSectionWidget({
    super.key,
    required this.sessions,
    required this.durationOptions,
    required this.defaultExpectedMaxMinutes,
    required this.onAddSession,
    required this.onEditSession,
    required this.onRemoveSession,
    required this.onDurationChanged,
  });

  final List<CleaningOpenTimeSessionRequest> sessions;
  final List<int> durationOptions;
  final int defaultExpectedMaxMinutes;
  final VoidCallback onAddSession;
  final ValueChanged<int> onEditSession;
  final ValueChanged<int> onRemoveSession;
  final void Function(int index, int minutes) onDurationChanged;

  @override
  Widget build(BuildContext context) {
    final options = durationOptions.isEmpty
        ? const <int>[60, 120, 240, 480]
        : durationOptions;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'مواعيد الطلب المفتوح',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'يمكنك إضافة عدة أيام. لكل يوم عداده وفوترته وحالته المستقلة.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(sessions.length, (index) {
              final session = sessions[index];
              final selectedMinutes =
                  options.contains(session.expectedMaxMinutes)
                  ? session.expectedMaxMinutes!
                  : (options.contains(defaultExpectedMaxMinutes)
                        ? defaultExpectedMaxMinutes
                        : options.first);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Semantics(
                  container: true,
                  label: 'جلسة الوقت المفتوح رقم ${index + 1}',
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F7F8),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF0B7480),
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    index == 0
                                        ? 'الجلسة الأولى'
                                        : 'الجلسة ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${_localizedDate(context, session.date)} • ${session.time}',
                                    style: const TextStyle(
                                      color: Color(0xFF4B5563),
                                      fontSize: 13,
                                      fontFeatures: <FontFeature>[
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: selectedMinutes,
                          decoration: const InputDecoration(
                            labelText: 'السقف المتوقع لهذه الجلسة',
                            helperText:
                                'يمكن طلب تمديد لاحقاً ضمن الحد الأعلى.',
                            border: OutlineInputBorder(),
                          ),
                          items: options
                              .map(
                                (minutes) => DropdownMenuItem<int>(
                                  value: minutes,
                                  child: Text(_durationLabel(minutes)),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (minutes) {
                            if (minutes != null) {
                              onDurationChanged(index, minutes);
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 48),
                              ),
                              onPressed: () => onEditSession(index),
                              icon: const Icon(Icons.edit_calendar_outlined),
                              label: const Text('تعديل الموعد'),
                            ),
                            if (index > 0)
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(48, 48),
                                  foregroundColor: const Color(0xFFB42318),
                                ),
                                onPressed: () => onRemoveSession(index),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('حذف'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: sessions.length >= 30 ? null : onAddSession,
              icon: const Icon(Icons.add_circle_outline),
              label: Text(
                sessions.length >= 30
                    ? 'تم بلوغ الحد الأعلى للجلسات'
                    : 'إضافة يوم آخر',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _localizedDate(BuildContext context, String raw) {
    final date = DateTime.tryParse(raw);
    return date == null
        ? raw
        : MaterialLocalizations.of(context).formatMediumDate(date);
  }

  static String _durationLabel(int minutes) {
    if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      if (hours == 1) return 'ساعة واحدة';
      if (hours == 2) return 'ساعتان';
      return '$hours ساعات';
    }
    return '$minutes دقيقة';
  }
}
