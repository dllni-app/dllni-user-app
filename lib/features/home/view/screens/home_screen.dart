import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/home/domain/usecases/fetch_user_offers_use_case.dart';
import 'package:dllni_user_app/features/home/view/manager/bloc/home_bloc.dart';
import 'package:dllni_user_app/features/home/view/widgets/home_app_bar.dart';
import 'package:dllni_user_app/features/sm_main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../generated/assets.dart';
import '../widgets/home_cube.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> titles = ['مطاعم', 'تنظيف', 'تسوق'];
    List<String> screens = ['/rsmain', '/clmain', '/smmain'];

    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(FetchUserOffersEvent(params: FetchUserOffersParams())),
      child: Column(
        children: [
          HomeAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  Row(
                    children: [
                      SizedBox(
                        height: 20,
                        child: VerticalDivider(color: context.primaryContainer, thickness: 4, radius: BorderRadius.circular(9999)),
                      ),
                      SizedBox(width: 8),
                      AppText.titleMedium('الخدمات', fontWeight: FontWeight.bold, color: Color(0xff212C7E)),
                    ],
                  ),
                  SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: titles.length,
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
                        context.pushRoute(screens[index], arguments: index == 2 ? SmMainScreenParams(initialPage: 0, expandSearch: false) : null);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: context.onPrimary,
                              borderRadius: BorderRadius.circular(24),
                              image: DecorationImage(image: AssetImage(Assets.images.test.path), fit: BoxFit.cover),
                            ),
                          ),
                          SizedBox(height: 8),
                          AppText.labelLarge(titles[index % 3], color: Color(0xff6B7280), fontWeight: FontWeight.w500),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Row(
                    children: [
                      SizedBox(
                        height: 20,
                        child: VerticalDivider(color: context.primaryContainer, thickness: 4, radius: BorderRadius.circular(9999)),
                      ),
                      SizedBox(width: 8),
                      AppText.titleMedium('عروض مميزة لك', fontWeight: FontWeight.bold, color: Color(0xff212C7E)),
                    ],
                  ),
                  SizedBox(height: 4),
                  AppText.bodyMedium(
                    'اكتشف أفضل العروض والخدمات المختارة \nخصيصا لك، بتجربة سريعة وسهلة بضغطة واحدة',
                    color: Color(0xff6B7280),
                    textAlign: TextAlign.start,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 16),
                  BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (prev, next) =>
                        prev.userOffersStatus != next.userOffersStatus ||
                        prev.userOffers != next.userOffers ||
                        prev.errorMessage != next.errorMessage,
                    builder: (context, state) {
                      if (state.userOffersStatus == BlocStatus.loading || state.userOffersStatus == BlocStatus.init) {
                        return SizedBox(
                          height: context.width * .45,
                          child: Center(child: CircularProgressIndicator(color: context.primaryContainer)),
                        );
                      }
                      if (state.userOffersStatus == BlocStatus.failed) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: AppText.bodyMedium(state.errorMessage ?? 'تعذر تحميل العروض', color: Color(0xffB91C1C)),
                        );
                      }
                      return HomeCube(offers: state.userOffers?.data ?? []);
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
