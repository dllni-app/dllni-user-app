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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'معلومات المطعم',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (description.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              AppText(
                description,
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 20 / 13,
                ),
              ),
            ],
            const SizedBox(height: 14),
            _RestaurantInfoRow(
              icon: FontAwesomeIcons.locationDot,
              title: 'العنوان',
              value: address,
            ),
            const SizedBox(height: 12),
            _WorkingHoursSection(lines: workingHoursLines),
          ],
        ),
      ),
    );
  }
}

class _RestaurantInfoRow extends StatelessWidget {
  const _RestaurantInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final FaIconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FaIcon(icon, size: 14, color: const Color(0xFF6B7280)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              AppText(
                value,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 20 / 13,
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
    final items = _parseWorkingHours(widget.lines);
    final todayName = _todayName(DateTime.now().weekday);
    _WorkingHourItem? today;
    for (final item in items) {
      if (item.day == todayName) {
        today = item;
        break;
      }
    }

    final hasSchedule = items.isNotEmpty;
    final summary = today != null
        ? 'اليوم • ${today.hours}'
        : (hasSchedule ? items.first.hours : 'غير متاح');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: hasSchedule
                ? () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.onPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.clock,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          'ساعات العمل',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AppText(
                          summary,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: today?.isClosed == true
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF4B5563),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 18 / 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasSchedule) ...[
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText(
                          _expanded ? 'إخفاء' : 'عرض كل الأيام',
                          style: TextStyle(
                            color: context.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 180),
                          turns: _expanded ? 0.5 : 0,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: context.primary,
                          ),
                        ),
                      ],
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
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    children: items
                        .map(
                          (item) => _WorkingHourRow(
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

  List<_WorkingHourItem> _parseWorkingHours(List<String> lines) {
    final result = <_WorkingHourItem>[];
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line == 'غير متاح') continue;

      final separator = line.indexOf(':');
      if (separator <= 0 || separator >= line.length - 1) continue;

      final day = line.substring(0, separator).trim();
      final hours = line.substring(separator + 1).trim();
      if (day.isEmpty || hours.isEmpty) continue;

      result.add(
        _WorkingHourItem(
          day: day,
          hours: hours,
          isClosed: hours == 'مغلق',
        ),
      );
    }
    return result;
  }

  String _todayName(int weekday) {
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

class _WorkingHourRow extends StatelessWidget {
  const _WorkingHourRow({required this.item, required this.isToday});

  final _WorkingHourItem item;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isToday ? context.primary.withAlpha(16) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                AppText(
                  item.day,
                  style: TextStyle(
                    color: isToday
                        ? context.primary
                        : const Color(0xFF374151),
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.primary.withAlpha(24),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: AppText(
                      'اليوم',
                      style: TextStyle(
                        color: context.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppText(
            item.hours,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: item.isClosed
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF111827),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkingHourItem {
  const _WorkingHourItem({
    required this.day,
    required this.hours,
    required this.isClosed,
  });

  final String day;
  final String hours;
  final bool isClosed;
}
