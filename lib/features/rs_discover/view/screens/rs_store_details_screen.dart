import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/fetch_restaurant_details_model.dart';
import '../../domain/usecases/fetch_restaurant_details_use_case.dart';
import '../models/product_preview_data.dart';
import '../models/restaurant_preview_data.dart';
import '../models/store_product_item.dart';
import 'rs_product_details_screen.dart';
import '../widgets/special_offers_section.dart';
import '../widgets/store_cover_section.dart';
import '../widgets/store_info_section.dart';
import '../widgets/store_status_section.dart';

class StoreDetailsScreenParams {
  final int restaurantId;
  final RestaurantPreviewData preview;

  const StoreDetailsScreenParams({
    required this.restaurantId,
    required this.preview,
  });
}

@AutoRoutePage(path: "/store")
class SmStoreDetailsScreen extends StatefulWidget {
  const SmStoreDetailsScreen({super.key, required this.params});

  final StoreDetailsScreenParams params;

  @override
  State<SmStoreDetailsScreen> createState() => _SmStoreDetailsScreenState();
}

class _SmStoreDetailsScreenState extends State<SmStoreDetailsScreen> {
  int _selectedFilterIndex = 0;
  late final Future<FetchRestaurantDetailsModel?> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  Future<FetchRestaurantDetailsModel?> _loadDetails() async {
    final useCase = getIt<FetchRestaurantDetailsUseCase>();
    final res = await useCase(
      FetchRestaurantDetailsParams(restaurantId: widget.params.restaurantId),
    );
    return res.fold((_) => null, (r) => r);
  }

  String _pickFirstNotEmpty(List<String?> candidates, {String fallback = ''}) {
    for (final v in candidates) {
      if (v != null && v.trim().isNotEmpty) {
        return v.trim();
      }
    }
    return fallback;
  }

  String _formatPrice(num? value) {
    if (value == null) return '—';
    return '${value.toStringAsFixed(2)} د.أ';
  }

  String _formatDistance(double? km) {
    if (km == null) return '';
    return '${km.toStringAsFixed(1)} كم منك';
  }

  String _dayAr(String? day) {
    switch ((day ?? '').toLowerCase()) {
      case 'monday':
        return 'الاثنين';
      case 'tuesday':
        return 'الثلاثاء';
      case 'wednesday':
        return 'الأربعاء';
      case 'thursday':
        return 'الخميس';
      case 'friday':
        return 'الجمعة';
      case 'saturday':
        return 'السبت';
      case 'sunday':
        return 'الأحد';
      default:
        return day ?? '';
    }
  }

  String _formatHour(String? hhmmss) {
    if (hhmmss == null || hhmmss.isEmpty) return '--:--';
    final chunks = hhmmss.split(':');
    if (chunks.length < 2) return hhmmss;
    final hour = int.tryParse(chunks[0]) ?? 0;
    final minute = chunks[1].padLeft(2, '0');
    final isPm = hour >= 12;
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h12:$minute ${isPm ? 'م' : 'ص'}';
  }

  List<String> _workingHoursLines(RestaurantDetailsRestaurant? restaurant) {
    final hours = restaurant?.operatingHours ?? const [];
    if (hours.isEmpty) return const ['غير متاح'];
    return hours.map((h) {
      final day = _dayAr(h.dayOfWeek);
      if (h.isClosed == true) return '$day: مغلق';
      return '$day: ${_formatHour(h.openTime)} - ${_formatHour(h.closeTime)}';
    }).toList();
  }

  List<StoreProductItem> _buildProducts(FetchRestaurantDetailsModel? details) {
    final byCategories =
        details?.categories
            .expand(
              (c) => c.products.map((p) => (product: p, category: c.name)),
            )
            .toList() ??
        const [];
    if (byCategories.isNotEmpty) {
      return byCategories.map((entry) {
        final p = entry.product;
        return StoreProductItem(
          id: p.id,
          name: p.name ?? 'منتج',
          description: p.description ?? 'بدون وصف',
          priceText: _formatPrice(p.discountedPrice ?? p.price),
          oldPriceText: p.discountedPrice != null
              ? _formatPrice(p.price)
              : null,
          displayPriceValue: p.discountedPrice ?? p.price,
          oldPriceValue: p.discountedPrice != null ? p.price : null,
          imageUrl: p.imageUrl ?? p.primaryImage ?? p.image,
          category: entry.category ?? p.categoryName ?? 'أخرى',
          isTop: p.isFeatured ?? false,
        );
      }).toList();
    }
    final popular = details?.popularProducts ?? const [];
    return popular.map((p) {
      return StoreProductItem(
        id: p.id,
        name: p.name ?? 'منتج',
        description: p.description ?? 'بدون وصف',
        priceText: _formatPrice(p.discountedPrice ?? p.price),
        oldPriceText: p.discountedPrice != null ? _formatPrice(p.price) : null,
        displayPriceValue: p.discountedPrice ?? p.price,
        oldPriceValue: p.discountedPrice != null ? p.price : null,
        imageUrl: p.imageUrl ?? p.primaryImage ?? p.image,
        category: p.categoryName ?? 'الأكثر طلباً',
        isTop: p.isFeatured ?? true,
      );
    }).toList();
  }

