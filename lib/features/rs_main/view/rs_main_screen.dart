import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/cart/cart_products_count_cubit.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/rs_main/view/widgets/rs_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

import '../../profile/domain/usecases/fetch_notifications_use_case.dart';
import '../../profile/view/manager/bloc/profile_bloc.dart';
import '../../rs_discover/view/screens/rs_discover_screen.dart';
import '../../rs_favourite/view/screens/rs_favourite_screen.dart';
import '../../rs_home/view/screens/rs_home_screen.dart';
import '../../rs_offers/view/rs_offers_screen.dart';

class RsMainScreenParams {
  final ProfileBloc profileBloc;

  RsMainScreenParams({required this.profileBloc});
}

@AutoRoutePage()
class RsMainScreen extends StatefulWidget {

  final RsMainScreenParams args;

  const RsMainScreen({super.key, required this.args});

  @override
  State<RsMainScreen> createState() => _RsMainScreenState();
}

class _RsMainScreenState extends State<RsMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  late final ProfileBloc profileBloc;


  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);

    profileBloc = widget.args.profileBloc;
    getIt<CartProductsCountCubit>().fetchCount();
  }

  List<Widget> get pages => [
    RsHomeScreen(
      args: RsHomeScreenParams(profileBloc: profileBloc),
    ),
    const RsDiscoverScreen(),
    const RsOffersScreen(),
    const RsFavouriteScreen(),
  ];

  // List<Widget> pages = <Widget>[
  //   RsHomeScreen(args: RsHomeScreenParams(profileBloc: profileBloc),),
  //   RsDiscoverScreen(),
  //   RsOffersScreen(),
  //   RsFavouriteScreen(),
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        body: TabBarView(
          controller: controller,
          physics: NeverScrollableScrollPhysics(),
          children: pages,
        ),
      ),
      bottomNavigationBar: RsBottomNavBar(controller: controller),
    );
  }
}
