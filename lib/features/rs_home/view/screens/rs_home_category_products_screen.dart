import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/extensions/extentions.dart';
import 'package:dllni_user_app/core/widgets/app_app_bars.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/product_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/widgets/discover_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/rs_app_product_card.dart';
import '../../data/models/fetch_restaurant_home_categories_model.dart';
import '../../data/models/fetch_restaurant_home_category_products_model.dart';
import '../../domain/usecases/fetch_restaurant_home_category_products_use_case.dart';
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
  late int _selectedTabIndex;
  late final RsHomeBloc _bloc;
  String _searchQuery = '';
  int _lastRequestedPage = 1;

  List<RestaurantHomeCategoryItem> get _categories => widget.params.categories;

  @override
  void initState() {
    super.initState();
    if (_categories.isEmpty) {
      _selectedTabIndex = 0;
    } else {
      _selectedTabIndex = widget.params.initialCategoryIndex
          .clamp(0, _categories.length - 1)
          .toInt();
    }
    _bloc = getIt<RsHomeBloc>();
    _requestCategory(_bloc);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  int? get _selectedCategoryId {
    if (_categories.isEmpty || _selectedTabIndex >= _categories.length) {
      return null;
    }
    return _categories[_selectedTabIndex].id;
  }

  void _requestCategory(RsHomeBloc bloc, {int page = 1}) {
    final categoryId = _selectedCategoryId;
    if (categoryId == null) return;
    _lastRequestedPage = page;
    bloc.add(
      FetchRestaurantHomeCategoryProductsEvent(
        params: FetchRestaurantHomeCategoryProductsParams(
          categoryId: categoryId,
          page: page,
          perPage: 30,
        ),
      ),
    );
  }

  void _loadMore(
    FetchRestaurantHomeCategoryProductsModel? model,
  ) {
    if (model == null || model.currentPage >= model.lastPage) return;
    final nextPage = model.currentPage + 1;
    if (nextPage <= _lastRequestedPage) return;
    _requestCategory(_bloc, page: nextPage);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Column(
          children: [
            RsAppSimpleAppBarWithSearch(
              title: 'التصنيفات',
              isCategory: true,
              onBackTap: () => context.maybePop(),
              searchHintText: 'ابحث عن منتج...',
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
            if (_categories.isNotEmpty)
              DiscoverTabBar(
                items: _categories
                    .map(
                      (category) => DiscoverTabBarItem(
                        title: (category.name ?? '').trim().isEmpty
                            ? 'تصنيف'
                            : category.name!.trim(),
                      ),
                    )
                    .toList(),
                initialIndex: _selectedTabIndex,
                onChanged: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                    _lastRequestedPage = 1;
                  });
                  _requestCategory(_bloc);
                },
              ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<RsHomeBloc, RsHomeState>(
                builder: (context, state) {
                  final status = state.restaurantCategoryProductsStatus;
                  final model = state.restaurantCategoryProducts;
                  final products = model?.products ??
                      const <RestaurantHomeCategoryProductsItem>[];

                  if (_categories.isEmpty) {
                    return const Center(child: Text('لا توجد تصنيفات متاحة'));
                  }
                  if ((status == BlocStatus.loading ||
                          status == null ||
                          status == BlocStatus.init) &&
                      products.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (status == BlocStatus.failed && products.isEmpty) {
                    return Center(
                      child: TextButton(
                        onPressed: () =>
                            _requestCategory(_bloc),
                        child: Text(state.errorMessage ?? 'إعادة المحاولة'),
                      ),
                    );
                  }

                  final visibleProducts = products.where((item) {
                    if (_searchQuery.isEmpty) return true;
                    final values = <String>[
                      item.name ?? '',
                      item.restaurantName ?? '',
                      item.description ?? '',
                    ];
                    return values.any(
                      (value) => value.toLowerCase().contains(_searchQuery),
                    );
                  }).toList();

                  if (visibleProducts.isEmpty) {
                    return const Center(child: Text('لا توجد منتجات مطابقة'));
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.extentAfter < 300) {
                        _loadMore(model);
                      }
                      return false;
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: visibleProducts.length +
                          ((model?.currentPage ?? 1) < (model?.lastPage ?? 1)
                              ? 1
                              : 0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: .65,
                      ),
                      itemBuilder: (_, index) {
                        if (index >= visibleProducts.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final item = visibleProducts[index];
                        return RsAppProductCard(
                          onTap: (item.productId ?? 0) <= 0
                              ? () {}
                              : () {
                                  context.pushRoute(
                                    '/rs_product',
                                    arguments: ProductDetailsScreenParams(
                                      product: ProductPreviewData
                                          .fromCategoryProductItem(item),
                                    ),
                                  );
                                },
                          productId: item.productId ?? 0,
                          title: item.name ?? '',
                          image: item.primaryImageUrl ?? '',
                          offer: null,
                          price: (item.displayPrice ?? 0).formatMoney(),
                          restaurant: item.restaurantName ?? 'المطعم',
                        );
                      },
                    ),
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
