import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/cart/cart_products_count_cubit.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../data/models/fetch_restaurant_details_model.dart';
import '../../domain/usecases/add_restaurant_cart_item_use_case.dart';
import '../models/product_preview_data.dart';
import '../models/store_product_item.dart';
import '../screens/rs_product_details_screen.dart';
import '../screens/rs_store_all_reviews_screen.dart';

class StoreProductsPreviewSection extends StatelessWidget {
  const StoreProductsPreviewSection({
    super.key,
    required this.restaurantId,
    required this.selectedFilterIndex,
    required this.onFilterChanged,
    required this.filters,
    required this.products,
  });

  final int restaurantId;
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
            separatorBuilder: (_, __) => SizedBox(width: 8),
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
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length > 5 ? 5 : products.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (_, index) => StoreProductCard(product: products[index]),
          ),
      ],
    );
  }
}

class StoreProductCard extends StatefulWidget {
  const StoreProductCard({super.key, required this.product});

  final StoreProductItem product;

  @override
  State<StoreProductCard> createState() => _StoreProductCardState();
}

class _StoreProductCardState extends State<StoreProductCard> {
  bool _isSubmittingAdd = false;

  StoreProductItem get product => widget.product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushRoute('/product', arguments: ProductDetailsScreenParams(product: ProductPreviewData.fromStoreProduct(product))),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: context.onPrimary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Color(0xFFF3F4F6)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 18, 14, 14),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (product.imageUrl ?? '').trim().isEmpty
                          ? Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)),
                            )
                          : AppImage.network(
                              product.imageUrl!,
                              width: 112,
                              height: 112,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(12),
                              errorWidget: Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)),
                              ),
                            ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Color(0xFF1F2937), fontSize: 34 / 2, fontWeight: FontWeight.w700, height: 24 / 17),
                              ),
                              SizedBox(height: 8),
                              AppText(
                                product.description,
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  AppText(
                                    product.priceText,
                                    style: TextStyle(color: Color(0xFF111827), fontSize: 36 / 2, fontWeight: FontWeight.w700, height: 28 / 18),
                                  ),
                                  SizedBox(width: 8),
                                  if (product.oldPriceText != null)
                                    AppText(
                                      product.oldPriceText!,
                                      style: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 24 / 16,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  InkWell(
                    onTap: _isSubmittingAdd ? null : _onAddToCartPressed,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: context.primary, borderRadius: BorderRadius.circular(10)),
                      child: AppText(
                        _isSubmittingAdd ? 'جاري الإضافة...' : 'اضافة الى السلة',
                        style: TextStyle(color: context.onPrimary, fontSize: 16, fontWeight: FontWeight.w700, height: 24 / 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              top: 0,
              end: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Color(0xFFFF7A00),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomRight: Radius.circular(16)),
                ),
                child: AppText(
                  'عرض اليوم',
                  style: TextStyle(color: context.onPrimary, fontSize: 11, fontWeight: FontWeight.w700, height: 16 / 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAddToCartPressed() async {
    if (_isSubmittingAdd) return;
    final productId = product.id;
    if (productId == null || productId <= 0) {
      AppToast.showToast(context: context, message: 'تعذر تحديد المنتج', type: ToastificationType.error);
      return;
    }

    setState(() {
      _isSubmittingAdd = true;
    });

    final res = await getIt<AddRestaurantCartItemUseCase>()(
      AddRestaurantCartItemParams(productId: productId, quantity: 1, modifierIds: const [], substituteProductId: null, specialInstructions: ''),
    );

    if (!mounted) return;

    res.fold(
      (failure) {
        setState(() {
          _isSubmittingAdd = false;
        });
        AppToast.showToast(context: context, message: failure.message, type: ToastificationType.error);
      },
      (result) {
        setState(() {
          _isSubmittingAdd = false;
        });
        getIt<CartProductsCountCubit>().refreshAfterAdd();
        AppToast.showToast(
          context: context,
          message: (result.message ?? '').trim().isNotEmpty ? result.message! : 'تمت إضافة المنتج إلى السلة',
          type: ToastificationType.success,
        );
      },
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
                style: TextStyle(color: Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w600, height: 20 / 13, ),
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
