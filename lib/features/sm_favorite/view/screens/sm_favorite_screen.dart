import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_favorite_supermarket_products_use_case.dart';
import '../../domain/usecases/get_favorite_supermarket_stores_use_case.dart';
import '../manager/bloc/sm_favorite_bloc.dart';
import '../../../sm_orders/view/widgets/orders_simple_app_bar.dart';
import 'sm_favorit_store_tab.dart';
import 'sm_favorite_products_tab.dart';

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
    return BlocProvider(
      create: (context) => getIt<SmFavoriteBloc>()
        ..add(
          FetchFavoriteSupermarketProductsEvent(
            isReload: true,
            params: GetFavoriteSupermarketProductsParams(page: 1),
          ),
        )
        ..add(
          FetchFavoriteSupermarketStoresEvent(
            isReload: true,
            params: GetFavoriteSupermarketStoresParams(page: 1),
          ),
        ),
      child: Scaffold(
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
                children: [SmFavoriteProductsTab(), SmFavoriteStoreTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
