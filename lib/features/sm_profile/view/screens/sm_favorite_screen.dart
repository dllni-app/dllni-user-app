import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../sm_home/data/models/get_nearby_stores_model.dart';
import '../../../sm_home/view/widgets/store_card.dart';
import '../../../sm_orders/view/widgets/orders_simple_app_bar.dart';

@AutoRoutePage(path: "/sm_favorite")
class SmFavoriteScreen extends StatefulWidget {
  const SmFavoriteScreen({super.key});

  @override
  State<SmFavoriteScreen> createState() => _SmFavoriteScreenState();
}

class _SmFavoriteScreenState extends State<SmFavoriteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SimpleAppBarWithTabBar(
            title: "المفضلة",
            items: ["منتجات", "متاجر"],
            onChanged: (index) {
              _tabController.animateTo(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                4,
                (index) => ListView.separated(
                  padding: EdgeInsets.all(20),
                  itemCount: 5,
                  itemBuilder: (context, index) => StoreCard(
                    store: GetNearbyStoresModelStoresItem(
                      name: "سوبر ماركت الأطرش",
                      categorySummary: "مفرزات • معلبات و تغذية• منظفات • أكلات و تسالي",
                      rating: 4.5,
                      discountOfferBadge: "خصم 20%",
                      isFavorited: true,
                      estimatedDeliveryMinutesMin: 20,
                      estimatedDeliveryMinutesMax: 30,
                      distanceKm: 1.2,
                      distanceUnit: "km",
                      deliveryFee: 15,
                      currency: "SYR"
                    ),
                  ),
                  separatorBuilder: (context, index) => SizedBox(height: 16),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