  List<String> _buildFilters(List<StoreProductItem> products) {
    final categories = products.map((e) => e.category).toSet().toList();
    return <String>['الكل', 'الأكثر طلباً', ...categories];
  }

  List<StoreProductItem> _visibleProducts(
    List<StoreProductItem> products,
    List<String> filters,
  ) {
    if (filters.isEmpty) return products;
    final safeIndex = _selectedFilterIndex >= filters.length
        ? 0
        : _selectedFilterIndex;
    final selectedFilter = filters[safeIndex];
    if (selectedFilter == 'الكل') {
      return products;
    }
    return products
        .where(
          (product) =>
              product.category == selectedFilter ||
              (selectedFilter == 'الأكثر طلباً' && product.isTop),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FetchRestaurantDetailsModel?>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        final details = snapshot.data;
        final restaurant = details?.restaurant;
        final preview = widget.params.preview;
        final offers = details?.offers ?? const <RestaurantDetailsOffer>[];

        final products = _buildProducts(details);
        final filters = _buildFilters(products);
        final safeIndex = _selectedFilterIndex >= filters.length
            ? 0
            : _selectedFilterIndex;
        if (safeIndex != _selectedFilterIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedFilterIndex = safeIndex;
              });
            }
          });
        }

        final visibleProducts = _visibleProducts(products, filters);
        final reviews = details?.reviews ?? const <RestaurantDetailsReview>[];
        final ratingAverage =
            details?.ratingSummary?.average ??
            restaurant?.averageRating ??
            preview.rating ??
            0;
        final ratingTotal =
            details?.ratingSummary?.total ??
            restaurant?.totalReviews ??
            preview.totalReviews ??
            0;

        final restaurantName = _pickFirstNotEmpty([
          restaurant?.name,
          preview.name,
        ], fallback: 'المطعم');
        final restaurantDescription = _pickFirstNotEmpty([
          restaurant?.description,
          preview.description,
        ]);
        final cuisineSummary =
            restaurant?.cuisineTypes
                .map((e) => e.name)
                .whereType<String>()
                .where((e) => e.isNotEmpty)
                .join(' • ') ??
            (preview.cuisineSummary ?? '');
        final address = _pickFirstNotEmpty([
          restaurant?.address,
          preview.address,
        ], fallback: 'غير متاح');
        final distanceLabel = _pickFirstNotEmpty([
          _formatDistance(restaurant?.distanceKm),
          preview.distanceLabel,
        ]);
        final prepMinutes =
            restaurant?.estimatedPreparationTime ??
            preview.estimatedPreparationTime ??
            0;
        final preparationLabel = prepMinutes > 0
            ? '$prepMinutes دقيقة'
            : 'غير متاح';
        final isOpenNow = !(restaurant?.isTemporarilyClosed ?? false);
        final coverImage = _pickFirstNotEmpty([
          restaurant?.imageUrl,
          restaurant?.primaryImage,
          restaurant?.image,
          restaurant?.banner,
          preview.imageUrl,
        ]);

        return Scaffold(
          backgroundColor: context.onPrimary,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StoreCoverSection(
                    title: restaurantName,
                    subtitle: restaurantDescription,
                    coverImageUrl: coverImage.isEmpty ? null : coverImage,
                    logoImageUrl: coverImage.isEmpty ? null : coverImage,
                  ),
                  SizedBox(height: 16),
                  StoreStatusSection(
                    title: restaurantName,
                    subtitle: cuisineSummary,
                    rating: ratingAverage,
                    totalReviews: ratingTotal,
                    isOpenNow: isOpenNow,
                    preparationTimeLabel: preparationLabel,
                  ),
                  SizedBox(height: 20),
                  Divider(height: 1, color: Color(0xFFF3F4F6)),
                  SizedBox(height: 28),
                  StoreInfoSection(
                    address: address,
                    distanceLabel: distanceLabel,
                    workingHoursLines: _workingHoursLines(restaurant),
                  ),
                  SizedBox(height: 16),
                  Divider(height: 1, color: Color(0xFFF3F4F6)),
                  SizedBox(height: 44),
                  SpecialOffersSection(offers: offers),
                  if (offers.isNotEmpty) ...[
                    SizedBox(height: 20),
                    Divider(height: 1, color: Color(0xFFF3F4F6)),
                    SizedBox(height: 20),
                  ],
                  _ProductsPreviewSection(
                    restaurantId: widget.params.restaurantId,
                    selectedFilterIndex: _selectedFilterIndex,
                    onFilterChanged: (index) {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
                    filters: filters,
                    products: visibleProducts,
                  ),
                  SizedBox(height: 20),
                  Divider(height: 1, color: Color(0xFFF3F4F6)),
                  SizedBox(height: 20),
                  _ReviewsPreviewSection(
                    restaurantId: widget.params.restaurantId,
                    reviews: reviews,
                    ratingAverage: ratingAverage,
                    ratingTotal: ratingTotal,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductsPreviewSection extends StatelessWidget {
  const _ProductsPreviewSection({
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
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 28 / 18,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () => context.pushRoute(
                  '/store-all-products',
                  arguments: restaurantId,
                ),
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AppText(
                    'عرض الكل',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? context.primary : Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
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
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length > 5 ? 5 : products.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (_, index) =>
                _StoreProductCard(product: products[index]),
          ),
      ],
    );
  }
}

class _StoreProductCard extends StatelessWidget {
  const _StoreProductCard({required this.product});

  final StoreProductItem product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushRoute(
        '/product',
        arguments: ProductDetailsScreenParams(
          product: ProductPreviewData.fromStoreProduct(product),
        ),
      ),
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
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_outlined,
                                color: Color(0xFF9CA3AF),
                              ),
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
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: Color(0xFF9CA3AF),
                                ),
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
                                style: TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 34 / 2,
                                  fontWeight: FontWeight.w700,
                                  height: 24 / 17,
                                ),
                              ),
                              SizedBox(height: 8),
                              AppText(
                                product.description,
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 20 / 14,
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  AppText(
                                    product.priceText,
                                    style: TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 36 / 2,
                                      fontWeight: FontWeight.w700,
                                      height: 28 / 18,
                                    ),
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
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: context.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AppText(
                      '+ إضافة',
                      style: TextStyle(
                        color: context.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 24 / 16,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFFF7A00),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: AppText(
                  'عرض اليوم',
                  style: TextStyle(
                    color: context.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 16 / 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsPreviewSection extends StatelessWidget {
  const _ReviewsPreviewSection({
    required this.restaurantId,
    required this.reviews,
    required this.ratingAverage,
    required this.ratingTotal,
  });

  final int restaurantId;
  final List<RestaurantDetailsReview> reviews;
  final double ratingAverage;
  final int ratingTotal;

  @override
  Widget build(BuildContext context) {
    final previewReviews = reviews.take(2).toList();
    final safeRating = ratingAverage.clamp(0, 5).toDouble();
    final stars = safeRating.round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'تقييمات العملاء',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 28 / 18,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                AppText(
                  safeRating.toStringAsFixed(1),
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 36 / 32,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                        stars == 0 ? 1 : stars,
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
                        height: 16 / 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 14),
          if (previewReviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: AppText(
                'لا توجد تقييمات بعد',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ...previewReviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReviewCard(review: review),
            ),
          ),
          if (previewReviews.isNotEmpty) ...[
            SizedBox(height: 4),
            InkWell(
              onTap: () => context.pushRoute(
                '/store-all-reviews',
                arguments: restaurantId,
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText(
                  'عرض جميع التقييمات ($ratingTotal)',
                  style: TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 20 / 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

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
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 20 / 13,
                      ),
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
                  ],
                ),
              ),
              AppText(
                review.createdAt ?? 'حديثاً',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          AppText(
            review.comment ?? 'بدون تعليق',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
