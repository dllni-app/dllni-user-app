import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/fetch_restaurant_details_model.dart';
import '../../domain/usecases/fetch_restaurant_details_use_case.dart';
import '../widgets/store_details_sub_widgets.dart';

class StoreAllReviewsScreenParams {
  const StoreAllReviewsScreenParams({required this.restaurantId, required this.reviewsPerPage});

  final int restaurantId;
  final int reviewsPerPage;
}

@AutoRoutePage(path: "/rs_store-all-reviews")
class SmStoreAllReviewsScreen extends StatefulWidget {
  const SmStoreAllReviewsScreen({super.key, required this.params});

  final StoreAllReviewsScreenParams params;

  @override
  State<SmStoreAllReviewsScreen> createState() => _SmStoreAllReviewsScreenState();
}

class _SmStoreAllReviewsScreenState extends State<SmStoreAllReviewsScreen> {
  late final Future<FetchRestaurantDetailsModel?> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _load();
  }

  Future<FetchRestaurantDetailsModel?> _load() async {
    final useCase = getIt<FetchRestaurantDetailsUseCase>();
    final safeReviewsPerPage = widget.params.reviewsPerPage > 0 ? widget.params.reviewsPerPage : 10;
    final res = await useCase(FetchRestaurantDetailsParams(restaurantId: widget.params.restaurantId, reviewsPerPage: safeReviewsPerPage));
    return res.fold((_) => null, (r) => r);
  }

  Map<int, int> _countsFromReviews(List<RestaurantDetailsReview> reviews) {
    final counts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final review in reviews) {
      final value = review.rating!.clamp(1, 5);
      counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts;
  }

  Map<int, int> _resolveCounts(FetchRestaurantDetailsModel? details, List<RestaurantDetailsReview> reviews) {
    final summaryCounts = details?.ratingSummary?.distribution ?? const {};
    if (summaryCounts.isNotEmpty) {
      return {5: summaryCounts[5] ?? 0, 4: summaryCounts[4] ?? 0, 3: summaryCounts[3] ?? 0, 2: summaryCounts[2] ?? 0, 1: summaryCounts[1] ?? 0};
    }
    return _countsFromReviews(reviews);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FetchRestaurantDetailsModel?>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Color(0xFFF3F4F6),
            appBar: AppBar(
              backgroundColor: context.onPrimary,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: AppText(
                'كل التقييمات',
                style: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final details = snapshot.data;
        final reviews = details?.reviews ?? const <RestaurantDetailsReview>[];
        final ratingAverage = details?.ratingSummary?.average ?? details?.restaurant?.averageRating ?? 0;
        final ratingTotal = details?.ratingSummary?.total ?? details?.restaurant?.totalReviews ?? reviews.length;
        final ratingCounts = _resolveCounts(details, reviews);

        return Scaffold(
          backgroundColor: Color(0xFFF3F4F6),
          appBar: AppBar(
            backgroundColor: context.onPrimary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: AppText(
              'كل التقييمات',
              style: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              StoreRatingSection(ratingAverage: ratingAverage, ratingTotal: ratingTotal, ratingCounts: ratingCounts),
              SizedBox(height: 14),
              if (reviews.isEmpty)
                _EmptyReviewsCard()
              else
                ...reviews.map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReviewTile(review: review),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyReviewsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFF3F4F6)),
      ),
      child: AppText(
        'لا توجد تقييمات بعد',
        style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final RestaurantDetailsReview review;

  String _formatReviewDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return 'حديثاً';
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      final datePart = rawDate.split('T').first.trim();
      final isFormatted = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(datePart);
      return isFormatted ? datePart : rawDate;
    }
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFE5E7EB),
                child: Icon(Icons.person, size: 16, color: Color(0xFF6B7280)),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppText(
                    review.userName ?? 'مستخدم',
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              AppText(
                _formatReviewDate(review.createdAt),
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: List.generate(
              (review.rating == null ||review.rating ==0 ) ? 1 : review.rating!,
              (_) => Padding(
                padding: const EdgeInsets.only(left: 2),
                child: FaIcon(FontAwesomeIcons.solidStar, size: 12, color: Color(0xFFFBBF24)),
              ),
            ),
          ),
          SizedBox(height: 8),
          AppText(
            review.comment ?? 'بدون تعليق',
            style: TextStyle(color: Color(0xFF4B5563), fontSize: 12, fontWeight: FontWeight.w500, height: 18 / 12),
          ),
        ],
      ),
    );
  }
}
