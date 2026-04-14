import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/restaurant_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_details_screen.dart';
import 'package:flutter/material.dart';

import '../../data/models/fetch_restaurant_home_exclusive_offers_model.dart';
import '../screens/rs_home_exclusive_offer_products_screen.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.data});

  final RestaurantHomeExclusiveOfferItem data;

  String get _badgeText {
    final badge = data.offerBadgeText?.trim();
    if (badge != null && badge.isNotEmpty) return badge;
    final value = data.discountValue;
    if (value == null) return '';
    if (data.discountType == 'percentage') {
      return 'خصم ${value.toStringAsFixed(0)}%';
    }
    return 'خصم ${value.toStringAsFixed(2)}';
  }

  String get _description {
    final description = data.offerDescription?.trim();
    if (description != null && description.isNotEmpty) return description;
    final badge = _badgeText;
    if (badge.isNotEmpty) return 'احصل على $badge';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _onTap(context),
      child: Container(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(
          color: context.onPrimary,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          border: Border.all(color: Color(0xFFF3F4F6)),
        ),
        child: Stack(
          fit: StackFit.loose,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: 12,
                end: 12,
                bottom: 12,
                top: 20,
              ),
              child: Row(
                children: [
                  (data.imageUrl != null && data.imageUrl!.trim().isNotEmpty)
                      ? AppImage.network(
                          data.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(10),
                          errorWidget: _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppText(
                                (data.restaurantName ?? '').trim().isEmpty
                                    ? 'مطعم'
                                    : data.restaurantName!,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (_badgeText.isNotEmpty) ...[
                              SizedBox(width: 16),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.primaryContainer.withValues(
                                    alpha: .1,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                                child: AppText(
                                  _badgeText,
                                  style: TextStyle(
                                    color: context.primaryContainer,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    height: 16 / 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 4),
                        if (_description.isNotEmpty)
                          AppText(
                            _description,
                            textAlign: TextAlign.start,
                            scrollText: true,
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              height: 16 / 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Visibility(
                visible: (data.urgencyTag ?? '').trim().isNotEmpty,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.primaryContainer,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(24),
                    ),
                  ),
                  child: AppText(
                    data.urgencyTag ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 15 / 10,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    final restaurant = data.restaurant;
    if (restaurant != null && (restaurant.id ?? 0) > 0) {
      final preview = RestaurantPreviewData.fromHomeExclusiveOfferRestaurant(
        restaurant,
      );
      context.pushRoute(
        '/rs_store',
        arguments: StoreDetailsScreenParams(
          restaurantId: restaurant.id!,
          preview: preview,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RsHomeExclusiveOfferProductsScreen(
          title: _description.isNotEmpty ? _description : 'العرض',
          products: data.products ?? const [],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)),
    );
  }
}
