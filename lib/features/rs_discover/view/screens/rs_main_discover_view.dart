import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/search_with_type_dropdown.dart';
import '../../../rs_home/data/models/fetch_restaurant_home_nearest_restaurants_model.dart';
import '../../../rs_home/view/widgets/store_card.dart';
import '../../data/models/fetch_discover_restaurants_model.dart';
import '../manager/bloc/rs_discover_bloc.dart';
import '../widgets/discover_tab_bar.dart';

class RsMainDiscoverView extends StatelessWidget {
  const RsMainDiscoverView({
    super.key,
    required this.onTypeSelected,
    this.expandSearch = false,
  });

  final void Function(SearchType type) onTypeSelected;
  final bool expandSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: context.width,
          padding: EdgeInsets.fromLTRB(
            16,
            16 + MediaQuery.paddingOf(context).top,
            16,
            20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                color: Color(0x0D000000),
              ),
            ],
            border: Border(
              bottom: BorderSide(color: context.primary, width: 2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'تصفح',
                style: TextStyle(
                  color: context.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 32 / 24,
                ),
              ),
              const SizedBox(height: 16),
              SearchWithTypeDropdown(
                isExpanded: expandSearch,
                collapsedHintText: 'ابحث عن مطعم أو وجبة معينة...',
                expandedHintText: 'حدد ما تود البحث عنه',
                productLabel: 'عن وجبة',
                storeLabel: 'عن مطعم',
                smartSearchLabel: 'بحث ذكي',
                productIcon: FontAwesomeIcons.bowlFood,
                storeIcon: FontAwesomeIcons.store,
                onTypeSelected: onTypeSelected,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<RsDiscoverBloc, RsDiscoverState>(
          buildWhen: (previous, current) =>
              previous.selectedTabIndex != current.selectedTabIndex,
          builder: (context, state) {
            return DiscoverTabBar(
              selectedIndex: state.selectedTabIndex,
              items: [
                DiscoverTabBarItem(title: 'الكل'),
                DiscoverTabBarItem(
                  title: 'الأقرب',
                  icon: const FaIcon(
                    FontAwesomeIcons.locationDot,
                    size: 14,
                  ),
                ),
                DiscoverTabBarItem(
                  title: 'الأعلى تقييماً',
                  icon: const FaIcon(FontAwesomeIcons.star, size: 14),
                ),
                DiscoverTabBarItem(
                  title: 'الأسرع توصيلاً',
                  icon: const FaIcon(FontAwesomeIcons.bolt, size: 14),
                ),
                DiscoverTabBarItem(
                  title: 'يوجد عروض',
                  icon: const FaIcon(FontAwesomeIcons.tag, size: 14),
                ),
                DiscoverTabBarItem(
                  title: 'مفتوح الآن',
                  icon: const FaIcon(FontAwesomeIcons.clock, size: 14),
                ),
              ],
              onChanged: (index) {
                context.read<RsDiscoverBloc>().add(
                  DiscoverTabChangedEvent(index),
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BlocBuilder<RsDiscoverBloc, RsDiscoverState>(
            buildWhen: (previous, current) =>
                previous.restaurants != current.restaurants,
            builder: (context, state) {
              final restaurants = state.restaurants;
              return restaurants.builder(
                loadingWidget: const Center(
                  child: CircularProgressIndicator(),
                ),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (restaurants.errorMessage.isNotEmpty)
                          AppText(
                            restaurants.errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                          ),
                        if (restaurants.errorMessage.isNotEmpty)
                          const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.read<RsDiscoverBloc>().add(
                            FetchDiscoverRestaurantsEvent(isReload: true),
                          ),
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
                    await bloc.stream.firstWhere(
                      (state) =>
                          state.restaurants.status != BlocStatus.loading,
                    );
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: restaurants.listLength(1),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                            context.read<RsDiscoverBloc>().add(
                              FetchDiscoverRestaurantsEvent(loadMore: true),
                            );
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

RestaurantHomeNearestRestaurantItem _mapDiscoverRestaurantToHomeCard(
  FetchDiscoverRestaurantsModelDataItem item,
) {
  final cuisineNames = item.cuisineTypes
      ?.map((cuisine) => (cuisine.name ?? '').trim())
      .where((name) => name.isNotEmpty)
      .toList();
  final estimatedMax =
      item.estimatedPreparationTimeMax ?? item.estimatedPreparationTime;
  final estimatedMin = item.estimatedPreparationTimeMin ?? estimatedMax;

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
