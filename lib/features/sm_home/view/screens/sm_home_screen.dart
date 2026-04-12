import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/sm_home/domain/usecases/get_featured_offers_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../data/models/get_featured_offers_model.dart';
import '../../domain/usecases/get_nearby_stores_use_case.dart';
import '../manager/bloc/sm_home_bloc.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/near_stores_section.dart';

@AutoRoutePage(path: "/sm_home")
class SmHomeScreen extends StatefulWidget {
  const SmHomeScreen({super.key});

  @override
  State<SmHomeScreen> createState() => _SmHomeScreenState();
}

class _SmHomeScreenState extends State<SmHomeScreen> {
  int selectedCategory = -1;
  late PageController _pageController;
  int lengthOfOffers = 0;
  late Timer timer;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => getIt<SmHomeBloc>()
          ..add(GetFeaturedOffersEvent(params: GetFeaturedOffersParams()))
          ..add(GetNearbyStoresEvent(params: GetNearbyStoresParams())),
        child: Column(
          children: [
            HomeAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LoadingPageView(),
                    BlocBuilder<SmHomeBloc, SmHomeState>(
                      buildWhen: (previous, current) =>
                          previous.featuredOffersStatus !=
                          current.featuredOffersStatus,
                      builder: (context, state) {
                        if (state.featuredOffersStatus == BlocStatus.loading) {
                          return LoadingPageView();
                        } else if (state.featuredOffersStatus ==
                            BlocStatus.failed) {
                          return FailureWidget(
                            message: state.errorMessage.toString(),
                            onRetry: () {
                              context.read<SmHomeBloc>().add(
                                GetFeaturedOffersEvent(
                                  params: GetFeaturedOffersParams(),
                                ),
                              );
                            },
                          );
                        }
                        if (state.featuredOffersStatus == BlocStatus.success) {
                          lengthOfOffers =
                              state.featuredOffers?.offers?.length ?? 0;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 130,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount:
                                      state.featuredOffers?.offers?.length ?? 0,
                                  itemBuilder: (_, index) => OfferCard(
                                    offer: state.featuredOffers!.offers![index],
                                  ),
                                ),
                                // child: PageView(
                                //   controller: _pageController,
                                //   children: List.generate(
                                //     state.featuredOffers?.offers?.length ?? 0,
                                //     (index) => OfferCard(
                                //       offer:
                                //           state.featuredOffers!.offers![index],
                                //     ),
                                //   ),
                                // ),
                              ),
                              SizedBox(height: 8),
                              SizedBox(
                                height: 4,
                                child: Center(
                                  child: SmoothPageIndicator(
                                    controller: _pageController,
                                    count:
                                        state.featuredOffers?.offers?.length ??
                                        0,
                                    effect: ExpandingDotsEffect(
                                      expansionFactor: 1.01,
                                      dotHeight: 4,
                                      dotWidth: 18,
                                      spacing: 4,
                                      dotColor: AppColors.primary.withValues(
                                        alpha: .34,
                                      ),
                                      activeDotColor: AppColors.primary,
                                    ),
                                    onDotClicked: (index) {},
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return SizedBox();
                      },
                    ),
                    SizedBox(height: 24),
                    NearStoresSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer});
  final GetFeaturedOffersModelOffersItem offer;
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
                  offer.name ?? "",
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
                  offer.description ?? "",
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
            child: AppImage.network(
              offer.imageUrl ?? "",
              size: 135,
              errorWidget: CircleAvatar(
                radius: 65,
                backgroundColor: AppColors.white,
                child: Icon(Icons.error_outline, color: Colors.black),
              ),
              loadingBuilder: (_) => CircleAvatar(
                radius: 65,
                backgroundColor: AppColors.white,
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              ),
              borderRadius: BorderRadius.all(Radius.circular(120)),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingPageView extends StatefulWidget {
  const LoadingPageView({super.key});

  @override
  State<LoadingPageView> createState() => _LoadingPageViewState();
}

class _LoadingPageViewState extends State<LoadingPageView> {
  late Timer timer;
  late PageController _pageController;
  @override
  void initState() {
    _pageController = PageController();
    timer = Timer.periodic(const Duration(milliseconds: 3000), (_) {
      if (_pageController.hasClients && (_pageController.page ?? 0) < 1.9) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 3,
            itemBuilder: (_, _) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 130,
                width: context.width,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 4,
          child: Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: 3,
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
        SizedBox(height: 24),
        NearStoresSection(),
      ],
    );
  }
}

// CategoriesBar(
//   selectedCategory: selectedCategory,
//   onCategorySelected: (index) {
//     selectedCategory = index;
//     setState(() {});
//   },
// ),
// SizedBox(height: 8),
// if (selectedCategory == -1)
// else
// SizedBox(height: 16),
// Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 16),
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       AppText(
//         "متاجر توفر من الصنف الذي تريده",
//         style: TextStyle(
//           color: Color(0xFF1A1A1A),
//           fontSize: 16,
//           fontWeight: FontWeight.w700,
//           height: 24 / 16,
//         ),
//       ),
//       InkWell(
//         onTap: () {
//           selectedCategory = -1;
//           setState(() {});
//         },
//         borderRadius: BorderRadius.all(Radius.circular(2)),
//         child: AppText(
//           " إعادة ضبط ",
//           style: TextStyle(
//             color: Color(0xFF615C5C),
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             height: 24 / 12,
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
// SizedBox(height: 8),
// ListView.separated(
//   padding: EdgeInsets.all(16),
//   shrinkWrap: true,
//   itemBuilder: (_, index) => StoreCard(store: stores[index]),
//   separatorBuilder: (_, _) => SizedBox(height: 16),
//   itemCount: stores.length,
// ),
