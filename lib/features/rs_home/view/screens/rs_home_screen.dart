import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/themes/app_colors.dart';
import 'package:dllni_user_app/core/widgets/failure_widget.dart';
import 'package:dllni_user_app/features/rs_home/data/models/fetch_featured_offers_model.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_featured_offers_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_restaurant_home_categories_use_case.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_restaurant_home_exclusive_offers_use_case.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_restaurant_home_latest_ordered_products_use_case.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_restaurant_home_nearest_restaurants_use_case.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_restaurant_home_suggested_products_use_case.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_stores_use_case.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:toastification/toastification.dart';

import '../../../../generated/assets.dart';
import '../../../sm_home/view/screens/sm_home_screen.dart';
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

class RsHomeOfferCard extends StatelessWidget {
  final FetchFeaturedOffersModelOffersItem offer;

  const RsHomeOfferCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: context.width,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(100, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  offer.restaurantName ?? "",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 20 / 16,
                  ),
                ),
                SizedBox(height: 12),
                AppText(
                  offer.offerDescription ?? "",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 24 / 13,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: -36,
            top: 16,
            child: CircleAvatar(
              backgroundColor: AppColors.white,
              radius: 68,
              child: AppImage.network(
                offer.imageUrl ?? "",
                fit: BoxFit.cover,
                size: 136,
                errorWidget: Icon(Icons.error_outline, color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(68)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RsHomeScreenState extends State<RsHomeScreen> {
  int selectedCategory = -1;
  late PageController _pageController;
  late Timer timer;
  int lengthOfOffers = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RsHomeBloc>(
      lazy: false,
      create: (context) => getIt<RsHomeBloc>()
        ..add(FetchStoresEvent(params: const FetchStoresParams(), isReload: true))
        ..add(FetchFeaturedOffersEvent(params: FetchFeaturedOffersParams()))
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
                child: SingleChildScrollView(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      BlocBuilder<RsHomeBloc, RsHomeState>(
                        buildWhen: (previous, current) => previous.featuredOffersStatus != current.featuredOffersStatus,
                        builder: (context, state) {
                          if (state.featuredOffersStatus == BlocStatus.loading) {
                            return LoadingPageView();
                          } else if (state.featuredOffersStatus == BlocStatus.failed) {
                            return FailureWidget(
                              message: state.errorMessage.toString(),
                              onRetry: () {
                                context.read<RsHomeBloc>().add(
                                  FetchFeaturedOffersEvent(params: FetchFeaturedOffersParams()),
                                );
                              },
                            );
                          }

                          if (state.featuredOffersStatus == BlocStatus.success) {
                            lengthOfOffers = state.featuredOffers?.offers?.length ?? 0;
                            return lengthOfOffers > 0
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 130,
                                        child: PageView.builder(
                                          controller: _pageController,
                                          itemCount: state.featuredOffers?.offers?.length ?? 0,
                                          itemBuilder: (_, index) => RsHomeOfferCard(
                                            offer: state.featuredOffers!.offers![index],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      SizedBox(
                                        height: 4,
                                        child: Center(
                                          child: SmoothPageIndicator(
                                            controller: _pageController,
                                            count: state.featuredOffers?.offers?.length ?? 0,
                                            effect: ExpandingDotsEffect(
                                              expansionFactor: 1.01,
                                              dotHeight: 4,
                                              dotWidth: 18,
                                              spacing: 4,
                                              dotColor: AppColors.primary.withValues(alpha: .34),
                                              activeDotColor: AppColors.primary,
                                            ),
                                            onDotClicked: (index) {},
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink();
                          }

                          return SizedBox();
                        },
                      ),
                      SizedBox(height: 16),
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
                      ExclusiveOffersSection(),
                      SizedBox(height: 24),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              AppText(
                                "عروض حصرية بالقرب منك",
                                style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 16, fontWeight: FontWeight.w700, height: 24 / 16),
                              ),
                              SizedBox(width: 8),
                              FaIcon(FontAwesomeIcons.solidCircleCheck, color: context.primaryContainer, size: 14),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            spacing: 11,
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () {
                                    context.pushRoute('/luckyboxsetup');
                                  },
                                  child: Container(
                                    height: 153,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: LinearGradient(
                                        colors: [Color(0xffFF7A00), Color(0xff994900)],
                                        end: Alignment.bottomRight,
                                        begin: Alignment.topLeft,
                                      ),
                                    ),
                                    padding: EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [AppImage.asset(Assets.images.giftImage.path, height: 88)],
                                        ),
                                        AppText.bodyLarge('صندوق الحظ', fontWeight: FontWeight.bold, color: context.onPrimary),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () {
                                    context.pushRoute('/ordervoting');
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: LinearGradient(
                                        colors: [Color(0xff384EDE), Color(0xff1E2A78)],
                                        begin: AlignmentGeometry.topLeft,
                                        end: AlignmentGeometry.bottomRight,
                                      ),
                                    ),
                                    padding: EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [AppImage.asset(Assets.images.threeStarsImage.path, height: 88)],
                                        ),
                                        AppText.bodyLarge('التصويت', fontWeight: FontWeight.bold, color: context.onPrimary),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {

                            },
                            child: Container(
                              height: 153,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  colors: [Color(0xff2EC4B6), Color(0xff165E57)],
                                  begin: AlignmentGeometry.topLeft,
                                  end: AlignmentGeometry.bottomRight,
                                ),
                              ),
                              padding: EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [AppImage.asset(Assets.images.socialImage.path, height: 88)],
                                  ),
                                  AppText.bodyLarge('التكامل الاجتماعي', fontWeight: FontWeight.bold, color: context.onPrimary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
      ),
    );
  }

  @override
  void initState() {
    _pageController = PageController();
    timer = Timer.periodic(const Duration(milliseconds: 3000), (_) {
      if (_pageController.hasClients &&
          (_pageController.page ?? 0).round() < lengthOfOffers - 1) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else if (_pageController.hasClients) {
        _pageController.animateToPage(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    _pageController.dispose();
    super.dispose();
  }
}
