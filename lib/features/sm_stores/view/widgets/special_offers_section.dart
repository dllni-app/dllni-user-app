import 'package:flutter/material.dart';

import 'special_offer_card.dart';

class SpecialOffersSection extends StatelessWidget {
  const SpecialOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
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
                  " عرض الكل ",
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
            itemCount: 3,
            separatorBuilder: (_, _) => SizedBox(width: 12),
            itemBuilder: (_, index) => SpecialOfferCard(),
          ),
        ),
      ],
    );
  }
}
