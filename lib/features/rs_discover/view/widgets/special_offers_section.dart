import 'package:flutter/material.dart';

import '../../data/models/fetch_restaurant_details_model.dart';
import 'special_offer_card.dart';

class SpecialOffersSection extends StatelessWidget {
  const SpecialOffersSection({super.key, required this.offers});

  final List<RestaurantDetailsOffer> offers;

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
              Text(
                "العروض الخاصة",
                style: TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 28 / 18,
                ),
              ),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: Text(
                  " ${offers.length} عروض ",
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 20 / 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 192,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: offers.length,
            separatorBuilder: (_, _) => SizedBox(width: 12),
            itemBuilder: (_, index) => SpecialOfferCard(offer: offers[index]),
          ),
        ),
      ],
    );
  }
}
