import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';
import 'offer_card.dart';

class ExclusiveOffersSection extends StatelessWidget {
  const ExclusiveOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                "عروض حصرية بالقرب منك",
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                ),
              ),
              SizedBox(width: 8),
              FaIcon(FontAwesomeIcons.fire, color: AppColors.accent, size: 14),
            ],
          ),
          SizedBox(height: 16),
          ...List.generate(3 * 2 - 1, (index) {
            if (index.isOdd) return SizedBox(height: 12);
            return OfferCard(data: offers[index ~/ 2]);
          }),
        ],
      ),
    );
  }
}

final List<OfferCardData> offers = [
  OfferCardData(
    imagePath: AppImages.products,
    name: "عرض خاص على المواد الغذائية",
    info: "خصم يصل إلى 30% على مجموعة مختارة من المنتجات",
    distance: 1.2,
    type: OfferType.limited,
  ),
  OfferCardData(
    imagePath: AppImages.products,
    name: "تخفيضات نهاية اليوم",
    info: "استفد من العروض قبل انتهاء الوقت",
    distance: 0.8,
    type: OfferType.almostFinished,
  ),
  OfferCardData(
    imagePath: AppImages.products,
    name: "عرض يومي على الخضار",
    info: "خضار طازجة بأسعار مميزة اليوم فقط",
    distance: 2.5,
    type: OfferType.daily,
  ),
  OfferCardData(
    imagePath: AppImages.products,
    name: "خصومات على المشروبات",
    info: "اشتري 2 واحصل على 1 مجاناً",
    distance: 1.7,
    type: OfferType.limited,
  ),
  OfferCardData(
    imagePath: AppImages.products,
    name: "عرض أوشك على الانتهاء",
    info: "سارع قبل نفاد الكمية",
    distance: 3.0,
    type: OfferType.almostFinished,
  ),
  OfferCardData(
    imagePath: AppImages.products,
    name: "عرض اليوم على الألبان",
    info: "أفضل الأسعار على منتجات الألبان",
    distance: 0.5,
    type: OfferType.daily,
  ),
  OfferCardData(
    imagePath: AppImages.products,
    name: "عروض الوجبات السريعة",
    info: "وجبات شهية بأسعار مخفضة",
    distance: 4.2,
    type: OfferType.limited,
  ),
  OfferCardData(
    imagePath: AppImages.products,
    name: "تخفيضات اللحظة الأخيرة",
    info: "لا تفوت الفرصة قبل انتهاء العرض",
    distance: 2.0,
    type: OfferType.almostFinished,
  ),
];
