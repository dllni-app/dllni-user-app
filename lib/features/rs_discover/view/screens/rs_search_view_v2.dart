import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/search/popular_searches_model.dart';
import '../../../../core/widgets/rs_app_product_card.dart';
import '../../../../core/widgets/search_field_with_voice.dart';
import '../../../../core/widgets/search_with_type_dropdown.dart';
import '../../../rs_home/data/models/fetch_restaurant_home_nearest_restaurants_model.dart';
import '../../../rs_home/view/widgets/store_card.dart';
import '../../../sm_discover/view/widgets/searches_group.dart';
import '../../data/models/fetch_discover_restaurants_model.dart';
import '../../data/models/fetch_restaurant_products_search_model.dart';
import '../../data/source/rs_discover_remote_data_source.dart';
import '../manager/bloc/rs_discover_bloc.dart';
import '../models/product_preview_data.dart';
import '../models/store_product_item.dart';
import '../widgets/smart_search_sheet.dart';
import 'rs_product_details_screen.dart';

class RsSearchViewV2 extends StatefulWidget {
  const RsSearchViewV2({
    super.key,
    required this.type,
    this.initialSearch,
  });

  final SearchType type;
  final String? initialSearch;

  @override
  State<RsSearchViewV2> createState() => _RsSearchViewV2State();
}

class _RsSearchViewV2State extends State<RsSearchViewV2> {
  static const String _historyKey = 'restaurant_search_history';

  late List<String> searchHistory;
  late TextEditingController searchController;
  late Future<PopularSearchesModel> _popularSearchesFuture;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchHistory =
        SharedPreferencesHelper.sharedPreferences!.getStringList(_historyKey) ??
        <String>[];
    _popularSearchesFuture = getIt<RsDiscoverRemoteDataSource>()
        .fetchPopularSearches();

    final initial = widget.initialSearch?.trim();
    if (initial != null && initial.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _submitSearch(context, initial);
      });
    }
  }

  @override
  void didUpdateWidget(covariant RsSearchViewV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialSearch?.trim();
    final previous = oldWidget.initialSearch?.trim();
    if (next != null && next.isNotEmpty && next != previous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _submitSearch(context, next);
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24 + MediaQuery.paddingOf(context).top),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchFieldWithVoice(
            backgroundColor: const Color(0xFFF9FAFB),
            controller: searchController,
            hintText: widget.type == SearchType.product
                ? 'ابحث عن وجبة...'
                : 'ابحث عن مطعم...',
            onVoiceTap: widget.type == SearchType.store
                ? null
                : () => _openSmartSearch(context),
            onSearch: (search) => _submitSearch(context, search),
          ),
        ),
        if (isSearching)
          Expanded(child: _buildResults(context))
        else
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              child: Column(
                children: [
                  FutureBuilder<PopularSearchesModel>(
                    future: _popularSearchesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      return SearchesGroup(
                        title: 'الأكثر بحثاً من قبل المستخدمين',
                        emptyText: 'لا توجد عمليات بحث شائعة حالياً',
                        searches: snapshot.data?.searches ?? const <String>[],
                        onSearchTap: (search) =>
                            _submitSearch(context, search),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFDBDCDE)),
                  const SizedBox(height: 16),
                  SearchesGroup(
                    title: 'سجل البحث',
                    emptyText: 'لا يوجد سجل للبحث',
                    searches: searchHistory,
                    onSearchTap: (search) => _submitSearch(context, search),
                    onDeleteAllTap: () async {
                      if (searchHistory.isEmpty) return;
                      searchHistory = <String>[];
                      await SharedPreferencesHelper.removeData(key: _historyKey);
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResults(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 20),
          child: AppText(
            'نتائج البحث',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 26 / 14,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: widget.type == SearchType.product
              ? _buildMealResults(context)
              : _buildRestaurantResults(context),
        ),
      ],
    );
  }

  Widget _buildRestaurantResults(BuildContext context) {
    return BlocBuilder<RsDiscoverBloc, RsDiscoverState>(
      buildWhen: (previous, current) =>
          previous.restaurants != current.restaurants,
      builder: (context, state) {
        final restaurants = state.restaurants;
        return restaurants.builder(
          loadingWidget: const Center(child: CircularProgressIndicator()),
          emptyWidget: Center(
            child: AppText(
              'لا توجد مطاعم',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
              ),
            ),
          ),
          failedWidget: Center(
            child: TextButton(
              onPressed: () => _makeSearch(context, searchController.text),
              child: AppText('إعادة المحاولة'),
            ),
          ),
          successWidget: () => GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.listLength(1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (_, index) {
              if (index >= restaurants.list.length) {
                if (index == restaurants.list.length &&
                    !restaurants.isEndPage &&
                    restaurants.status != BlocStatus.loading) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      context.read<RsDiscoverBloc>().add(
                        FetchDiscoverRestaurantsEvent(loadMore: true),
                      );
                    }
                  });
                }
                return const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return StoreCard(
                expandToFit: true,
                store: _mapDiscoverRestaurantToHomeCard(
                  restaurants.list[index],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMealResults(BuildContext context) {
    return BlocBuilder<RsDiscoverBloc, RsDiscoverState>(
      buildWhen: (previous, current) => previous.products != current.products,
      builder: (context, state) {
        final products = state.products;
        return products.builder(
          loadingWidget: const Center(child: CircularProgressIndicator()),
          emptyWidget: Center(
            child: AppText(
              'لا توجد وجبات',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
              ),
            ),
          ),
          failedWidget: Center(
            child: TextButton(
              onPressed: () => _makeSearch(context, searchController.text),
              child: AppText('إعادة المحاولة'),
            ),
          ),
          successWidget: () => GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.listLength(1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (_, index) {
              if (index >= products.list.length) {
                if (index == products.list.length &&
                    !products.isEndPage &&
                    products.status != BlocStatus.loading) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      context.read<RsDiscoverBloc>().add(
                        FetchDiscoverProductsEvent(loadMore: true),
                      );
                    }
                  });
                }
                return const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return _MealSearchCard(product: products.list[index]);
            },
          ),
        );
      },
    );
  }

  Future<void> _openSmartSearch(BuildContext context) async {
    final words = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SmartSearchSheet(isSupermarket: false),
    );
    if (!mounted || words == null || words.isEmpty) return;
    _submitSearch(context, words.join(' , '));
  }

  void _submitSearch(BuildContext context, String rawSearch) {
    final search = rawSearch.trim();
    if (search.isEmpty) return;
    _makeSearch(context, search);
    _rememberSearch(search);
  }

  void _makeSearch(BuildContext context, String rawSearch) {
    final search = rawSearch.trim();
    if (search.isEmpty) {
      isSearching = false;
      searchController.clear();
      setState(() {});
      return;
    }

    isSearching = true;
    searchController.text = search;
    searchController.selection = TextSelection.collapsed(offset: search.length);

    if (widget.type == SearchType.product) {
      context.read<RsDiscoverBloc>().add(
        DiscoverProductSearchQueryChangedEvent(search),
      );
    } else {
      context.read<RsDiscoverBloc>().add(
        DiscoverSearchQueryChangedEvent(search),
      );
    }
    setState(() {});
  }

  void _rememberSearch(String search) {
    searchHistory.removeWhere((word) => word == search);
    searchHistory.insert(0, search);
    if (searchHistory.length > 20) {
      searchHistory = searchHistory.take(20).toList(growable: true);
    }
    SharedPreferencesHelper.sharedPreferences!.setStringList(
      _historyKey,
      searchHistory,
    );
    if (mounted) setState(() {});
  }
}

