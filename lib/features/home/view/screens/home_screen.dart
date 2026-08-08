import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/auth/auth_gate.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/home/domain/usecases/fetch_user_offers_use_case.dart';
import 'package:dllni_user_app/features/home/view/manager/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../generated/assets.dart';
import '../../../cl_main/view/screens/cl_main_screen.dart';
import '../../../profile/domain/usecases/fetch_notifications_use_case.dart';
import '../../../profile/view/manager/bloc/profile_bloc.dart';
import '../../../rs_home/view/widgets/home_app_bar.dart';
import '../../../rs_main/view/rs_main_screen.dart';
import '../../../sm_main_page.dart';
import '../widgets/home_cube.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProfileBloc profileBloc;

  List<String> shoppingTitles = ['مطاعم', 'سوبر ماركت'];
  List<String> shoppingScreens = ['/rsmain', '/smmain'];
  List<String> shoppingImages = [
    Assets.images.restaurantServiceIcon.path,
    Assets.images.storeServiceIcon.path,
  ];

  List<String> servicesTitles = ['تنظيف'];
  List<String> servicesScreens = ['/clmain'];
  List<String> servicesImages = [Assets.images.cleaninigServiceIcon.path];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<HomeBloc>();
        bloc.add(
          FetchUserOffersEvent(
            params: FetchUserOffersParams(),
            isReload: true,
          ),
        );
        return bloc;
      },
      child: Column(
        children: [
          HomeAppBar(profileBloc: profileBloc),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32),
                  BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (prev, next) =>
                        prev.userOffersStatus != next.userOffersStatus ||
                        prev.userOffers != next.userOffers ||
                        prev.errorMessage != next.errorMessage,
                    builder: (context, state) {
                      if (state.userOffersStatus == BlocStatus.loading ||
                          state.userOffersStatus == BlocStatus.init) {
                        return SizedBox(
                          height:
                              (context.width * 0.52).clamp(180.0, 230.0) + 56,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: context.primaryContainer,
                            ),
                          ),
                        );
                      }
                      if (state.userOffersStatus == BlocStatus.failed) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: AppText.bodyMedium(
                            state.errorMessage ?? 'تعذر تحميل العروض',
                            color: Color(0xffB91C1C),
                          ),
                        );
                      }
                      return Center(
                        child: HomeCube(offers: state.userOffers.list),
                      );
                    },
                  ),
                  SizedBox(height: 35),
                  Row(
                    children: [
                      SizedBox(
                        height: 20,
                        child: VerticalDivider(
                          color: context.primaryContainer,
                          thickness: 4,
                          radius: BorderRadius.circular(9999),
                        ),
                      ),
                      SizedBox(width: 8),
                      AppText.titleMedium(
                        'الخدمات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff212C7E),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: servicesScreens.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: .8,
                    ),
                    itemBuilder: (context, index) => InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        context.pushRoute(
                          servicesScreens[index],
                          arguments: ClMainScreenParams(profileBloc: profileBloc),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: context.onPrimary,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: EdgeInsetsDirectional.all(15),
                            child: AppImage.asset(
                              servicesImages[index],
                              color: context.primary,
                            ),
                          ),
                          SizedBox(height: 8),
                          AppText.labelLarge(
                            servicesTitles[index],
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        height: 20,
                        child: VerticalDivider(
                          color: context.primaryContainer,
                          thickness: 4,
                          radius: BorderRadius.circular(9999),
                        ),
                      ),
                      SizedBox(width: 8),
                      AppText.titleMedium(
                        'التسوق',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff212C7E),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: shoppingScreens.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: .8,
                    ),
                    itemBuilder: (context, index) => InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        context.pushRoute(
                          shoppingScreens[index],
                          arguments: index == 1
                              ? SmMainScreenParams(
                                  initialPage: 0,
                                  expandSearch: false,
                                )
                              : RsMainScreenParams(profileBloc: profileBloc),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: context.onPrimary,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: EdgeInsetsDirectional.all(15),
                            child: AppImage.asset(
                              shoppingImages[index],
                              color: context.primary,
                            ),
                          ),
                          SizedBox(height: 8),
                          AppText.labelLarge(
                            shoppingTitles[index],
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  initState() {
    profileBloc = getIt<ProfileBloc>();
    if (AuthGate.isAuthenticated) {
      profileBloc.add(
        FetchNotificationsEvent(
          params: FetchNotificationsParams(),
          isReload: true,
        ),
      );
    }

    super.initState();
  }
}
