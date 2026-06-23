import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/app_app_bars.dart';
import '../../../../core/widgets/rs_app_product_card.dart';
import '../../../rs_home/data/models/fetch_restaurant_home_nearest_restaurants_model.dart';
import '../../../rs_home/view/widgets/store_card.dart';
import '../../data/models/fetch_discover_restaurants_model.dart';
import '../../data/models/fetch_restaurant_products_search_model.dart';
import '../manager/bloc/rs_discover_bloc.dart';
import '../models/product_preview_data.dart';
import '../widgets/discover_tab_bar.dart';
import '../models/store_product_item.dart';
import 'rs_product_details_screen.dart';

@AutoRoutePage(path: "/rs_discover")
class RsDiscoverScreen extends StatelessWidget {
  const RsDiscoverScreen({super.key, this.selectedView = 0});

  final int selectedView;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RsDiscoverBloc>()..add(FetchDiscoverRestaurantsEvent(isReload: true)),
      child: Scaffold(backgroundColor: const Color(0xFFEFEFEF), body: const _SearchView()),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final state = context.read<RsDiscoverBloc>().state;
    _searchController = TextEditingController(
      text: state.activeSearchMode == RsDiscoverSearchMode.restaurant ? state.searchQuery : state.productSearchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<RsDiscoverBloc, RsDiscoverState>(
          buildWhen: (p, c) => p.activeSearchMode != c.activeSearchMode,
          builder: (context, state) {
            final smart = state.activeSearchMode == RsDiscoverSearchMode.smart;
            return RsAppSimpleAppBarWithSearch(
              title: "اكتشف",
              searchHintText: "حدد ما تود البحث عنه",
              searchController: _searchController,
              searchReadOnly: smart,
            );
          },
        ),
        BlocBuilder<RsDiscoverBloc, RsDiscoverState>(
          buildWhen: (p, c) =>
              p.activeSearchMode != c.activeSearchMode || p.selectedTabIndex != c.selectedTabIndex,
          builder: (context, state) {
            if (state.activeSearchMode != RsDiscoverSearchMode.restaurant) {
              return const SizedBox(height: 16);
            }
            return DiscoverTabBar(
              selectedIndex: state.selectedTabIndex,
              items: [
                DiscoverTabBarItem(title: 'الكل'),
                DiscoverTabBarItem(
                  title: 'الأقرب',
                  icon: FaIcon(FontAwesomeIcons.locationDot, size: 14),
                ),
                DiscoverTabBarItem(
                  title: 'الأعلى تقييماً',
                  icon: FaIcon(FontAwesomeIcons.star, size: 14),
                ),
                DiscoverTabBarItem(
                  title: 'الأسرع توصيلاً',
                  icon: FaIcon(FontAwesomeIcons.bolt, size: 14),
                ),
                DiscoverTabBarItem(
                  title: 'يوجد عروض',
                  icon: FaIcon(FontAwesomeIcons.tag, size: 14),
                ),
                DiscoverTabBarItem(
                  title: 'مفتوح الآن',
                  icon: FaIcon(FontAwesomeIcons.clock, size: 14),
                ),
              ],
              onChanged: (index) {
                context.read<RsDiscoverBloc>().add(DiscoverTabChangedEvent(index));
              },
            );
          },
        ),
        Expanded(
          child: BlocBuilder<RsDiscoverBloc, RsDiscoverState>(
            buildWhen: (p, c) => p.activeSearchMode != c.activeSearchMode || p.restaurants != c.restaurants || p.products != c.products,
            builder: (context, state) {
              if (state.activeSearchMode == RsDiscoverSearchMode.restaurant) {
                return _buildRestaurantResults(state);
              }
              return _buildMealResults(state);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantResults(RsDiscoverState state) {
    final p = state.restaurants;
    return p.builder(
      loadingWidget: const Center(child: CircularProgressIndicator()),
      emptyWidget: Center(
        child: AppText('لا توجد مطاعم', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
      ),
      failedWidget: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (p.errorMessage.isNotEmpty)
                AppText(
                  p.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
              if (p.errorMessage.isNotEmpty) const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.read<RsDiscoverBloc>().add(FetchDiscoverRestaurantsEvent(isReload: true)),
                child: AppText('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
      successWidget: () => RefreshIndicator(
        onRefresh: () async {
          final bloc = context.read<RsDiscoverBloc>();
          bloc.add(FetchDiscoverRestaurantsEvent(isReload: true));
          await bloc.stream.firstWhere((s) => s.restaurants.status != BlocStatus.loading);
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: p.listLength(1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (_, index) {
            if (index >= p.list.length) {
              if (index == p.list.length && !p.isEndPage && p.status != BlocStatus.loading) {
                context.read<RsDiscoverBloc>().add(FetchDiscoverRestaurantsEvent(loadMore: true));
              }
              return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
            }
            return StoreCard(expandToFit: true, store: _mapDiscoverRestaurantToHomeCard(p.list[index]));
          },
        ),
      ),
    );
  }

  Widget _buildMealResults(RsDiscoverState state) {
    final p = state.products;
    return p.builder(
      loadingWidget: const Center(child: CircularProgressIndicator()),
      emptyWidget: Center(
        child: AppText('لا توجد وجبات', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
      ),
      failedWidget: Center(
        child: TextButton(
          onPressed: () => context.read<RsDiscoverBloc>().add(FetchDiscoverProductsEvent(isReload: true)),
          child: AppText('إعادة المحاولة'),
        ),
      ),
      successWidget: () => RefreshIndicator(
        onRefresh: () async {
          final bloc = context.read<RsDiscoverBloc>();
          bloc.add(FetchDiscoverProductsEvent(isReload: true));
          await bloc.stream.firstWhere((s) => s.products.status != BlocStatus.loading);
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: p.listLength(1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (_, index) {
            if (index >= p.list.length) {
              if (index == p.list.length && !p.isEndPage && p.status != BlocStatus.loading) {
                context.read<RsDiscoverBloc>().add(FetchDiscoverProductsEvent(loadMore: true));
              }
              return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
            }
            return _MealSearchCard(product: p.list[index]);
          },
        ),
      ),
    );
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
      productId: mapped.id!,
      image: (mapped.imageUrl ?? '').trim(),
      title: mapped.name,
      restaurant: (mapped.restaurantName ?? '').trim().isEmpty ? 'مطعم' : mapped.restaurantName!.trim(),
      price: mapped.priceText,
      offer: FetchRestaurantProductsSearchModelActiveOffer(
        badgeText: mapped.offerBadgeText,
        discountType: mapped.offerDiscountType,
        discountValue: mapped.offerDiscountValue,
        title: mapped.offerUrgencyTag,
      ),
      onTap: () {
        if (productId <= 0) return;
        context.pushRoute(
          '/rs_product',
          arguments: ProductDetailsScreenParams(product: ProductPreviewData.fromStoreProduct(mapped, fallbackRestaurantName: mapped.restaurantName)),
        );
      },
    );
  }
}

class SearchesGroup extends StatelessWidget {
  const SearchesGroup({super.key, required this.searches, required this.title, this.onDeleteAllTap, required this.onSearchTap});

  final List<String> searches;
  final String title;
  final void Function(String search) onSearchTap;
  final void Function()? onDeleteAllTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                title,
                style: TextStyle(color: Colors.black, fontSize: 14, height: 16 / 14),
              ),
              if (onDeleteAllTap != null)
                InkWell(
                  onTap: onDeleteAllTap,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: AppText(
                    " مسح الكل ",
                    style: TextStyle(color: context.primaryContainer, fontSize: 10, fontWeight: FontWeight.w300, height: 19 / 10),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: searches
                .map<_SearchChip>(
                  (search) => _SearchChip(
                    label: search,
                    onTap: () {
                      onSearchTap(search);
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  const _SearchChip({this.onTap, required this.label});

  final void Function()? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(22)),
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 4, 8, 5),
        decoration: BoxDecoration(color: Color(0xFFDADCEA), borderRadius: BorderRadius.all(Radius.circular(22))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.magnifyingGlass, size: 12, color: context.primary),
            SizedBox(width: 4),
            AppText(
              label,
              style: TextStyle(color: context.primary, fontSize: 10, fontWeight: FontWeight.w300, height: 19 / 10),
            ),
          ],
        ),
      ),
    );
  }
}

StoreProductItem _toStoreProductItem(FetchRestaurantProductsSearchModelDataItem product) {
  final activeOffer = (product.activeOffers ?? []).isNotEmpty ? product.activeOffers!.first : null;
  final currency = 'ل.س';

  String? formatPrice(num? value) {
    if (value == null) return null;
    final normalized = value % 1 == 0 ? value.toInt().toString() : value.toString();
    return '$normalized $currency'.trim();
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
    currency: currency.isEmpty ? null : currency,
    imageUrl: product.primaryImageUrl,
    restaurantName: product.restaurant?.name,
    offer: activeOffer?.title,
    offerName: activeOffer?.title,
    offerBadgeText: activeOffer?.title,
    offerDiscountType: activeOffer?.discountType,
    offerDiscountValue: activeOffer?.discountValue,
    isFavorited: product.isFavorite ?? false,
  );
}

RestaurantHomeNearestRestaurantItem _mapDiscoverRestaurantToHomeCard(FetchDiscoverRestaurantsModelDataItem item) {
  final cuisineNames = item.cuisineTypes?.map((c) => (c.name ?? '').trim()).where((name) => name.isNotEmpty).toList();
  final estimatedMax = item.estimatedPreparationTime;
  final int? estimatedMin = estimatedMax == null ? null : (estimatedMax - 10).clamp(1, estimatedMax).toInt();

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
