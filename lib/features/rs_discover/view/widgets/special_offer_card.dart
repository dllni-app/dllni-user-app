import 'dart:ui';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/fetch_restaurant_details_model.dart';

class SpecialOfferCard extends StatelessWidget {
  const SpecialOfferCard({super.key, required this.offer});

  final RestaurantDetailsOffer offer;

  String get _discountLabel {
    final value = offer.discountValue;
    if (value == null) return 'عرض خاص';
    if (offer.discountType == 'percentage') {
      return 'خصم ${value.toStringAsFixed(0)}%';
    }
    return 'خصم ${value.toStringAsFixed(2)} د.أ';
  }

  String get _title => offer.name ?? 'عرض خاص';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192,
      width: 280,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    color: Color(0x33FFFFFF),
                    child: Text(
                      _discountLabel,
                      style: TextStyle(
                        color: context.onPrimaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 16 / 12,
                      ),
                    ),
                  ),
                ),
              ),
              FaIcon(FontAwesomeIcons.tag, color: Color(0xCCFFFFFF), size: 21),
            ],
          ),
          SizedBox(height: 12),
          AppText(
            _title,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: context.onPrimaryContainer,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 28 / 18,
            ),
          ),
          SizedBox(height: 8),
          AppText(
            'احصل على $_discountLabel على الطلبات المؤهلة في هذا المتجر',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Color(0xE5FFFFFF),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 20 / 14,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.onPrimaryContainer,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Text(
                    "استخدم الآن",
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 20 / 14,
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Color(0x33FFFFFF),
                    child: Text(
                      "عرض فعال الآن",
                      style: TextStyle(
                        color: context.onPrimaryContainer,
                        fontSize: 12,
                        height: 16 / 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
