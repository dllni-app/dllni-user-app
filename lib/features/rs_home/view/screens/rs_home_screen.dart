import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_restaurant_home_categories_use_case.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_restaurant_home_exclusive_offers_use_case.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_restaurant_home_latest_ordered_products_use_case.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_restaurant_home_nearest_restaurants_use_case.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_restaurant_home_suggested_products_use_case.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_stores_use_case.dart';
import 'package:toastification/toastification.dart';

import '../manager/bloc/rs_home_bloc.dart';
import '../widgets/categories_bar.dart';
import '../widgets/exclusive_offers_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/latest_ordered_products_section.dart';
import '../widgets/near_stores_section.dart';
import '../widgets/suggested_products_section.dart';
import 'rs_home_category_products_screen.dart';

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
    return BlocProvider<RsHomeBloc>(
      lazy: false,
      create: (context) => getIt<RsHomeBloc>()
        ..add(FetchStoresEvent(params: const FetchStoresParams(), isReload: true))
        ..add(FetchRestaurantHomeCategoriesEvent(params: FetchRestaurantHomeCategoriesParams()))
        ..add(FetchRestaurantHomeExclusiveOffersEvent(params: FetchRestaurantHomeExclusiveOffersParams()))
        ..add(FetchRestaurantHomeNearestRestaurantsEvent(params: FetchRestaurantHomeNearestRestaurantsParams()))
        ..add(FetchRestaurantHomeSuggestedProductsEvent(params: FetchRestaurantHomeSuggestedProductsParams()))
        ..add(FetchRestaurantHomeLatestOrderedProductsEvent(params: FetchRestaurantHomeLatestOrderedProductsParams())),
      child: BlocListener<RsHomeBloc, RsHomeState>(
        listenWhen: (previous, current) => previous.restaurantReorderStatus != current.restaurantReorderStatus,
        listener: (context, state) {
          if (state.restaurantReorderStatus == BlocStatus.success) {
            AppToast.showToast(context: context, message: 'تمت إعادة الطلب بنجاح', type: ToastificationType.success);
          } else if (state.restaurantReorderStatus == BlocStatus.failed) {
            AppToast.showToast(context: context, message: state.errorMessage ?? 'تعذر إعادة الطلب', type: ToastificationType.error);
          }
        },
        child: Scaffold(
          body: Column(
            children: [
              HomeAppBar(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<RsHomeBloc, RsHomeState>(
                      builder: (context, state) {
                        if (state.restaurantCategoriesStatus == BlocStatus.loading ||
                            state.restaurantCategoriesStatus == null ||
                            state.restaurantCategoriesStatus == BlocStatus.init) {
                          return const SizedBox(height: 96, child: Center(child: CircularProgressIndicator()));
                        }
                        if (state.restaurantCategoriesStatus == BlocStatus.failed) {
                          return const SizedBox.shrink();
                        }
                        return CategoriesBar(
                          selectedCategory: selectedCategory,
                          categories: state.restaurantCategories?.categories ?? const [],
                          onCategorySelected: (index) {
                            selectedCategory = index;
                            setState(() {});
                            if (index < 0) return;
                            final categories = state.restaurantCategories?.categories ?? const [];
                            if (index >= categories.length) return;
                            context.pushRoute(
                              '/rshomecategoryproducts',
                              arguments: RsHomeCategoryProductsScreenParams(categories: categories, initialCategoryIndex: index),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            ExclusiveOffersSection(),
                            SizedBox(height: 24),
                            SuggestedProductsSection(),
                            SizedBox(height: 24),
                            NearStoresSection(),
                            SizedBox(height: 24),
                            LatestOrderedProductsSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
