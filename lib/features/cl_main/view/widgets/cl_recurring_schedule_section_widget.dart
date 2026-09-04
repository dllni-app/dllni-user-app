import 'package:flutter/material.dart';

import '../../domain/models/cleaning_recurring_session.dart';

class ClRecurringScheduleSectionWidget extends StatelessWidget {
  const ClRecurringScheduleSectionWidget({
    super.key,
    required this.enabled,
    required this.sessions,
    required this.onEnabledChanged,
    required this.onAddVisit,
    required this.onEditVisit,
    required this.onRemoveVisit,
  });

  final bool enabled;
  final List<CleaningRecurringSessionInput> sessions;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onAddVisit;
  final ValueChanged<int> onEditVisit;
  final ValueChanged<int> onRemoveVisit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
              'فعّل الخيار إذا أردت تنفيذ نفس خدمة التنظيف في أكثر من موعد ضمن حجز واحد.',
            ),
          ),
          if (enabled) ...[
            const Divider(height: 22),
            const Text(
              'أضف زيارتين على الأقل. كل زيارة تبقى مستقلة من حيث العامل والحالة والتنفيذ.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(sessions.length, (index) {
              final session = sessions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 8, 10),
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
                          color: const Color(0xFFE0F7F8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Color(0xFF0B7480),
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
                              index == 0 ? 'الزيارة الأولى' : 'الزيارة ${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${session.dateApi} • ${session.time}',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  ),
                ),
              );
            }),
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
    );
  }
}
