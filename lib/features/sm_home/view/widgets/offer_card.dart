import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../data/models/get_featured_offers_model.dart';


class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer});
  final GetFeaturedOffersModelOffersItem offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: Color(0xFFF3F4F6)),
      ),
      child: Stack(
        fit: StackFit.loose,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                AppImage.network(
                  offer.store!.cover.toString(),
                  size: 80,
                  errorWidget: Icon(Icons.error_outline),
                  
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText(
                            offer.name.toString(),
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 20 / 12,
                            ),
                          ),
                          SizedBox(width: 16),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: .1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                            child: AppText(
                              "خصم ${offer.discountPercent != null ? "${offer.discountPercent}%" : "${offer.discountValue}ل.س"}",
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 16 / 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      AppText(
                        offer.description.toString(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          height: 16 / 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Row(
                      //   children: [
                      //     FaIcon(
                      //       FontAwesomeIcons.locationDot,
                      //       size: 10,
                      //       color: Color(0xFF9CA3AF),
                      //     ),
                      //     SizedBox(width: 8),
                      //     AppText(
                      //       "${data.distance.toStringAsFixed(1)} كم",
                      //       style: TextStyle(
                      //         color: Color(0xFF9CA3AF),
                      //         fontSize: 12,
                      //         height: 16 / 12,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(16),
                  topLeft: Radius.circular(24),
                ),
              ),
              child: AppText(
                "لفترة محدودة",
                // offer.type == OfferType.limited
                //     ? "لفترة محدودة"
                //     : offer.type == OfferType.almostFinished
                //     ? "ينتهي قريباً"
                //     : "عرض اليوم",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 15 / 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
