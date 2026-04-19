import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/widgets/rs_app_product_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/fetch_restaurant_details_model.dart';
import '../../data/models/fetch_restaurant_products_search_model.dart';
import '../models/product_preview_data.dart';
import '../models/store_product_item.dart';
import '../screens/rs_product_details_screen.dart';
import '../screens/rs_store_all_reviews_screen.dart';

class StoreProductsPreviewSection extends StatelessWidget {
  const StoreProductsPreviewSection({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    required this.selectedFilterIndex,
    required this.onFilterChanged,
    required this.filters,
    required this.products,
  });

  final int restaurantId;
  final String restaurantName;
  final int selectedFilterIndex;
  final void Function(int index) onFilterChanged;
  final List<String> filters;
  final List<StoreProductItem> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              AppText(
                'المنتجات',
                style: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w700, height: 28 / 18),
              ),
              Spacer(),
              InkWell(
                onTap: () => context.pushRoute('/rs_store-all-products', arguments: restaurantId),
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AppText(
                    'عرض الكل',
                    style: TextStyle(color: Color(0xFF4CAF50), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, index) => SizedBox(width: 8),
            itemBuilder: (_, index) {
              final isSelected = selectedFilterIndex == index;
              return InkWell(
                onTap: () => onFilterChanged(index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: isSelected ? context.primary : Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
                  child: AppText(
                    filters[index],
                    style: TextStyle(
                      color: isSelected ? context.onPrimary : Color(0xFF4B5563),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 16 / 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16),
        if (products.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: AppText(
              'لا توجد منتجات حالياً',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length > 5 ? 5 : products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (_, index) => StoreProductCard(product: products[index], restaurantName: restaurantName),
          ),
      ],
    );
  }
}

class StoreProductCard extends StatefulWidget {
  const StoreProductCard({super.key, required this.product, required this.restaurantName});

  final StoreProductItem product;
  final String restaurantName;

  @override
  State<StoreProductCard> createState() => _StoreProductCardState();
}

class _StoreProductCardState extends State<StoreProductCard> {
  StoreProductItem get product => widget.product;

  String get restaurantName => widget.restaurantName;

  @override
  Widget build(BuildContext context) {
    final safeImage = (product.imageUrl ?? '').trim();
    final safeRestaurant = restaurantName.trim().isNotEmpty ? restaurantName.trim() : 'مطعم';
    final safeOffer = ((product.offerBadgeText ?? product.offer ?? '').trim()).isNotEmpty
        ? (product.offerBadgeText ?? product.offer ?? '').trim()
        : 'عرض';

    return RsAppProductCard(
      image: safeImage,
      productId: product.id!,
      title: product.name,
      restaurant: safeRestaurant,
      price: product.priceText,
      offer: FetchRestaurantProductsSearchModelActiveOffer(
        badgeText: product.offerBadgeText,
        discountType: product.offerDiscountType,
        discountValue: product.offerDiscountValue,
        title: product.offerUrgencyTag,
      ),
      onTap: () => context.pushRoute(
        '/rs_product',
        arguments: ProductDetailsScreenParams(product: ProductPreviewData.fromStoreProduct(product, fallbackRestaurantName: safeRestaurant)),
      ),
    );
  }
}

class StoreReviewsPreviewSection extends StatelessWidget {
  const StoreReviewsPreviewSection({
    super.key,
    required this.restaurantId,
    required this.reviews,
    required this.ratingAverage,
    required this.ratingTotal,
    required this.ratingCounts,
  });

  final int restaurantId;
  final List<RestaurantDetailsReview> reviews;
  final double ratingAverage;
  final int ratingTotal;
  final Map<int, int> ratingCounts;

  @override
  Widget build(BuildContext context) {
    final previewReviews = reviews.take(2).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'تقييمات العملاء',
            style: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w700, height: 28 / 18),
          ),
          SizedBox(height: 16),
          StoreRatingSection(ratingAverage: ratingAverage, ratingTotal: ratingTotal, ratingCounts: ratingCounts),
          SizedBox(height: 14),
          if (previewReviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: AppText(
                'لا توجد تقييمات بعد',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ...previewReviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StoreReviewCard(review: review),
            ),
          ),
          if (previewReviews.isNotEmpty) ...[
            SizedBox(height: 4),
            InkWell(
              onTap: () => context.pushRoute(
                '/rs_store-all-reviews',
                arguments: StoreAllReviewsScreenParams(restaurantId: restaurantId, reviewsPerPage: ratingTotal > 0 ? ratingTotal : 10),
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
                child: AppText(
                  'عرض جميع التقييمات ($ratingTotal)',
                  style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600, height: 20 / 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StoreRatingSection extends StatelessWidget {
  const StoreRatingSection({super.key, required this.ratingAverage, required this.ratingTotal, required this.ratingCounts});

  final double ratingAverage;
  final int ratingTotal;
  final Map<int, int> ratingCounts;

  @override
  Widget build(BuildContext context) {
    final safeRating = ratingAverage.clamp(0, 5).toDouble();
    final maxCount = ratingCounts.values.fold<int>(0, (prev, value) => value > prev ? value : prev);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((stars) {
                    final count = ratingCounts[stars] ?? 0;
                    final factor = maxCount == 0 ? 0.0 : count / maxCount;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Row(
                              children: [
                                Icon(Icons.star, size: 16, color: Color(0xFFFBBF24)),
                                AppText(
                                  '$stars',
                                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: factor,
                                minHeight: 5,
                                backgroundColor: Color(0xFFE5E7EB),
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFBBF24)),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            width: 24,
                            child: AppText(
                              '$count',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(width: 14),
              SizedBox(
                width: 100,
                child: Column(
                  children: [
                    AppText(
                      safeRating.toStringAsFixed(1),
                      style: TextStyle(color: Color(0xFF111827), fontSize: 36, fontWeight: FontWeight.w700, height: 40 / 36),
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final active = index < safeRating.round();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: FaIcon(
                            active ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                            size: 12,
                            color: active ? Color(0xFFFBBF24) : Color(0xFFD1D5DB),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 6),
                    AppText(
                      '$ratingTotal تقييم',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StoreRestaurantInfoCard extends StatelessWidget {
  const StoreRestaurantInfoCard({super.key, required this.description, required this.address, required this.workingHoursLines});

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
          border: Border.all(color: Color(0xFFF3F4F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'معلومات المطعم',
              style: TextStyle(color: Color(0xFF111827), fontSize: 17, fontWeight: FontWeight.w700),
            ),
            if (description.trim().isNotEmpty) ...[
              SizedBox(height: 10),
              AppText(
                description,
                style: TextStyle(color: Color(0xFF4B5563), fontSize: 13, fontWeight: FontWeight.w500, height: 20 / 13),
              ),
            ],
            SizedBox(height: 12),
            _StoreInfoRow(icon: FontAwesomeIcons.locationDot, title: 'العنوان', value: address),
            SizedBox(height: 10),
            _StoreInfoRow(icon: FontAwesomeIcons.clock, title: 'ساعات العمل', value: '• ${workingHoursLines.join('\n• ')}', isMultiline: true),
          ],
        ),
      ),
    );
  }
}

class _StoreInfoRow extends StatelessWidget {
  const _StoreInfoRow({required this.icon, required this.title, required this.value, this.isMultiline = false});

  final FaIconData icon;
  final String title;
  final String value;
  final bool isMultiline;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        FaIcon(icon, size: 14, color: Color(0xFF6B7280)),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 2),
              AppText(
                value,
                textAlign: TextAlign.start,
                style: TextStyle(color: Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w600, height: 20 / 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StoreReviewCard extends StatelessWidget {
  const StoreReviewCard({super.key, required this.review});

  final RestaurantDetailsReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                radius: 22,
                backgroundColor: Color(0xFFE5E7EB),
                child: Icon(Icons.person, size: 16, color: Color(0xFF6B7280)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      review.reviewerName ?? 'مستخدم',
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w700, height: 20 / 13),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        review.rating == 0 ? 1 : review.rating,
                        (_) => Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: FaIcon(FontAwesomeIcons.solidStar, size: 12, color: Color(0xFFFBBF24)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppText(
                review.createdAt ?? 'حديثاً',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12),
              ),
            ],
          ),
          SizedBox(height: 12),
          AppText(
            review.comment ?? 'بدون تعليق',
            style: TextStyle(color: Color(0xFF4B5563), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
