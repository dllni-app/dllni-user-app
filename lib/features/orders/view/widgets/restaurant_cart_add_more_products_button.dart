import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../profile/view/manager/bloc/profile_bloc.dart';
import '../../../rs_main/view/rs_main_screen.dart';
import '../../../sm_main_page.dart';

class RestaurantCartAddMoreProductsButton extends StatelessWidget {
  const RestaurantCartAddMoreProductsButton({
    super.key,
    this.isRestaurant = true,
  });
  final bool isRestaurant;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => isRestaurant
          ? context.pushRoute('/rsmain',arguments: RsMainScreenParams(
        profileBloc: getIt<ProfileBloc>(),

      ))
          : context.pushRoute(
              '/smmain',
              arguments: SmMainScreenParams(
                initialPage: 0,
                expandSearch: false,
              ),
            ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffD1D5DB), width: 1.3),
        ),
        child: Center(
          child: AppText.labelLarge(
            'إضافة منتجات أخرى',
            color: const Color(0xff4B5563),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
