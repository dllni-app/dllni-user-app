import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/utils/cleaning_date_time_ui_format.dart';

import '../../domain/models/cleaning_recurring_session.dart';

class ClRecurringScheduleSectionWidget extends StatelessWidget {
  const ClRecurringScheduleSectionWidget({
    super.key,
    required this.enabled,
    required this.pattern,
    this.workerScope = CleaningRecurringWorkerScope.any,
    this.calculationMode = CleaningRecurringCalculationMode.task,
    this.hoursPerVisit = 2,
    required this.occurrences,
    required this.maxOccurrences,
    required this.sessions,
    required this.onEnabledChanged,
    required this.onPatternChanged,
    this.onWorkerScopeChanged,
    this.onCalculationModeChanged,
    this.onHoursPerVisitChanged,
    required this.onOccurrencesChanged,
    required this.onAddVisit,
    required this.onEditVisit,
    required this.onRemoveVisit,
  });

  final bool enabled;
  final CleaningRecurringPattern pattern;
  final CleaningRecurringWorkerScope workerScope;
  final CleaningRecurringCalculationMode calculationMode;
  final double hoursPerVisit;
  final int occurrences;
  final int maxOccurrences;
  final List<CleaningRecurringSessionInput> sessions;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<CleaningRecurringPattern> onPatternChanged;
  final ValueChanged<CleaningRecurringWorkerScope>? onWorkerScopeChanged;
  final ValueChanged<CleaningRecurringCalculationMode>?
  onCalculationModeChanged;
  final ValueChanged<double>? onHoursPerVisitChanged;
  final ValueChanged<int> onOccurrencesChanged;
  final VoidCallback onAddVisit;
  final ValueChanged<int> onEditVisit;
  final ValueChanged<int> onRemoveVisit;

  static const List<String> _visitOrdinals = <String>[
    'الأولى',
    'الثانية',
    'الثالثة',
    'الرابعة',
    'الخامسة',
    'السادسة',
    'السابعة',
    'الثامنة',
    'التاسعة',
    'العاشرة',
    'الحادية عشرة',
    'الثانية عشرة',
    'الثالثة عشرة',
    'الرابعة عشرة',
    'الخامسة عشرة',
    'السادسة عشرة',
    'السابعة عشرة',
    'الثامنة عشرة',
    'التاسعة عشرة',
    'العشرون',
    'الحادية والعشرون',
    'الثانية والعشرون',
    'الثالثة والعشرون',
    'الرابعة والعشرون',
    'الخامسة والعشرون',
    'السادسة والعشرون',
    'السابعة والعشرون',
    'الثامنة والعشرون',
    'التاسعة والعشرون',
    'الثلاثون',
    'الحادية والثلاثون',
  ];

  String _visitLabel(int index) {
    if (index >= 0 && index < _visitOrdinals.length) {
      return 'الزيارة ${_visitOrdinals[index]}';
    }
    return 'الزيارة ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final maxWindowDays = pattern == CleaningRecurringPattern.monthly
        ? cleaningRecurringMaxWindowDays
        : cleaningRecurringStandardWindowDays;
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
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: enabled,
              onChanged: onEnabledChanged,
              title: const Text(
                'حجز دوري لخدمة التنظيف',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'كرّر نفس خدمة التنظيف في مواعيد متعددة ضمن حجز واحد.',
              ),
            ),
            if (enabled) ...[
              const Divider(height: 22),
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  'حدد أيام الزيارات ومواعيدها. رح نحسب مدة كل زيارة تلقائياً حسب تفاصيل التنظيف.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ),
              DropdownButtonFormField<CleaningRecurringPattern>(
                initialValue: pattern,
                decoration: const InputDecoration(
                  labelText: 'نمط التكرار',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: CleaningRecurringPattern.values
                    .map(
                      (item) => DropdownMenuItem<CleaningRecurringPattern>(
                        value: item,
                        child: Text(item.labelAr),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) onPatternChanged(value);
                },
              ),
              if (pattern.isGenerated) ...[
                const SizedBox(height: 6),
                Text(
                  pattern == CleaningRecurringPattern.weekly
                      ? 'أسبوعي: زيارة كل 7 أيام، بنفس الموعد.'
                      : pattern == CleaningRecurringPattern.monthly
                      ? 'شهري: بنفس اليوم من كل شهر. الشهر اللي ما فيه هاليوم منتجاوزه بدون تغيير الموعد.'
                      : 'يومي: زيارة كل يوم بنفس الموعد.',
                  style: const TextStyle(
                    color: SharedPlatformColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (pattern.isGenerated) ...[
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'عدد الزيارات',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: 'تقليل عدد الزيارات',
                      onPressed: occurrences > 2
                          ? () => onOccurrencesChanged(occurrences - 1)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 40),
                      alignment: Alignment.center,
                      child: Text(
                        '$occurrences',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'زيادة عدد الزيارات',
                      onPressed: occurrences < maxOccurrences
                          ? () => onOccurrencesChanged(occurrences + 1)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                Text(
                  maxOccurrences >= 2
                      ? 'يمكن حجز حتى $maxOccurrences زيارات خلال $maxWindowDays يومًا.'
                      : 'لا توجد زيارة ثانية متاحة خلال $maxWindowDays يومًا من التاريخ المختار.',
                  style: TextStyle(
                    color: maxOccurrences >= 2
                        ? const Color(0xFF6B7280)
                        : const Color(0xFFB45309),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                const Text(
                  'أضف زيارتين على الأقل. كل زيارة تبقى مستقلة من حيث العامل والحالة والتنفيذ.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              ...List.generate(sessions.length, (index) {
                final session = sessions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      12,
                      10,
                      8,
                      10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: SharedPlatformColors.cleaningSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: SharedPlatformColors.cleaningInk,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _visitLabel(index),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CleaningDateTimeUiFormat.dateFromApiDate(
                                  session.dateApi,
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.schedule_outlined,
                                    size: 15,
                                    color: SharedPlatformColors.primary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    CleaningDateTimeUiFormat.time(session.time),
                                    style: const TextStyle(
                                      color: SharedPlatformColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!pattern.isGenerated) ...[
                          IconButton(
                            tooltip: 'تعديل الزيارة',
                            onPressed: () => onEditVisit(index),
                            icon: const Icon(Icons.edit_calendar_outlined),
                          ),
                          if (index > 0)
                            IconButton(
                              tooltip: 'حذف الزيارة',
                              onPressed: () => onRemoveVisit(index),
                              icon: const Icon(Icons.delete_outline),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              if (!pattern.isGenerated)
                OutlinedButton.icon(
                  onPressed: onAddVisit,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('إضافة زيارة أخرى'),
                ),
              if (sessions.length < 2) ...[
                const SizedBox(height: 8),
                const Text(
                  'يلزم إضافة زيارة ثانية على الأقل لتفعيل الحجز الدوري.',
                  style: TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
