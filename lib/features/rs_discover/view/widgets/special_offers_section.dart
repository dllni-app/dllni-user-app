import 'package:flutter/material.dart';

import '../../data/models/fetch_restaurant_details_model.dart';
import '../screens/rs_store_offer_products_screen.dart';
import 'special_offer_card.dart';

class SpecialOffersSection extends StatelessWidget {
  const SpecialOffersSection({
    super.key,
    required this.offers,
    required this.restaurantId,
    required this.restaurantName,
  });

  final List<RestaurantDetailsOffer> offers;
  final int restaurantId;
  final String restaurantName;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'العروض الخاصة',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 28 / 18,
                ),
              ),
              Text(
                ' ${offers.length} عروض ',
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 192,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: offers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final offer = offers[index];
              return SpecialOfferCard(
                offer: offer,
                onTap: offer.id == null
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => RsStoreOfferProductsScreen(
                              params: StoreOfferProductsScreenParams(
                                restaurantId: restaurantId,
                                restaurantName: restaurantName,
                                offer: offer,
                              ),
                            ),
                          ),
                        );
                      },
              );
            },
          ),
        ),
      ],
    );
  }
}