class _MealSearchCard extends StatelessWidget {
  const _MealSearchCard({required this.product});

  final FetchRestaurantProductsSearchModelDataItem product;

  @override
  Widget build(BuildContext context) {
    final mapped = _toStoreProductItem(product);
    final productId = mapped.id ?? 0;

    return RsAppProductCard(
      productId: productId,
      image: (mapped.imageUrl ?? '').trim(),
      title: mapped.name,
      restaurant: (mapped.restaurantName ?? '').trim().isEmpty
          ? 'مطعم'
          : mapped.restaurantName!.trim(),
      price: mapped.priceText,
      offer: FetchRestaurantProductsSearchModelActiveOffer(
        badgeText: mapped.offerBadgeText,
        discountType: mapped.offerDiscountType,
        discountValue: mapped.offerDiscountValue,
        title: mapped.offerName,
      ),
      cartProductsCount: product.cartProductsCount,
      onTap: () {
        if (productId <= 0) return;
        context.pushRoute(
          '/rs_product',
          arguments: ProductDetailsScreenParams(
            product: ProductPreviewData.fromStoreProduct(
              mapped,
              fallbackRestaurantName: mapped.restaurantName,
            ),
          ),
        );
      },
    );
  }
}

StoreProductItem _toStoreProductItem(
  FetchRestaurantProductsSearchModelDataItem product,
) {
  final activeOffer = (product.activeOffers ?? []).isNotEmpty
      ? product.activeOffers!.first
      : null;
  const currency = 'ل.س';

  String? formatPrice(num? value) {
    if (value == null) return null;
    return '${value.toInt()}  $currency'.trim();
  }

  return StoreProductItem(
    id: product.id,
    name: product.name ?? '-',
    description: product.description ?? product.restaurant?.name ?? '',
    priceText: formatPrice(product.displayPrice) ?? '-',
    oldPriceText: formatPrice(product.originalPrice),
    category: product.category?.name ?? '',
    displayPriceValue: product.displayPrice,
    oldPriceValue: product.originalPrice,
    currency: currency,
    imageUrl: product.primaryImageUrl,
    restaurantName: product.restaurant?.name,
    offer: activeOffer?.offerType,
    offerName: activeOffer?.offerType,
    offerBadgeText: activeOffer?.offerType,
    offerDiscountType: activeOffer?.discountType,
    offerDiscountValue: activeOffer?.discountValue,
    isFavorited: product.isFavorite ?? false,
  );
}

RestaurantHomeNearestRestaurantItem _mapDiscoverRestaurantToHomeCard(
  FetchDiscoverRestaurantsModelDataItem item,
) {
  final cuisineNames = item.cuisineTypes
      ?.map((cuisine) => (cuisine.name ?? '').trim())
      .where((name) => name.isNotEmpty)
      .toList();
  final estimatedMax = item.estimatedPreparationTime;
  final int? estimatedMin = estimatedMax == null
      ? null
      : (estimatedMax - 10).clamp(1, estimatedMax).toInt();

  return RestaurantHomeNearestRestaurantItem(
    id: item.id,
    name: item.name,
    slug: item.slug,
    rating: item.averageRating?.toDouble(),
    primaryImageUrl: item.imageUrl ?? item.primaryImage ?? item.image,
    cuisineNames: cuisineNames,
    cuisineSummary: cuisineNames?.join(' • ') ?? item.description,
    distanceKm: item.distanceKm,
    distanceUnit: 'km',
    estimatedDeliveryMinutesMin: estimatedMin,
    estimatedDeliveryMinutesMax: estimatedMax,
    discountOfferBadge: item.listingOffer?.offerBadgeText,
    popularOrdersCount: item.totalReviews,
    isFavorited: item.isFavorited,
    deliveryFee: item.minimumOrderAmount,
    currency: 'د.أ',
  );
}
