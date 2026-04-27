import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/widgets/app_app_bars.dart';
import 'package:flutter/material.dart';

import 'favourite_app_bar.dart';
import 'favourite_products_tab.dart';
import 'favourite_restaurants_tab.dart';

class RsFavouriteView extends StatefulWidget {
  const RsFavouriteView({super.key});

  @override
  State<RsFavouriteView> createState() => _RsFavouriteViewState();
}

class _RsFavouriteViewState extends State<RsFavouriteView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          FavouriteAppBar(),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 24),
            child: Row(
              spacing: 20,
              children: List.generate(
                2,
                (i) => Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _tabController.animateTo(i);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _tabController.index == i ? null : context.onPrimary,
                        gradient: _tabController.index != i
                            ? null
                            : LinearGradient(
                                colors: [context.secondary, context.primary],
                                begin: AlignmentGeometry.topRight,
                                end: AlignmentGeometry.bottomLeft,
                              ),
                        border: Border.all(color: Color(0xffE5E7EB), width: 1),
                      ),
                      padding: EdgeInsetsDirectional.symmetric(vertical: 8),
                      child: AppText.labelLarge(
                        i == 0 ? 'المطاعم' : 'الوجبات',
                        color: _tabController.index != i ? null : context.onPrimary,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: TabBarView(controller: _tabController, children: const [FavouriteRestaurantsTab(), FavouriteProductsTab()]),
          ),
        ],
      ),
    );
  }
}
