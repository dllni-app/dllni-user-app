import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

export '../data/cl_worker_profile_mock_data.dart' show WorkerProfileRouteArgs;

import '../data/cl_worker_profile_mock_data.dart';
import '../widgets/cl_rating_summary_card_widget.dart';
import '../widgets/cl_worker_review_card_widget.dart';

@AutoRoutePage()
class ClWorkerProfileDetailScreen extends StatelessWidget {
  const ClWorkerProfileDetailScreen({super.key, required this.args});

  final WorkerProfileRouteArgs args;

  @override
  Widget build(BuildContext context) {
    final apiWorker = args.worker;
    final workerDescription = apiWorker?.description?.trim();
    final averageRating = apiWorker?.ratings?.average ?? apiWorker?.rating ?? 0;
    final ratingsCount = apiWorker?.ratings?.count ?? apiWorker?.totalJobs ?? 0;
    final profileImageUrl = apiWorker?.profileImage?.trim();
    final profile = apiWorker == null
        ? WorkerProfileMockData.getById(args.workerId)
        : WorkerProfileData(
            id: (apiWorker.id ?? 0).toString(),
            name: apiWorker.name ?? 'عامل خدمة',
            verified: (apiWorker.badges ?? const []).contains('verified'),
            avatarColor: const Color(0xFFE2E8F0),
            badgeValue: averageRating.toStringAsFixed(1),
            completedTasksText: 'أكمل مقدم الخدمة ${apiWorker.completedJobs ?? 0} من أصل ${apiWorker.totalJobs ?? 0} مهمة',
            aboutText: workerDescription == null || workerDescription.isEmpty
                ? 'مقدم خدمة نظافة مع سجل خدمات سابقة وتقييمات إيجابية من العملاء.'
                : workerDescription,
            ratingSummary: WorkerRatingSummary(
              average: averageRating,
              totalReviews: ratingsCount,
              starCounts: const <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
            ),
            reviews: const [],
            profileImageUrl: profileImageUrl == null || profileImageUrl.isEmpty ? null : profileImageUrl,
          );
    final previewReviews = profile.reviews.take(10).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _ProfileHeaderWidget(profile: profile),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopInfoPillsWidget(profile: profile),
                        const SizedBox(height: 18),
                        AppText.titleSmall('نبذة عن مقدم الخدمة', fontWeight: FontWeight.bold, textAlign: TextAlign.start),
                        const SizedBox(height: 8),
                        AppText.labelLarge(
                          profile.aboutText,
                          color: const Color(0xFF4B5563),
                          textAlign: TextAlign.start,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText.titleSmall(
                              'تقييمات العملاء',
                              color: const Color(0xFF111827),
                              fontWeight: FontWeight.w900,
                              textAlign: TextAlign.start,
                            ),
                            InkWell(
                              onTap: () {
                                context.pushRoute('/clworkerreviewsall', arguments: args);
                              },
                              child: AppText.labelLarge(
                                'عرض الكل',
                                color: const Color(0xFF4CAF50),
                                fontWeight: FontWeight.w500,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClRatingSummaryCardWidget(summary: profile.ratingSummary),
                        const SizedBox(height: 14),
                        ...previewReviews.map(
                          (review) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ClWorkerReviewCardWidget(review: review),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              context.pushRoute('/clworkerreviewsall', arguments: args);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E2A78),
                              side: const BorderSide(color: Color(0xFFD5D9E2)),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: AppText.bodyMedium(
                              'عرض جميع التقييمات (${profile.ratingSummary.totalReviews})',
                              color: const Color(0xFF1E2A78),
                              fontWeight: FontWeight.w700,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _ProfileActionsWidget(args: args),
        ],
      ),
    );
  }
}

class _ProfileHeaderWidget extends StatelessWidget {
  const _ProfileHeaderWidget({required this.profile});

  final WorkerProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [Color(0xFF1E2A78), Color(0xFF0CBBC7)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, size: 17, color: Color(0xFF1E2A78)),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 54,
                backgroundColor: profile.avatarColor,
                backgroundImage: profile.profileImageUrl == null ? null : NetworkImage(profile.profileImageUrl!),
                child: profile.profileImageUrl == null ? const Icon(Icons.person, size: 62, color: Color(0xFF334155)) : null,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (profile.verified) const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                  if (profile.verified) const SizedBox(width: 6),
                  AppText.titleLarge(profile.name, color: Colors.white, fontWeight: FontWeight.w800, textAlign: TextAlign.center),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopInfoPillsWidget extends StatelessWidget {
  const _TopInfoPillsWidget({required this.profile});

  final WorkerProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoPillWidget(
          text: '(${profile.badgeValue})',
          icon: Icons.star_rounded,
          bgColor: const Color(0xFF4CAF50).withAlpha(27),
          textColor: const Color(0xFF4B5563),
          iconColor: Colors.amberAccent,
        ),
        const SizedBox(height: 8),
        _InfoPillWidget(text: profile.completedTasksText, bgColor: const Color(0xFFDCFCE7), textColor: const Color(0xFF166534)),
      ],
    );
  }
}

class _InfoPillWidget extends StatelessWidget {
  const _InfoPillWidget({required this.text, this.icon, required this.bgColor, required this.textColor, this.iconColor});

  final String text;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...{Icon(icon, color: iconColor, size: 18), const SizedBox(width: 6)},
          AppText.bodyMedium(text, color: textColor, fontWeight: FontWeight.w600, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ProfileActionsWidget extends StatelessWidget {
  const _ProfileActionsWidget({required this.args});

  final WorkerProfileRouteArgs args;

  int? _resolveWorkerId() {
    return args.worker?.id ?? int.tryParse(args.workerId);
  }

  @override
  Widget build(BuildContext context) {
    final workerId = _resolveWorkerId();
    return Container(
      color: const Color(0xFFF2F2F2),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 18),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9FA8C8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: AppText.bodyMedium('رفض العامل', color: Colors.white, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (workerId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر تحديد مقدم الخدمة')));
                    return;
                  }
                  context.pop(workerId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF08BFCF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: AppText.bodyMedium('قبول العامل', color: Colors.white, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
