import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../widgets/categories_bar.dart';
import '../widgets/exclusive_offers_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/near_stores_section.dart';

@AutoRoutePage(path: "/")
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HomeAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoriesBar(),
                  SizedBox(height: 24),
                  ExclusiveOffersSection(),
                  SizedBox(height: 24),
                  NearStoresSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
