import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/product_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:dllni_user_app/features/rs_home/view/manager/bloc/rs_home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/rs_app_offer_card.dart';
import '../../../../generated/assets.dart';
import '../../data/models/fetch_restaurant_home_exclusive_offers_model.dart';

class ExclusiveOffersSection extends StatelessWidget {
  const ExclusiveOffersSection({super.key});

  String _badgeText(RestaurantHomeExclusiveOfferItem item) {
    final badge = item.offerBadgeText?.trim();
    if (badge != null && badge.isNotEmpty) return badge;
    final value = item.discountValue;
    if (value == null) return 'عرض خاص';
    if (item.discountType == 'percentage') {
      return 'خصم ${value.toStringAsFixed(0)}%';
    }
    return 'خصم ${value.toStringAsFixed(2)}';
  }

  void _openProduct(
    BuildContext context,
    RestaurantHomeExclusiveOfferItem offer,
    RestaurantHomeExclusiveOfferProduct product,
  ) {
    final id = product.id;
    if (id == null || id <= 0) return;
    context.pushRoute(
      '/rs_product',
      arguments: ProductDetailsScreenParams(
        product: ProductPreviewData.fromExclusiveOfferProduct(
          product,
          fallbackRestaurantName: offer.restaurantName ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              'عروض حصرية بالقرب منك',
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 24 / 16,
              ),
            ),
            const SizedBox(width: 8),
            FaIcon(
              FontAwesomeIcons.fire,
              color: context.primaryContainer,
              size: 14,
            ),
          ],
        ),
        BlocBuilder<RsHomeBloc, RsHomeState>(
          builder: (context, state) {
            if (state.restaurantExclusiveOffersStatus == BlocStatus.loading ||
                state.restaurantExclusiveOffersStatus == BlocStatus.init ||
                state.restaurantExclusiveOffersStatus == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.restaurantExclusiveOffersStatus == BlocStatus.failed) {
              return Center(
                child: AppText.labelLarge(state.errorMessage ?? 'حدث خطأ ما'),
              );
            }

            final offers = state.restaurantExclusiveOffers?.exclusiveOffers ?? const <RestaurantHomeExclusiveOfferItem>[];
            final offeredProducts = <MapEntry<RestaurantHomeExclusiveOfferItem, RestaurantHomeExclusiveOfferProduct>>[];
            for (final offer in offers) {
              for (final product in offer.products ?? const <RestaurantHomeExclusiveOfferProduct>[]) {
                if ((product.id ?? 0) > 0) {
                  offeredProducts.add(MapEntry(offer, product));
                }
              }
            }
            if (offeredProducts.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
                itemBuilder: (context, index) {
                  final offer = offeredProducts[index].key;
                  final product = offeredProducts[index].value;
                  final currentPrice = product.discountedPrice ?? product.price;
                  final originalPrice = product.discountedPrice != null ? product.price : null;
                  final priceText = currentPrice == null
                      ? (offer.restaurantName ?? '')
                      : originalPrice != null && originalPrice > currentPrice
                          ? '${currentPrice.toStringAsFixed(0)} ل.س • بدلاً من ${originalPrice.toStringAsFixed(0)}'
                          : '${currentPrice.toStringAsFixed(0)} ل.س';

                  return RsAppOfferCard(
                    offer: _badgeText(offer),
                    image: product.primaryImage ?? offer.imageUrl ?? '',
                    title: product.name ?? 'منتج ضمن العرض',
                    onTap: () => _openProduct(context, offer, product),
                    subtitle: priceText,
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemCount: offeredProducts.length,
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const _RestaurantHomeEngagementCards(),
      ],
    );
  }
}

class _RestaurantHomeEngagementCards extends StatelessWidget {
  const _RestaurantHomeEngagementCards();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 11,
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => context.pushRoute('/luckyboxsetup'),
                child: Container(
                  height: 153,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xffFF7A00), Color(0xff994900)],
                      end: Alignment.bottomRight,
                      begin: Alignment.topLeft,
                    ),
                  ),
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [AppImage.asset(Assets.images.giftImage.path, height: 88)],
                      ),
                      AppText.bodyLarge('صندوق الحظ', fontWeight: FontWeight.bold, color: context.onPrimary),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => context.pushRoute('/ordervoting'),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xff384EDE), Color(0xff1E2A78)],
                      begin: AlignmentGeometry.topLeft,
                      end: AlignmentGeometry.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [AppImage.asset(Assets.images.threeStarsImage.path, height: 88)],
                      ),
                      AppText.bodyLarge('التصويت', fontWeight: FontWeight.bold, color: context.onPrimary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.pushRoute('/group-order/create'),
          child: Container(
            height: 153,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xff2EC4B6), Color(0xff165E57)],
                begin: AlignmentGeometry.topLeft,
                end: AlignmentGeometry.bottomRight,
              ),
            ),
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [AppImage.asset(Assets.images.socialImage.path, height: 88)],
                ),
                AppText.bodyLarge('التكامل الاجتماعي', fontWeight: FontWeight.bold, color: context.onPrimary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
