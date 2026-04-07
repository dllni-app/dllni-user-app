import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/cart/cart_products_count_cubit.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/rs_favourite/data/models/fetch_favourite_products_model.dart';
import 'package:dllni_user_app/features/rs_favourite/domain/usecases/fetch_favourite_products_use_case.dart';
import 'package:dllni_user_app/features/rs_favourite/view/manager/bloc/rs_favourite_bloc.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/store_product_item.dart';
import 'package:dllni_user_app/features/rs_discover/domain/usecases/add_restaurant_cart_item_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import 'favourite_empty_state.dart';
import 'favourite_product_placeholder_card.dart';

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
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, __) => FavouriteProductPlaceholderCard(
              product: StoreProductItem(
                name: '...',
                description: '...',
                priceText: '...',
                category: '...',
              ),
            ),
          );
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
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              itemCount: pagination.list.length + (showFooter ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                if (index >= pagination.list.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }

                final item = _mapFavouriteProductToStoreItem(pagination.list[index]);
                return FavouriteProductPlaceholderCard(
                  product: item,
                  onAddToCart: () => _addToCart(context: context, item: item),
                  onFavouriteChanged: (isFavorited) {
                    if (isFavorited) return;
                    final productId = item.id;
                    if (productId == null || productId <= 0) return;
                    context.read<RsFavouriteBloc>().add(
                      RemoveFavouriteProductEvent(productId: productId),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _addToCart({
    required BuildContext context,
    required StoreProductItem item,
  }) async {
    final productId = item.id;
    if (productId == null || productId <= 0) {
      AppToast.showToast(
        context: context,
        message: 'تعذر تحديد المنتج',
        type: ToastificationType.error,
      );
      return;
    }

    final res = await getIt<AddRestaurantCartItemUseCase>()(
      AddRestaurantCartItemParams(
        productId: productId,
        quantity: 1,
        modifierIds: const [],
        substituteProductId: null,
        specialInstructions: '',
      ),
    );

    if (!context.mounted) return;
    res.fold(
      (failure) => AppToast.showToast(
        context: context,
        message: failure.message,
        type: ToastificationType.error,
      ),
      (result) {
        getIt<CartProductsCountCubit>().refreshAfterAdd();
        AppToast.showToast(
          context: context,
          message: (result.message ?? '').trim().isNotEmpty
              ? result.message!
              : 'تمت إضافة المنتج إلى السلة',
          type: ToastificationType.success,
        );
      },
    );
  }
}

StoreProductItem _mapFavouriteProductToStoreItem(FetchFavouriteProductsModelDataItem item) {
  String _priceText(num? value, String? currency) {
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
    priceText: _priceText(item.displayPrice, item.currency),
    oldPriceText: item.originalPrice != null ? _priceText(item.originalPrice, item.currency) : null,
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
