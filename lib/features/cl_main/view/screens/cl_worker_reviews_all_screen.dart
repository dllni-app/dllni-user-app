import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../data/cl_worker_profile_mock_data.dart';
import '../widgets/cl_rating_summary_card_widget.dart';
import '../widgets/cl_worker_review_card_widget.dart';

@AutoRoutePage()
class ClWorkerReviewsAllScreen extends StatelessWidget {
  const ClWorkerReviewsAllScreen({super.key, required this.args});

  final WorkerProfileRouteArgs args;

  @override
  Widget build(BuildContext context) {
    final profile = WorkerProfileMockData.getById(args.workerId);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: AppText.titleLarge(
          'تقييمات العملاء',
          color: Color(0xFF111827),
          fontWeight: FontWeight.w800,
          textAlign: TextAlign.start,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_forward, color: Color(0xFF1E2A78)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 20),
        children: [
          ClRatingSummaryCardWidget(summary: profile.ratingSummary),
          const SizedBox(height: 12),
          ...profile.reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClWorkerReviewCardWidget(review: review),
            ),
          ),
        ],
      ),
    );
  }
}
