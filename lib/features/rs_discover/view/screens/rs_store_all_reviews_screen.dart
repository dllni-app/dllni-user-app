import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/fetch_restaurant_details_model.dart';
import '../../domain/usecases/fetch_restaurant_details_use_case.dart';

@AutoRoutePage(path: "/store-all-reviews")
class SmStoreAllReviewsScreen extends StatefulWidget {
  const SmStoreAllReviewsScreen({super.key, required this.restaurantId});

  final int restaurantId;

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
    final res = await useCase(
      FetchRestaurantDetailsParams(restaurantId: widget.restaurantId),
    );
    return res.fold((_) => null, (r) => r);
  }

  int _stars(double rating) {
    final value = rating.clamp(0, 5).round();
    return value == 0 ? 1 : value;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FetchRestaurantDetailsModel?>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        final details = snapshot.data;
        final reviews = details?.reviews ?? const <RestaurantDetailsReview>[];
        final ratingAverage = details?.ratingSummary?.average ??
            details?.restaurant?.averageRating ??
            0;
        final ratingTotal = details?.ratingSummary?.total ??
            details?.restaurant?.totalReviews ??
            reviews.length;

        return Scaffold(
          backgroundColor: context.onPrimary,
          appBar: AppBar(
            backgroundColor: context.onPrimary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: AppText(
              'كل التقييمات',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length + 1,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (_, index) {
              if (index == 0) {
                return _SummaryCard(
                  ratingAverage: ratingAverage,
                  ratingTotal: ratingTotal,
                  stars: _stars(ratingAverage),
                );
              }
              if (reviews.isEmpty) {
                return AppText(
                  'لا توجد تقييمات بعد',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }
              return _ReviewTile(review: reviews[index - 1]);
            },
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.ratingAverage,
    required this.ratingTotal,
    required this.stars,
  });

  final double ratingAverage;
  final int ratingTotal;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          AppText(
            ratingAverage.toStringAsFixed(1),
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 34,
              fontWeight: FontWeight.w700,
              height: 38 / 34,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(
                  stars,
                  (_) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: FaIcon(
                      FontAwesomeIcons.solidStar,
                      size: 13,
                      color: Color(0xFFFBBF24),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4),
              AppText(
                '$ratingTotal تقييم',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final RestaurantDetailsReview review;

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
                child: AppText(
                  review.reviewerName ?? 'مستخدم',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppText(
                review.createdAt ?? 'حديثاً',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: List.generate(
              review.rating == 0 ? 1 : review.rating,
              (_) => Padding(
                padding: const EdgeInsets.only(left: 2),
                child: FaIcon(
                  FontAwesomeIcons.solidStar,
                  size: 12,
                  color: Color(0xFFFBBF24),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          AppText(
            review.comment ?? 'بدون تعليق',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 18 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
