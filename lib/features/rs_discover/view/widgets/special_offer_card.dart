import 'dart:ui';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/fetch_restaurant_details_model.dart';

class SpecialOfferCard extends StatelessWidget {
  const SpecialOfferCard({
    super.key,
    required this.offer,
    this.onTap,
    this.width = 280,
  });

  final RestaurantDetailsOffer offer;
  final VoidCallback? onTap;
  final double width;

  String get _discountLabel {
    final value = offer.discountValue;
    if (value == null) return 'عرض خاص';
    if (offer.discountType == 'percentage') {
      return 'خصم ${value.toStringAsFixed(0)}%';
    }
    return 'خصم ${value.toStringAsFixed(2)} ل.س';
  }

  String get _title => offer.name ?? 'عرض خاص';

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 192,
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
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
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    color: const Color(0x33FFFFFF),
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
              const FaIcon(
                FontAwesomeIcons.tag,
                color: Color(0xCCFFFFFF),
                size: 21,
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
          AppText(
            'احصل على $_discountLabel على المنتجات المؤهلة في هذا المطعم',
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: Color(0xE5FFFFFF),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 20 / 14,
            ),
          ),
          const Spacer(),
          Semantics(
            label: 'حالة العرض: فعال الآن',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'فعال الآن',
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
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Semantics(
      button: true,
      label: 'فتح منتجات العرض $_title',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: content,
        ),
      ),
    );
  }
}
