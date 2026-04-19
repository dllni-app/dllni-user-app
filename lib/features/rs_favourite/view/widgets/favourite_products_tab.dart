import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/widgets/rs_app_product_card.dart';
import 'package:dllni_user_app/features/rs_favourite/data/models/fetch_favourite_products_model.dart';
import 'package:dllni_user_app/features/rs_favourite/domain/usecases/fetch_favourite_products_use_case.dart';
import 'package:dllni_user_app/features/rs_favourite/view/manager/bloc/rs_favourite_bloc.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/store_product_item.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/product_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../rs_discover/data/models/fetch_restaurant_products_search_model.dart';
import 'favourite_empty_state.dart';

class FavouriteProductsTab extends StatelessWidget {
  const FavouriteProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RsFavouriteBloc, RsFavouriteState>(
      builder: (context, state) {
        final pagination = state.productFavourites;

        if (pagination.isFailed) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText.labelLarge(pagination.errorMessage),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      context.read<RsFavouriteBloc>().add(FetchFavouriteProductsEvent(params: FetchFavouriteProductsParams(page: 1), isReload: true));
                    },
                    child: AppText('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        if (pagination.isLoading && pagination.list.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (pagination.isEmpty) {
          return RefreshIndicator(
            color: context.primary,
            backgroundColor: context.onPrimary,
            onRefresh: () async {
              context.read<RsFavouriteBloc>().add(FetchFavouriteProductsEvent(params: FetchFavouriteProductsParams(page: 1), isReload: true));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                FavouriteEmptyState(title: 'لا توجد وجبات مفضلة حالياً', subtitle: 'أضف الوجبات المفضلة لتظهر هنا.'),
              ],
            ),
          );
        }

        final showFooter = !pagination.isEndPage && pagination.status == BlocStatus.loading && pagination.list.isNotEmpty;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              final metrics = notification.metrics;
              if (metrics.pixels >= metrics.maxScrollExtent - 240) {
                context.read<RsFavouriteBloc>().add(FetchFavouriteProductsEvent(params: FetchFavouriteProductsParams(page: 1), loadMore: true));
              }
            }
            return false;
          },
          child: RefreshIndicator(
            color: context.primary,
            backgroundColor: context.onPrimary,
            onRefresh: () async {
              context.read<RsFavouriteBloc>().add(FetchFavouriteProductsEvent(params: FetchFavouriteProductsParams(page: 1), isReload: true));
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate((_, index) {
                      final item = _mapFavouriteProductToStoreItem(pagination.list[index]);
                      return Stack(
                        children: [
                          RsAppProductCard(
                            productId: item.id!,
                            image: (item.imageUrl ?? '').trim(),
                            title: item.name,
                            restaurant: (item.restaurantName ?? '').trim().isEmpty ? 'مطعم' : item.restaurantName!.trim(),
                            price: item.priceText,
                            offer: FetchRestaurantProductsSearchModelActiveOffer(
                              badgeText: item.offerBadgeText,
                              discountType: item.offerDiscountType,
                              discountValue: item.offerDiscountValue,
                              title: item.offerUrgencyTag,
                            ),
                            onTap: () {
                              final productId = item.id ?? 0;
                              if (productId <= 0) return;
                              context.pushRoute(
                                '/rs_product',
                                arguments: ProductDetailsScreenParams(
                                  product: ProductPreviewData.fromStoreProduct(item, fallbackRestaurantName: item.restaurantName),
                                ),
                              );
                            },
                          ),
                          PositionedDirectional(
                            top: 8,
                            start: 8,
                            child: InkWell(
                              onTap: () {
                                final productId = item.id;
                                if (productId == null || productId <= 0) return;
                                context.read<RsFavouriteBloc>().add(RemoveFavouriteProductEvent(productId: productId));
                              },
                              customBorder: const CircleBorder(),
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: context.onPrimary,
                                child: const FaIcon(FontAwesomeIcons.solidHeart, size: 14, color: Color(0xFFEF4444)),
                              ),
                            ),
                          ),
                        ],
                      );
                    }, childCount: pagination.list.length),
                  ),
                ),
                if (showFooter)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

StoreProductItem _mapFavouriteProductToStoreItem(FetchFavouriteProductsModelDataItem item) {
  String priceText(num? value, String? currency) {
    if (value == null) return '-';
    final clean = value % 1 == 0 ? value.toInt().toString() : value.toString();
    return (currency ?? '').trim().isEmpty ? clean : '$clean ${currency!.trim()}';
  }

  final offer = item.activeOffers.isNotEmpty ? item.activeOffers.first : null;
  final restaurantName = item.restaurant?.name ?? '';
  final categoryName = item.category?.name ?? '';

  return StoreProductItem(
    id: item.id,
    name: item.name ?? 'منتج',
    description: item.description ?? 'بدون وصف',
    priceText: priceText(item.displayPrice, item.currency),
    oldPriceText: item.originalPrice != null ? priceText(item.originalPrice, item.currency) : null,
    displayPriceValue: item.displayPrice,
    oldPriceValue: item.originalPrice,
    currency: item.currency,
    category: categoryName.isNotEmpty ? categoryName : 'الوجبات',
    imageUrl: item.primaryImageUrl,
    restaurantName: restaurantName,
    isFavorited: item.isFavorite ?? true,
    offerName: offer?.name,
    offerBadgeText: offer?.badgeText,
    offerUrgencyTag: offer?.urgencyTag,
    offerDiscountType: offer?.discountType,
    offerDiscountValue: offer?.discountValue,
    isOfferActive: offer?.isActive,
  );
}
