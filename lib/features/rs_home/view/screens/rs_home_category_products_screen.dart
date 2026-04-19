import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/widgets/app_app_bars.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/product_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/widgets/discover_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/fetch_restaurant_home_categories_model.dart';
import '../../data/models/fetch_restaurant_home_suggested_products_model.dart';
import '../../domain/usecases/fetch_restaurant_home_suggested_products_use_case.dart';
import '../manager/bloc/rs_home_bloc.dart';

class RsHomeCategoryProductsScreenParams {
  final List<RestaurantHomeCategoryItem> categories;
  final int initialCategoryIndex;

  RsHomeCategoryProductsScreenParams({
    required this.categories,
    required this.initialCategoryIndex,
  });
}

@AutoRoutePage()
class RsHomeCategoryProductsScreen extends StatefulWidget {
  const RsHomeCategoryProductsScreen({super.key, required this.params});

  final RsHomeCategoryProductsScreenParams params;

  @override
  State<RsHomeCategoryProductsScreen> createState() =>
      _RsHomeCategoryProductsScreenState();
}

class _RsHomeCategoryProductsScreenState
    extends State<RsHomeCategoryProductsScreen> {
  late final List<String> _tabTitles;
  int _selectedTabIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final tabTitleSet = <String>{
      ...widget.params.categories
          .map((e) => (e.name ?? '').trim())
          .where((e) => e.isNotEmpty),
    };
    _tabTitles = tabTitleSet.toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RsHomeBloc>()
        ..add(
          FetchRestaurantHomeSuggestedProductsEvent(
            params: FetchRestaurantHomeSuggestedProductsParams(),
          ),
        ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Column(
          children: [
            RsAppSimpleAppBarWithSearch(
              title: "التصنيفات",
              onBackTap: () => context.maybePop(),
              searchHintText: "ابحث عن منتج...",
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
            DiscoverTabBar(
              items: _tabTitles
                  .map((title) => DiscoverTabBarItem(title: title))
                  .toList(),
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
                  final products =
                      state.restaurantSuggestedProducts?.suggestedProducts ??
                      const [];
                  if (status == BlocStatus.loading ||
                      status == null ||
                      status == BlocStatus.init) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (status == BlocStatus.failed) {
                    return Center(
                      child: AppText(
                        state.errorMessage ?? 'حدث خطا ما',
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                    );
                  }
                  final selectedCategory = _tabTitles[_selectedTabIndex];
                  final visibleProducts = products.where((item) {
                    final categoryMatches =
                        selectedCategory == 'الكل' ||
                        _matchesCategory(item, selectedCategory);
                    final searchMatches =
                        _searchQuery.isEmpty ||
                        _matchesSearch(item, _searchQuery);
                    return categoryMatches && searchMatches;
                  }).toList();
                  if (visibleProducts.isEmpty) {
                    return Center(
                      child: AppText(
                        'لا توجد منتجات مطابقة',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: visibleProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                    itemBuilder: (_, index) {
                      final product = visibleProducts[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          if ((product.productId ?? 0) <= 0) return;
                          context.pushRoute(
                            '/rs_product',
                            arguments: ProductDetailsScreenParams(
                              product: ProductPreviewData.fromSuggestedItem(
                                product,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFF3F4F6)),
                          ),
                          child: Row(
                            children: [
                              _ImageThumb(url: product.primaryImageUrl),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      product.name ?? '-',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AppText(
                                      _descriptionText(product),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              AppText(
                                _priceText(
                                  product.displayPrice,
                                  product.currency,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF273C8F),
                                ),
                              ),
                            ],
                          ),
                        ),
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

bool _matchesCategory(
  RestaurantHomeSuggestedProductItem item,
  String category,
) {
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
  final candidates = <String>[
    item.name ?? '',
    item.restaurantName ?? '',
    item.location ?? '',
    ...(item.tags ?? const <String>[]),
  ];
  return candidates.any((value) => value.toLowerCase().contains(q));
}

String _descriptionText(RestaurantHomeSuggestedProductItem item) {
  final restaurant = (item.restaurantName ?? '').trim();
  final location = (item.location ?? '').trim();
  if (restaurant.isNotEmpty && location.isNotEmpty) {
    return '$restaurant - $location';
  }
  if (restaurant.isNotEmpty) return restaurant;
  if (location.isNotEmpty) return location;
  return '';
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final imageUrl = (url ?? '').trim();
    if (imageUrl.isEmpty) {
      return _placeholder();
    }
    return AppImage.network(
      imageUrl,
      width: 72,
      height: 72,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(12),
      errorWidget: _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)),
    );
  }
}

String _priceText(num? value, String? currency) {
  if (value == null) return '-';
  final cleaned = value % 1 == 0 ? value.toInt().toString() : value.toString();
  final curr = (currency ?? '').trim();
  return curr.isEmpty ? cleaned : '$cleaned $curr';
}
