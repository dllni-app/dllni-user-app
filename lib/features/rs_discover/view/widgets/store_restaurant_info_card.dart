import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StoreRestaurantInfoCard extends StatelessWidget {
  const StoreRestaurantInfoCard({
    super.key,
    required this.description,
    required this.address,
    required this.workingHoursLines,
  });

  final String description;
  final String address;
  final List<String> workingHoursLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.onPrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'معلومات المطعم',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (description.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              AppText(
                description,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            ],
            const SizedBox(height: 18),
            _InfoRow(
              icon: FontAwesomeIcons.locationDot,
              title: 'العنوان',
              value: address,
            ),
            const SizedBox(height: 14),
            _WorkingHoursSection(lines: workingHoursLines),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, size: 15, color: const Color(0xFF6B7280)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              AppText(
                value,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkingHoursSection extends StatefulWidget {
  const _WorkingHoursSection({required this.lines});

  final List<String> lines;

  @override
  State<_WorkingHoursSection> createState() => _WorkingHoursSectionState();
}

class _WorkingHoursSectionState extends State<_WorkingHoursSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final items = _parse(widget.lines);
    final todayName = _dayName(DateTime.now().weekday);
    final today = items.where((e) => e.day == todayName).firstOrNull;
    final hasSchedule = items.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: hasSchedule
                ? () => setState(() => _expanded = !_expanded)
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.onPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.clock,
                      size: 15,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          'أوقات العمل',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (today != null)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: today.isClosed
                                      ? const Color(0xFFFEE2E2)
                                      : const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: AppText(
                                  today.isClosed ? 'مغلق اليوم' : 'اليوم',
                                  style: TextStyle(
                                    color: today.isClosed
                                        ? const Color(0xFFB91C1C)
                                        : const Color(0xFF15803D),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppText(
                                  today.hours,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: today.isClosed
                                        ? const Color(0xFFB91C1C)
                                        : const Color(0xFF4B5563),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          AppText(
                            hasSchedule ? 'اضغط لعرض الجدول الأسبوعي' : 'غير متاح',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (hasSchedule) ...[
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 180),
                      turns: _expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: context.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: items
                        .map(
                          (item) => _HourRow(
                            item: item,
                            isToday: item.day == todayName,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_HourItem> _parse(List<String> lines) {
    final result = <_HourItem>[];
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty || line == 'غير متاح') continue;
      final separator = line.indexOf(':');
      if (separator <= 0 || separator >= line.length - 1) continue;
      final day = line.substring(0, separator).trim();
      final hours = line.substring(separator + 1).trim();
      result.add(_HourItem(day: day, hours: hours, isClosed: hours == 'مغلق'));
    }
    return result;
  }

  String _dayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'الاثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
        return 'الأحد';
      default:
        return '';
    }
  }
}

class _HourRow extends StatelessWidget {
  const _HourRow({required this.item, required this.isToday});

  final _HourItem item;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: isToday ? context.primary.withAlpha(14) : context.onPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday
              ? context.primary.withAlpha(40)
              : const Color(0xFFF3F4F6),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: AppText(
              item.day,
              style: TextStyle(
                color: isToday ? context.primary : const Color(0xFF374151),
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: AppText(
              item.hours,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: item.isClosed
                    ? const Color(0xFFB91C1C)
                    : const Color(0xFF111827),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourItem {
  const _HourItem({
    required this.day,
    required this.hours,
    required this.isClosed,
  });

  final String day;
  final String hours;
  final bool isClosed;
}
