import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/product_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/restaurant_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_details_screen.dart';
import 'package:dllni_user_app/features/rs_home/view/manager/bloc/rs_home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/rs_app_offer_card.dart';
import '../../../../generated/assets.dart';
import '../../data/models/fetch_restaurant_home_exclusive_offers_model.dart';

class ExclusiveOffersSection extends StatelessWidget {
  const ExclusiveOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              "عروض حصرية بالقرب منك",
              style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 16, fontWeight: FontWeight.w700, height: 24 / 16),
            ),
            SizedBox(width: 8),
            FaIcon(FontAwesomeIcons.fire, color: context.primaryContainer, size: 14),
          ],
        ),
        BlocBuilder<RsHomeBloc, RsHomeState>(
          builder: (context, state) {
            if (state.restaurantExclusiveOffersStatus == BlocStatus.loading ||
                state.restaurantExclusiveOffersStatus == BlocStatus.init ||
                state.restaurantExclusiveOffersStatus == null) {
              return Center(child: CircularProgressIndicator());
            } else if (state.restaurantExclusiveOffersStatus == BlocStatus.failed) {
              return Center(child: AppText.labelLarge(state.errorMessage ?? 'حدث خطا ما'));
            } else {
              final list = state.restaurantExclusiveOffers?.exclusiveOffers ?? const [];
              if (list.isEmpty) return const SizedBox.shrink();

              String badgeText(int index) {
                final badge = list[index].offerBadgeText?.trim();
                if (badge != null && badge.isNotEmpty) return badge;
                final value = list[index].discountValue;
                if (value == null) return '';
                if (list[index].discountType == 'percentage') {
                  return 'خصم ${value.toStringAsFixed(0)}%';
                }
                return 'خصم ${value.toStringAsFixed(2)}';
              }

              String offerCardTitle(RestaurantHomeExclusiveOfferItem item) {
                final rn = item.restaurantName?.trim();
                if (rn != null && rn.isNotEmpty) return rn;
                final products = item.products;
                if (products != null) {
                  for (final p in products) {
                    final n = p.name?.trim();
                    if (n != null && n.isNotEmpty) return n;
                  }
                }
                return '';
              }

              String offerCardSubtitle(RestaurantHomeExclusiveOfferItem item) {
                final d = item.offerDescription?.trim();
                if (d != null && d.isNotEmpty) return d;
                return '';
              }

              void onOfferTap(BuildContext context, RestaurantHomeExclusiveOfferItem item) {
                final r = item.restaurant;
                if (r != null && (r.id ?? 0) > 0) {
                  context.pushRoute(
                    '/rs_store',
                    arguments: StoreDetailsScreenParams(
                      restaurantId: r.id!,
                      preview: RestaurantPreviewData.fromHomeExclusiveOfferRestaurant(r),
                    ),
                  );
                  return;
                }
                final products = item.products;
                if (products == null) return;
                for (final p in products) {
                  final id = p.id;
                  if (id != null && id > 0) {
                    context.pushRoute(
                      '/rs_product',
                      arguments: ProductDetailsScreenParams(
                        product: ProductPreviewData.fromExclusiveOfferProduct(
                          p,
                          fallbackRestaurantName: item.restaurantName ?? '',
                        ),
                      ),
                    );
                    return;
                  }
                }
              }

              return SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsetsDirectional.symmetric(vertical: 10),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return RsAppOfferCard(
                      offer: badgeText(index),
                      image: item.imageUrl ?? '',
                      title: offerCardTitle(item),
                      onTap: () => onOfferTap(context, item),
                      subtitle: offerCardSubtitle(item),
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(width: 10),
                  itemCount: list.length,
                ),
              );
            }
          },
        ),
        SizedBox(height: 24),
        _RestaurantHomeEngagementCards(),
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppText(
              'عروض حصرية بالقرب منك',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 24 / 16,
              ),
            ),
            SizedBox(width: 8),
            FaIcon(
              FontAwesomeIcons.solidCircleCheck,
              color: context.primaryContainer,
              size: 14,
            ),
          ],
        ),
        SizedBox(height: 16),
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
                    gradient: LinearGradient(
                      colors: [Color(0xffFF7A00), Color(0xff994900)],
                      end: Alignment.bottomRight,
                      begin: Alignment.topLeft,
                    ),
                  ),
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppImage.asset(Assets.images.giftImage.path, height: 88),
                        ],
                      ),
                      AppText.bodyLarge(
                        'صندوق الحظ',
                        fontWeight: FontWeight.bold,
                        color: context.onPrimary,
                      ),
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
                    gradient: LinearGradient(
                      colors: [Color(0xff384EDE), Color(0xff1E2A78)],
                      begin: AlignmentGeometry.topLeft,
                      end: AlignmentGeometry.bottomRight,
                    ),
                  ),
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppImage.asset(
                            Assets.images.threeStarsImage.path,
                            height: 88,
                          ),
                        ],
                      ),
                      AppText.bodyLarge(
                        'التصويت',
                        fontWeight: FontWeight.bold,
                        color: context.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.pushRoute('/group-order/create'),
          child: Container(
            height: 153,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Color(0xff2EC4B6), Color(0xff165E57)],
                begin: AlignmentGeometry.topLeft,
                end: AlignmentGeometry.bottomRight,
              ),
            ),
            padding: EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppImage.asset(Assets.images.socialImage.path, height: 88),
                  ],
                ),
                AppText.bodyLarge(
                  'التكامل الاجتماعي',
                  fontWeight: FontWeight.bold,
                  color: context.onPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
