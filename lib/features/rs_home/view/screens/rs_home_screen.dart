import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../widgets/categories_bar.dart';
import '../widgets/exclusive_offers_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/near_stores_section.dart';
import '../widgets/store_card.dart';

@AutoRoutePage(path: "/home")
class RsHomeScreen extends StatefulWidget {
  const RsHomeScreen({super.key});

  @override
  State<RsHomeScreen> createState() => _RsHomeScreenState();
}

class _RsHomeScreenState extends State<RsHomeScreen> {
  int selectedCategory = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HomeAppBar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoriesBar(
                  selectedCategory: selectedCategory,
                  onCategorySelected: (index) {
                    selectedCategory = index;
                    setState(() {});
                  },
                ),
                SizedBox(height: 8),
                if (selectedCategory == -1)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          ExclusiveOffersSection(),
                          SizedBox(height: 24),
                          NearStoresSection(),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                "متاجر توفر من الصنف الذي تريده",
                                style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 24 / 16,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  selectedCategory = -1;
                                  setState(() {});
                                },
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                                child: AppText(
                                  " إعادة ضبط ",
                                  style: TextStyle(
                                    color: Color(0xFF615C5C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    height: 24 / 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.all(16),
                            itemBuilder: (_, index) =>
                                StoreCard(store: stores[index]),
                            separatorBuilder: (_, _) => SizedBox(height: 16),
                            itemCount: stores.length,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
