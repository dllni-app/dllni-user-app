import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/widgets/app_app_bars.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/product_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/widgets/discover_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/rs_app_product_card.dart';
import '../../../rs_discover/view/manager/bloc/rs_discover_bloc.dart';
import '../../data/models/fetch_restaurant_home_categories_model.dart';
import '../../data/models/fetch_restaurant_home_suggested_products_model.dart';
import '../../domain/usecases/fetch_restaurant_home_suggested_products_use_case.dart';
import '../manager/bloc/rs_home_bloc.dart';

class RsHomeCategoryProductsScreenParams {
  final List<RestaurantHomeCategoryItem> categories;
  final int initialCategoryIndex;

  RsHomeCategoryProductsScreenParams({required this.categories, required this.initialCategoryIndex});
}

@AutoRoutePage()
class RsHomeCategoryProductsScreen extends StatefulWidget {
  const RsHomeCategoryProductsScreen({super.key, required this.params});

  final RsHomeCategoryProductsScreenParams params;

  @override
  State<RsHomeCategoryProductsScreen> createState() => _RsHomeCategoryProductsScreenState();
}

class _RsHomeCategoryProductsScreenState extends State<RsHomeCategoryProductsScreen> {
  late final List<String> _tabTitles;
  int _selectedTabIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final tabTitleSet = <String>{...widget.params.categories.map((e) => (e.name ?? '').trim()).where((e) => e.isNotEmpty)};
    _tabTitles = tabTitleSet.toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<RsHomeBloc>()..add(FetchRestaurantHomeSuggestedProductsEvent(params: FetchRestaurantHomeSuggestedProductsParams())),
        ),
        BlocProvider(create: (context) => getIt<RsDiscoverBloc>()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Column(
          children: [
            RsAppSimpleAppBarWithSearch(
              title: "التصنيفات",
              isCategory: true,
              onBackTap: () => context.maybePop(),
              searchHintText: "ابحث عن منتج...",
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
            DiscoverTabBar(
              items: _tabTitles.map((title) => DiscoverTabBarItem(title: title)).toList(),
              initialIndex: _selectedTabIndex,
              onChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<RsHomeBloc, RsHomeState>(
                builder: (context, state) {
                  final status = state.restaurantSuggestedProductsStatus;
                  final products = state.restaurantSuggestedProducts?.suggestedProducts ?? const [];
                  if (status == BlocStatus.loading || status == null || status == BlocStatus.init) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (status == BlocStatus.failed) {
                    return Center(
                      child: AppText(state.errorMessage ?? 'حدث خطا ما', style: const TextStyle(color: Color(0xFF6B7280))),
                    );
                  }
                  final selectedCategory = _tabTitles[_selectedTabIndex];
                  final visibleProducts = products.where((item) {
                    final categoryMatches = selectedCategory == 'الكل' || _matchesCategory(item, selectedCategory);
                    final searchMatches = _searchQuery.isEmpty || _matchesSearch(item, _searchQuery);
                    return categoryMatches && searchMatches;
                  }).toList();
                  if (visibleProducts.isEmpty) {
                    return Center(
                      child: AppText('لا توجد منتجات مطابقة', style: TextStyle(color: Color(0xFF6B7280))),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: visibleProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: .65,
                    ),
                    itemBuilder: (_, index) {
                      return RsAppProductCard(
                        onTap: visibleProducts[index].productId == null
                            ? () {}
                            : () {
                                context.pushRoute(
                                  '/rs_product',
                                  arguments: ProductDetailsScreenParams(product: ProductPreviewData.fromSuggestedItem(visibleProducts[index])),
                                );
                              },
                        productId: visibleProducts[index].productId ?? 0,
                        title: visibleProducts[index].name ?? '',
                        image: visibleProducts[index].primaryImageUrl ?? '',
                        offer: null,
                        price: '${visibleProducts[index].displayPrice} ${visibleProducts[index].currency}',
                        restaurant: visibleProducts[index].restaurantName ?? 'restaurant',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _matchesCategory(RestaurantHomeSuggestedProductItem item, String category) {
  final normalizedCategory = category.trim().toLowerCase();
  final tags = item.tags ?? const <String>[];
  for (final tag in tags) {
    if (tag.trim().toLowerCase() == normalizedCategory) {
      return true;
    }
  }
  return false;
}

bool _matchesSearch(RestaurantHomeSuggestedProductItem item, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  final candidates = <String>[item.name ?? '', item.restaurantName ?? '', item.location ?? '', ...(item.tags ?? const <String>[])];
  return candidates.any((value) => value.toLowerCase().contains(q));
}
