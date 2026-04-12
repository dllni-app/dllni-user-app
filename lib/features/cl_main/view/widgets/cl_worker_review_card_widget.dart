import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../data/cl_worker_profile_mock_data.dart';

class ClWorkerReviewCardWidget extends StatelessWidget {
  const ClWorkerReviewCardWidget({super.key, required this.review});

  final WorkerReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: review.reviewerAvatarColor,
                child: const Icon(Icons.person, color: Color(0xFF4B5563)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.labelMedium(review.reviewerName, color: const Color(0xFF111827), fontWeight: FontWeight.w700, textAlign: TextAlign.start),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) =>
                            Icon(index < review.rating ? Icons.star_rounded : Icons.star_border_rounded, size: 18, color: const Color(0xFFF4C20D)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AppText.bodySmall(review.timeAgo, color: const Color(0xFF6B7280), textAlign: TextAlign.start),
            ],
          ),
          const SizedBox(height: 8),
          AppText.bodyMedium(review.comment, color: const Color(0xFF374151), textAlign: TextAlign.start),
        ],
      ),
    );
  }
}
