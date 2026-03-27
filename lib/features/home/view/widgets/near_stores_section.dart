import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';

class NearStoresSection extends StatelessWidget {
  const NearStoresSection({super.key});

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
              FaIcon(
                FontAwesomeIcons.locationDot,
                color: Color(0xFF6C63FF),
                size: 15,
              ),
              SizedBox(width: 8),
              AppText(
                "متاجر قريبة منك",
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...List.generate(stores.length * 2 - 1, (index) {
            if (index.isOdd) return SizedBox(height: 12);
            return NearStoreCard(store: stores[index ~/ 2]);
            // return NearStoreCard(data: stores[index ~/ 2]);
          }),
        ],
      ),
    );
  }
}

final List<NearStoreData> stores = [
  NearStoreData(
    image: AppImages.store,
    name: "سوبر ماركت الأطرش",
    description: "مفرزات • معلبات • منظفات • تسالي",
    rating: 4.5,
    distance: 1.2,
    deliveryPrice: "15 ل.س",
    time: "20-30 دقيقة",
    discount: 20,
    isFavorite: true,
  ),
  NearStoreData(
    image: AppImages.store,
    name: "ماركت المدينة",
    description: "خضار • فواكه • مواد غذائية",
    rating: 4.2,
    distance: 0.8,
    deliveryPrice: "10 ل.س",
    time: "15-25 دقيقة",
    discount: 0,
  ),
  NearStoreData(
    image: AppImages.store,
    name: "هايبر الشام",
    description: "عروض يومية • أسعار منافسة",
    rating: 4.7,
    distance: 2.3,
    deliveryPrice: "20 ل.س",
    time: "25-35 دقيقة",
    discount: 30,
  ),
  NearStoreData(
    image: AppImages.store,
    name: "سوق الخير",
    description: "مواد تنظيف • مستلزمات منزلية",
    rating: 4.0,
    distance: 3.1,
    deliveryPrice: "12 ل.س",
    time: "30-40 دقيقة",
    discount: 10,
  ),
];

class NearStoreData {
  final String image;
  final String name;
  final String description;
  final double rating;
  final double distance;
  final String deliveryPrice;
  final String time;
  final int discount;
  final bool isFavorite;

  NearStoreData({
    required this.image,
    required this.name,
    required this.description,
    required this.rating,
    required this.distance,
    required this.deliveryPrice,
    required this.time,
    required this.discount,
    this.isFavorite = false,
  });
}

class NearStoreCard extends StatelessWidget {
  const NearStoreCard({super.key, required this.store});
  final NearStoreData store;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: Color(0xFFF3F4F6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            fit: StackFit.loose,
            children: [
              AppImage.asset(
                store.image,
                height: 160,
                width: context.width,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 12,
                left: 12,
                child: InkWell(
                  onTap: () {},
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.white,
                    child: FaIcon(
                      store.isFavorite
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart,
                      size: 16,
                      color: store.isFavorite
                          ? Colors.red
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
              if (store.discount > 0)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.tag,
                          size: 10,
                          color: AppColors.white,
                        ),
                        SizedBox(width: 4),
                        AppText(
                          "خصم ${store.discount}%",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 16 / 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        store.time,
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 16 / 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      FaIcon(
                        FontAwesomeIcons.motorcycle,
                        size: 15,
                        color: Color(0xFF6C63FF),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppText(
                        store.name,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 24 / 16,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            store.rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 16 / 12,
                            ),
                          ),
                          SizedBox(width: 4),
                          FaIcon(
                            FontAwesomeIcons.solidStar,
                            size: 12,
                            color: Color(0xFF22C55E),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                AppText(
                  store.description,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.locationArrow,
                      size: 12,
                      color: Color(0xB26C63FF),
                    ),
                    SizedBox(width: 8),
                    AppText(
                      "${store.distance.toStringAsFixed(1)} كم",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        height: 16 / 12,
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(radius: 2, backgroundColor: Color(0xFFD1D5DB)),
                    SizedBox(width: 8),
                    AppText(
                      "توصيل ${store.deliveryPrice} ل.س",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        height: 16 / 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
