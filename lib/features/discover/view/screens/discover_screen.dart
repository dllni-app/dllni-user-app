import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/utils/app_images.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../widgets/discover_tab_bar.dart';
import '../widgets/store_card.dart';

@AutoRoutePage(path: "/discover")
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppSimpleAppBarWithSearch(
            title: "اكتشف",
            onSearchChanged: (value) {},
            onFilterTap: () {},
          ),
          SizedBox(height: 16),
          DiscoverTabBar(items: discoverTabs, onChanged: (index) {}),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                AppText(
                  "124 متجر متاح",
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 20 / 14,
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        AppText(
                          "ترتيب حسب: الأقرب",
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 20 / 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        FaIcon(
                          FontAwesomeIcons.angleDown,
                          size: 12,
                          color: Color(0xFF4CAF50),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(20),
              itemBuilder: (_, index) => StoreCard(store: stores[index]),
              separatorBuilder: (_, _) => SizedBox(height: 16),
              itemCount: stores.length,
            ),
          ),
        ],
      ),
    );
  }
}

final List<DiscoverTabBarItem> discoverTabs = [
  DiscoverTabBarItem(title: "الكل"),
  DiscoverTabBarItem(
    title: "الأقرب",
    icon: const FaIcon(
      FontAwesomeIcons.locationDot,
      size: 14,
      color: Color(0xFF9CA3AF),
    ),
  ),
  DiscoverTabBarItem(
    title: "الأعلى تقييماً",
    icon: const FaIcon(
      FontAwesomeIcons.solidStar,
      size: 15,
      color: Color(0xFFFACC15),
    ),
  ),
  DiscoverTabBarItem(
    title: "الأسرع توصيلاً",
    icon: const FaIcon(
      FontAwesomeIcons.bolt,
      size: 14,
      color: Color(0xFF4CAF50),
    ),
  ),
  DiscoverTabBarItem(
    title: "يوجد عروض",
    icon: const FaIcon(
      FontAwesomeIcons.tag,
      size: 12,
      color: Color(0xFFEF4444),
    ),
  ),
  DiscoverTabBarItem(
    title: "مفتوح الآن",
    icon: const FaIcon(
      FontAwesomeIcons.solidClock,
      size: 14,
      color: Color(0xFF22C55E), // أزرق
    ),
  ),
];

final List<StoreData> stores = [
  StoreData(
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
  StoreData(
    image: AppImages.store,
    name: "ماركت المدينة",
    description: "خضار • فواكه • مواد غذائية",
    rating: 4.2,
    distance: 0.8,
    deliveryPrice: "10 ل.س",
    time: "15-25 دقيقة",
    discount: 0,
  ),
  StoreData(
    image: AppImages.store,
    name: "هايبر الشام",
    description: "عروض يومية • أسعار منافسة",
    rating: 4.7,
    distance: 2.3,
    deliveryPrice: "20 ل.س",
    time: "25-35 دقيقة",
    discount: 30,
  ),
  StoreData(
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
