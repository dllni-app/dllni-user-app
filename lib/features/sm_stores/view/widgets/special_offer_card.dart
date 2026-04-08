import 'dart:ui';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';

enum OfferType { offer, discount, familyOffer }

class SpecialOfferCard extends StatelessWidget {
  const SpecialOfferCard({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.validUntil,
  });

  final OfferType type;
  final String? title;
  final String? subtitle;
  final String? validUntil;

  @override
  Widget build(BuildContext context) {
    final titleText =
        title?.trim().isNotEmpty == true
            ? title!.trim()
            : "كغ رز + كغ برغل + كغ عدس ب 30 ل.س";
    final subtitleText =
        subtitle?.trim().isNotEmpty == true
            ? subtitle!.trim()
            : "4 وجبات برغر + 2 بطاطس كبيرة + 4 مشروبات";
    final untilText =
        validUntil?.trim().isNotEmpty == true
            ? validUntil!.trim()
            : "صالح حتى 31 ديسمبر";

    return Container(
      height: 192,
      width: 280,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: type == OfferType.offer
              ? [Color(0xFFEF4444), Color(0xFFDC2626)]
              : type == OfferType.discount
              ? [Color(0xFF4CAF50), Color(0xFF16A34A)]
              : [Color(0xFFEAB308), Color(0xFFF97316)],
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
                      "عرض",
                      style: TextStyle(
                        color: AppColors.white,
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
          SizedBox(height: 8),
          AppText(
            titleText,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 21 / 16,
            ),
          ),
          SizedBox(height: 6),
          Expanded(
            child: Center(
              child: AppText(
                subtitleText,
                textAlign: TextAlign.start,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xE5FFFFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Color(0x33FFFFFF),
                      child: Text(
                        untilText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          height: 16 / 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // InkWell(
              //   child: Container(
              //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //     decoration: BoxDecoration(
              //       color: AppColors.white,
              //       borderRadius: BorderRadius.all(Radius.circular(8)),
              //     ),
              //     child: Text(
              //       "استخدم الآن",
              //       style: TextStyle(
              //         color: type == OfferType.offer
              //             ? Color(0xFFDC2626)
              //             : type == OfferType.discount
              //             ? Color(0xFF4CAF50)
              //             : Color(0xFFEA580C),
              //         fontSize: 14,
              //         fontWeight: FontWeight.w700,
              //         height: 20 / 14,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
