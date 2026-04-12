import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../data/cl_worker_profile_mock_data.dart';

class ClRatingSummaryCardWidget extends StatelessWidget {
  const ClRatingSummaryCardWidget({super.key, required this.summary});

  final WorkerRatingSummary summary;

  @override
  Widget build(BuildContext context) {
    final maxCount = summary.starCounts.values.fold<int>(0, (prev, value) => value > prev ? value : prev);
    final displayedScore = summary.average.toStringAsFixed(1);
    final filledStars = summary.average.floor().clamp(0, 5);

    return Container(
      padding: const EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            displayedScore,
            style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800, fontSize: 48, height: 1),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              5,
              (index) => Icon(index < filledStars ? Icons.star_rounded : Icons.star_border_rounded, size: 22, color: const Color(0xFFF4C20D)),
            ),
          ),
          const SizedBox(height: 6),
          AppText.labelLarge('من ${summary.totalReviews} تقييم', color: const Color(0xFF4B5563), textAlign: TextAlign.start),
          const SizedBox(height: 16),
          ...List.generate(5, (index) {
            final star = 5 - index;
            final count = summary.starCounts[star] ?? 0;
            final factor = maxCount == 0 ? 0.0 : count / maxCount;
            return Padding(
              padding: EdgeInsets.only(bottom: star == 1 ? 0 : 10),
              child: _HistogramRowWidget(star: star, count: count, progressFactor: factor),
            );
          }),
        ],
      ),
    );
  }
}

class _HistogramRowWidget extends StatelessWidget {
  const _HistogramRowWidget({required this.star, required this.count, required this.progressFactor});

  final int star;
  final int count;
  final double progressFactor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFF4C20D), size: 18),
            AppText.bodyLarge('$star', color: const Color(0xFF4B5563), textAlign: TextAlign.start),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              child: Stack(
                children: [
                  Container(color: const Color(0xFFE1E4EA)),
                  FractionallySizedBox(
                    widthFactor: progressFactor.clamp(0, 1),
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(color: const Color(0xFFF4C20D)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 38,
          child: AppText.bodyLarge('$count', color: const Color(0xFF4B5563), textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
