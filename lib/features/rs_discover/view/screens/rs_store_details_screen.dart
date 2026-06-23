import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_share_targets.dart';
import 'package:dllni_user_app/core/cart/cart_products_count_cubit.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/fetch_restaurant_details_model.dart';
import '../../domain/usecases/fetch_restaurant_details_use_case.dart';
import '../../../rs_favourite/domain/usecases/toggle_restaurant_favourite_use_case.dart';
import '../models/restaurant_preview_data.dart';
import '../models/store_product_item.dart';
import '../widgets/store_details_sub_widgets.dart';
import '../widgets/special_offers_section.dart';
import '../widgets/store_cover_section.dart';
import '../widgets/store_status_section.dart';

class StoreDetailsScreenParams {
  final int restaurantId;
  final RestaurantPreviewData preview;

  const StoreDetailsScreenParams({
    required this.restaurantId,
    required this.preview,
  });
}

@AutoRoutePage(path: "/rs_store")
class RsStoreDetailsScreen extends StatefulWidget {
  const RsStoreDetailsScreen({super.key, required this.params});

  final StoreDetailsScreenParams params;

  @override
  State<RsStoreDetailsScreen> createState() => _RsStoreDetailsScreenState();
}

class _RsStoreDetailsScreenState extends State<RsStoreDetailsScreen> {
  int _selectedFilterIndex = 0;
  late final Future<FetchRestaurantDetailsModel?> _detailsFuture;
  late bool _isFavorited;
  bool _isUpdatingFavourite = false;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.params.preview.isFavorited ?? false;
    _detailsFuture = _loadDetails();
  }

  Future<FetchRestaurantDetailsModel?> _loadDetails() async {
    final useCase = getIt<FetchRestaurantDetailsUseCase>();
    final res = await useCase(
      FetchRestaurantDetailsParams(
        restaurantId: widget.params.restaurantId,
        reviewsPerPage: 10,
      ),
    );
    return res.fold((_) => null, (r) {
      final remoteFavourite = r.restaurant?.isFavorited;
      if (remoteFavourite != null && mounted) {
        setState(() {
          _isFavorited = remoteFavourite;
        });
      }
      return r;
    });
  }

  Future<void> _toggleFavourite() async {
    if (_isUpdatingFavourite) return;
    final restaurantId = widget.params.restaurantId;
    if (restaurantId <= 0) return;

    final next = !_isFavorited;
    setState(() {
      _isFavorited = next;
      _isUpdatingFavourite = true;
    });

    final res = await getIt<ToggleRestaurantFavouriteUseCase>()(
      ToggleRestaurantFavouriteParams(
        restaurantId: restaurantId,
        isFavorited: next,
      ),
    );

    if (!mounted) return;

    res.fold(
      (_) {
        setState(() {
          _isFavorited = !next;
          _isUpdatingFavourite = false;
        });
      },
      (_) {
        setState(() {
          _isUpdatingFavourite = false;
        });
      },
    );
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

  Map<int, int> _countsFromReviews(List<RestaurantDetailsReview> reviews) {
    final counts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final review in reviews) {
      final value = review.rating?.clamp(1, 5) ?? 0;
      counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts;
  }

  Map<int, int> _resolveCounts(
    FetchRestaurantDetailsModel? details,
    List<RestaurantDetailsReview> reviews,
  ) {
    final summaryCounts = details?.ratingSummary?.distribution ?? const {};
    if (summaryCounts.isNotEmpty) {
      return {
        5: summaryCounts[5] ?? 0,
        4: summaryCounts[4] ?? 0,
        3: summaryCounts[3] ?? 0,
        2: summaryCounts[2] ?? 0,
        1: summaryCounts[1] ?? 0,
      };
    }
    return _countsFromReviews(reviews);
  }

  List<StoreProductItem> _buildProducts(FetchRestaurantDetailsModel? details) {
    final resolvedRestaurantName = _pickFirstNotEmpty([
      details?.restaurant?.name,
      widget.params.preview.name,
    ], fallback: 'مطعم');
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
          restaurantName: resolvedRestaurantName,
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
        restaurantName: resolvedRestaurantName,
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
        final ratingCounts = _resolveCounts(details, reviews);
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
                  BlocBuilder<CartProductsCountCubit, int>(
                    bloc: getIt<CartProductsCountCubit>(),
                    builder: (context, cartCount) {
                      return StoreCoverSection(
                        title: restaurantName,
                        subtitle: restaurantDescription,
                        coverImageUrl: coverImage.isEmpty ? null : coverImage,
                        logoImageUrl: coverImage.isEmpty ? null : coverImage,
                        isFavorited: _isFavorited,
                        onFavouriteTap: _toggleFavourite,
                        cartCount: cartCount,
                        onCartTap: () => context.pushRoute('/cart'),
                        onShareTap: () {
                          if (widget.params.restaurantId <= 0) return;
                          unawaited(
                            shareDeepLinkUrl(
                              restaurantUrl(widget.params.restaurantId),
                              context: context,
                            ),
                          );
                        },
                      );
                    },
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
                  StoreRestaurantInfoCard(
                    description: restaurantDescription,
                    address: address,
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
                  StoreProductsPreviewSection(
                    restaurantId: widget.params.restaurantId,
                    restaurantName: restaurantName,
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
                  StoreReviewsPreviewSection(
                    restaurantId: widget.params.restaurantId,
                    reviews: reviews,
                    ratingAverage: ratingAverage,
                    ratingTotal: ratingTotal,
                    ratingCounts: ratingCounts,
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
