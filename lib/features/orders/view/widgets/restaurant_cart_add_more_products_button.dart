import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../rs_discover/view/models/restaurant_preview_data.dart';
import '../../../rs_discover/view/screens/rs_store_details_screen.dart';
import '../../../sm_main_page.dart';
import '../../data/models/orders_api_models.dart';

class RestaurantCartAddMoreProductsButton extends StatelessWidget {
  const RestaurantCartAddMoreProductsButton({
    super.key,
    this.isRestaurant = true,
    this.merchant,
  });

  final bool isRestaurant;
  final OrderMerchantModel? merchant;

  void _openRestaurant(BuildContext context) {
    final restaurantId = merchant?.id;
    if (restaurantId == null || restaurantId <= 0) {
      context.pushRoute('/rsmain');
      return;
    }

    context.pushRoute(
      '/rs_store',
      arguments: StoreDetailsScreenParams(
        restaurantId: restaurantId,
        preview: RestaurantPreviewData(
          restaurantId: restaurantId,
          name: merchant?.name ?? 'المطعم',
          description: merchant?.locationDetails ?? merchant?.address ?? '',
          address: merchant?.address,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => isRestaurant
          ? _openRestaurant(context)
          : context.pushRoute(
              '/smmain',
              arguments: SmMainScreenParams(
                initialPage: 0,
                expandSearch: false,
              ),
            ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffD1D5DB), width: 1.3),
        ),
        child: Center(
          child: AppText.labelLarge(
            'إضافة منتجات أخرى',
            color: const Color(0xff4B5563),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
