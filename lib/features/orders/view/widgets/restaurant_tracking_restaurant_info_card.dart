import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'restaurant_order_circle_icon_button.dart';
import 'restaurant_order_tracking_colors.dart';

class RestaurantTrackingRestaurantInfoCard extends StatelessWidget {
  const RestaurantTrackingRestaurantInfoCard({
    super.key,
    required this.name,
    required this.onCall,
    this.imageUrl,
  });

  final String name;
  final VoidCallback onCall;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final image = imageUrl;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: image != null && image.isNotEmpty
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => ColoredBox(
                        color: const Color(0xffE5E7EB),
                        child: Icon(Icons.storefront, color: RestaurantOrderTrackingColors.primary.withAlpha(160), size: 32),
                      ),
                    )
                  : ColoredBox(
                      color: const Color(0xffE5E7EB),
                      child: Icon(Icons.storefront, color: RestaurantOrderTrackingColors.primary.withAlpha(160), size: 32),
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodyMedium(name, color: RestaurantOrderTrackingColors.primary, fontWeight: FontWeight.bold),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xffFBBF24), size: 20),
                      AppText.labelLarge(' 4.8  ·  ', color: RestaurantOrderTrackingColors.grey),
                      AppText.labelLarge('وجبات سريعة', color: RestaurantOrderTrackingColors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),
          RestaurantOrderCircleIconButton(
            background: const Color(0xffF3F4F6),
            iconColor: RestaurantOrderTrackingColors.primary,
            icon: Icons.phone,
            onTap: onCall,
          ),
        ],
      ),
    );
  }
}
