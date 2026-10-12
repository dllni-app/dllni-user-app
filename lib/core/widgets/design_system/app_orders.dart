import 'package:flutter/material.dart';
import 'alnadha_tokens.dart';
import 'app_layout.dart';
import 'app_feedback.dart';

/// View-only order summary; values/actions must originate in backend presenters.
class AppOrderCard extends StatelessWidget {
  const AppOrderCard({
    super.key,
    required this.title,
    required this.reference,
    required this.status,
    required this.scheduleLabel,
    required this.section,
    this.amountLabel,
    this.statusIntent = AppStatusIntent.info,
    this.onTap,
    this.needsAttention = false,
  });
  final String title;
  final String reference;
  final String status;
  final String scheduleLabel;
  final String? amountLabel;
  final AppSection section;
  final AppStatusIntent statusIntent;
  final VoidCallback? onTap;
  final bool needsAttention;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    section: section,
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: section.soft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.receipt_long_outlined, color: section.ink),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: AlnadhaTokens.sectionTitle)),
            if (needsAttention)
              const Icon(
                Icons.notifications_active_outlined,
                color: AlnadhaTokens.warning,
                size: 20,
              ),
          ],
        ),
        const SizedBox(height: 10),
        AppStatusBadge(label: status, intent: statusIntent),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              reference,
              style: AlnadhaTokens.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(scheduleLabel, style: AlnadhaTokens.body),
        if (amountLabel != null) ...[
          const SizedBox(height: 6),
          Text(amountLabel!, style: AlnadhaTokens.sectionTitle),
        ],
      ],
    ),
  );
}

class AppPriceLine {
  const AppPriceLine({required this.label, required this.formattedAmount});
  final String label;
  final String formattedAmount;
}

/// No client-side arithmetic or invented quote. All formatted values are passed in.
class AppPriceSummary extends StatelessWidget {
  const AppPriceSummary({
    super.key,
    required this.lines,
    required this.totalFormatted,
    this.provisional = false,
    this.note,
  });
  final List<AppPriceLine> lines;
  final String totalFormatted;
  final bool provisional;
  final String? note;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('ملخص التكلفة', style: AlnadhaTokens.sectionTitle),
        if (provisional) ...[
          const SizedBox(height: 8),
          const AppStatusBadge(
            label: 'سعر تقديري',
            intent: AppStatusIntent.pending,
          ),
        ],
        const SizedBox(height: 8),
        for (final line in lines)
          AppInfoRow(label: line.label, value: line.formattedAmount),
        const Divider(color: AlnadhaTokens.border),
        AppInfoRow(label: 'الإجمالي', value: totalFormatted),
        if (note != null) Text(note!, style: AlnadhaTokens.caption),
      ],
    ),
  );
}

class AppTimelineEntry {
  const AppTimelineEntry({
    required this.title,
    this.detail,
    this.timestamp,
    this.completed = false,
    this.current = false,
  });
  final String title;
  final String? detail;
  final String? timestamp;
  final bool completed;
  final bool current;
}

class AppStatusTimeline extends StatelessWidget {
  const AppStatusTimeline({super.key, required this.entries});
  final List<AppTimelineEntry> entries;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var index = 0; index < entries.length; index++)
        Builder(
          builder: (context) {
            final entry = entries[index];
            final highlighted = entry.current || entry.completed;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      entry.completed
                          ? Icons.check_circle
                          : entry.current
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: highlighted
                          ? AlnadhaTokens.primary
                          : AlnadhaTokens.muted,
                    ),
                    if (index < entries.length - 1)
                      Container(
                        width: 2,
                        height: 38,
                        color: AlnadhaTokens.border,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.title, style: AlnadhaTokens.body),
                        if (entry.detail != null)
                          Text(entry.detail!, style: AlnadhaTokens.caption),
                        if (entry.timestamp != null)
                          Text(entry.timestamp!, style: AlnadhaTokens.caption),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
    ],
  );
}
