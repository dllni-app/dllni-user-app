import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import 'special_offer_card.dart';

class SpecialOffersSection extends StatelessWidget {
  const SpecialOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  child: Text(
                    "الحسومات والعروض  الخاصة بهذا المتجر",
                    style: TextStyle(
                      color: const Color(0xFF111827),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 28 / 15,
                    ),
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
              itemBuilder: (_, index) => SpecialOfferCard(
                type: index == 0
                    ? OfferType.offer
                    : index == 1
                    ? OfferType.discount
                    : OfferType.familyOffer,
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
