import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'store_card.dart';

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
            if (index.isOdd) return SizedBox(height: 16);
            return StoreCard(store: stores[index ~/ 2]);
            // return NearStoreCard(data: stores[index ~/ 2]);
          }),
        ],
      ),
    );
  }
}

final List<StoreData> stores = [
  StoreData(
    image: '',
    name: "سوبر ماركت الأطرش",
    description: "مفرزات • معلبات • منظفات • تسالي",
    rating: 4.5,
    distance: 1.2,
    deliveryPrice: "15 ل.س",
    time: "20-30 دقيقة",
    discount: 20,
    isFavorite: true,
  ),
  StoreData(
    image: '',
    name: "ماركت المدينة",
    description: "خضار • فواكه • مواد غذائية",
    rating: 4.2,
    distance: 0.8,
    deliveryPrice: "10 ل.س",
    time: "15-25 دقيقة",
    discount: 0,
  ),
  StoreData(
    image: '',
    name: "هايبر الشام",
    description: "عروض يومية • أسعار منافسة",
    rating: 4.7,
    distance: 2.3,
    deliveryPrice: "20 ل.س",
    time: "25-35 دقيقة",
    discount: 30,
  ),
  StoreData(
    image: '',
    name: "سوق الخير",
    description: "مواد تنظيف • مستلزمات منزلية",
    rating: 4.0,
    distance: 3.1,
    deliveryPrice: "12 ل.س",
    time: "30-40 دقيقة",
    discount: 10,
  ),
];
