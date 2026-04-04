import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/restaurant_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/fetch_restaurant_home_nearest_restaurants_model.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store});

  final RestaurantHomeNearestRestaurantItem store;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final id = store.id;
        if (id == null) return;
        context.pushRoute(
          '/store',
          arguments: StoreDetailsScreenParams(
            restaurantId: id,
            preview: RestaurantPreviewData.fromHomeNearest(store),
          ),
        );
      },
      borderRadius: BorderRadius.all(Radius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          color: context.onPrimaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          border: Border.all(color: Color(0xFFF3F4F6)),
        ),
        height: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child:
                        store.primaryImageUrl == null ||
                            store.primaryImageUrl!.isEmpty
                        ? Container(
                            width: double.infinity,
                            color: const Color(0xFFF5F5F5),
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          )
                        : AppImage.network(
                            store.primaryImageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              width: double.infinity,
                              color: const Color(0xFFF5F5F5),
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: InkWell(
                      onTap: () {

                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: context.onPrimaryContainer,
                        child: FaIcon(
                          FontAwesomeIcons.heart,
                          size: 16,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  if ((store.discountOfferBadge ?? '').isNotEmpty)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.primaryContainer,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.tag,
                              size: 10,
                              color: context.onPrimaryContainer,
                            ),
                            SizedBox(width: 4),
                            AppText(
                              store.discountOfferBadge!,
                              style: TextStyle(
                                color: context.onPrimaryContainer,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 16 / 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Visibility(
                      visible:
                          store.estimatedDeliveryMinutesMin != null ||
                          store.estimatedDeliveryMinutesMax != null,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.onPrimaryContainer,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              _deliveryTimeText(store),
                              style: TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 16 / 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            FaIcon(
                              FontAwesomeIcons.motorcycle,
                              size: 15,
                              color: Color(0xFF6C63FF),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppText(
                          store.name ?? '-',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 24 / 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              (store.rating ?? 0).toStringAsFixed(1),
                              style: TextStyle(
                                color: Color(0xFF15803D),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 16 / 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            FaIcon(
                              FontAwesomeIcons.solidStar,
                              size: 12,
                              color: Color(0xFF22C55E),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  AppText(
                    store.cuisineSummary ?? '-',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                    ),
                  ),
                  SizedBox(height: 25),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (store.distanceKm != null) ...[
                        FaIcon(
                          FontAwesomeIcons.locationArrow,
                          size: 12,
                          color: Color(0xB26C63FF),
                        ),
                        AppText(
                          '${store.distanceKm!.toStringAsFixed(1)} كم',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            height: 16 / 12,
                          ),
                        ),
                      ],
                      if (store.distanceKm != null && store.deliveryFee != null)
                        CircleAvatar(
                          radius: 2,
                          backgroundColor: Color(0xFFD1D5DB),
                        ),
                      if (store.deliveryFee != null)
                        AppText(
                          '${store.deliveryFee} ${store.currency ?? ''}'.trim(),
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            height: 16 / 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _deliveryTimeText(RestaurantHomeNearestRestaurantItem store) {
  final min = store.estimatedDeliveryMinutesMin;
  final max = store.estimatedDeliveryMinutesMax;
  if (min != null && max != null) return '$min-$max دقيقة';
  if (max != null) return '$max دقيقة';
  if (min != null) return '$min دقيقة';
  return '';
}
