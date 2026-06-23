// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/material.dart';
import 'package:dllni_user_app/features/auth/view/screens/account_recovery_screen.dart';
import 'package:dllni_user_app/features/auth/view/screens/login_screen.dart';
import 'package:dllni_user_app/features/auth/view/screens/register_screen.dart';
import 'package:dllni_user_app/features/auth/view/screens/verify_account_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_home_description_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_occasion_description_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/data/cl_main_route_args.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_occasion_schedule_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/manager/bloc/cl_main_bloc.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_service_schedule_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_worker_profile_detail_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_worker_reviews_all_screen.dart';
import 'package:dllni_user_app/features/delivery/presentation/screens/delivery_order_tracking_screen.dart';
import 'package:dllni_user_app/features/delivery/presentation/screens/delivery_orders_screen.dart';
import 'package:dllni_user_app/features/main/view/screens/main_screen.dart';
import 'package:dllni_user_app/features/orders/view/screens/cleaning_order_details_screen.dart';
import 'package:dllni_user_app/features/orders/view/screens/cleaning_order_problem_report_screen.dart';
import 'package:dllni_user_app/features/orders/view/screens/cleaning_order_reschedule_screen.dart';
import 'package:dllni_user_app/features/orders/view/screens/cleaning_order_sos_screen.dart';
import 'package:dllni_user_app/features/orders/view/screens/cleaning_worker_rating_screen.dart';
import 'package:dllni_user_app/features/orders/view/screens/restaurant_order_fulfillment_screen.dart';
import 'package:dllni_user_app/features/orders/view/screens/restaurant_order_tracking_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/add_address_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/add_edit_shopping_list_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/coupons_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/group_order_followup_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/group_order_setup_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/lucky_box_setup_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/lucky_box_suggestions_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/my_addresses_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/notifications_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/order_voting_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/personal_details_screen.dart';
import 'package:dllni_user_app/features/auth/data/models/login_response_model.dart';
import 'package:dllni_user_app/features/profile/view/screens/shopping_list_details_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/shopping_list_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/vote_followup_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_discover_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_all_products_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_all_reviews_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_details_screen.dart';
import 'package:dllni_user_app/features/rs_favourite/view/screens/rs_favourite_screen.dart';
import 'package:dllni_user_app/features/rs_home/view/screens/rs_home_category_products_screen.dart';
import 'package:dllni_user_app/features/rs_home/view/screens/rs_home_screen.dart';
import 'package:dllni_user_app/features/rs_main/view/rs_main_screen.dart';
import 'package:dllni_user_app/features/sm_cart/view/screens/sm_cart_details_screen.dart';
import 'package:dllni_user_app/features/sm_cart/view/screens/sm_cart_screen.dart';
import 'package:dllni_user_app/features/sm_cart/view/screens/sm_late_time_screen.dart';
import 'package:dllni_user_app/features/sm_discover/view/screens/sm_all_products_screen.dart';
import 'package:dllni_user_app/features/sm_discover/view/screens/sm_autocomplete_demo_screen.dart';
import 'package:dllni_user_app/features/sm_discover/view/screens/sm_discover_screen.dart';
import 'package:dllni_user_app/features/sm_favorite/view/screens/sm_favorite_screen.dart';
import 'package:dllni_user_app/features/sm_home/view/screens/sm_home_screen.dart';
import 'package:dllni_user_app/features/sm_main_page.dart';
import 'package:dllni_user_app/features/sm_offers/view/screens/sm_offers_screen.dart';
import 'package:dllni_user_app/features/sm_orders/view/screens/sm_order_details_screen.dart';
import 'package:dllni_user_app/features/sm_orders/view/screens/sm_order_tracking_screen.dart';
import 'package:dllni_user_app/features/sm_stores/view/screens/sm_product_details_screen.dart';
import 'package:dllni_user_app/features/sm_stores/view/screens/sm_store_details_screen.dart';

class GeneratedAppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/account-recovery':
        return MaterialPageRoute(
          builder: (_) => AccountRecoveryScreen(),
          settings: settings,
        );
      case '/login':
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );
      case '/register':
        return MaterialPageRoute(
          builder: (_) => RegisterScreen(),
          settings: settings,
        );
      case '/verify-account':
        if (args is VerifyAccountRouteArgs) {
          return MaterialPageRoute(
            builder: (_) => VerifyAccountScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/clmainhomedescription':
        return MaterialPageRoute(
          builder: (_) => ClMainHomeDescriptionScreen(),
          settings: settings,
        );
      case '/clmainoccasiondescription':
        if (args is ClMainOccasionDescriptionArgs?) {
          return MaterialPageRoute(
            builder: (_) => ClMainOccasionDescriptionScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/clmainoccasionschedule':
        if (args is ClMainOccasionScheduleArgs?) {
          return MaterialPageRoute(
            builder: (_) => ClMainOccasionScheduleScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/clmain':
        if (args is ClMainScreenParams) {
          return MaterialPageRoute(
            builder: (_) => ClMainScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/clmainserviceschedule':
        if (args is ClMainScheduleArgs?) {
          return MaterialPageRoute(
            builder: (_) => ClMainServiceScheduleScreen(item: args, args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/clworkerprofiledetail':
        if (args is WorkerProfileRouteArgs) {
          return MaterialPageRoute(
            builder: (_) => ClWorkerProfileDetailScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/clworkerreviewsall':
        if (args is WorkerProfileRouteArgs) {
          return MaterialPageRoute(
            builder: (_) => ClWorkerReviewsAllScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/delivery/orders/tracking':
        if (args is DeliveryOrderTrackingArgs) {
          return MaterialPageRoute(
            builder: (_) => DeliveryOrderTrackingScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/delivery/orders':
        return MaterialPageRoute(
          builder: (_) => DeliveryOrdersScreen(),
          settings: settings,
        );
      case '/main':
        if (args is int?) {
          return MaterialPageRoute(
            builder: (_) => MainScreen(returnedIndex: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/cleaning-order-details':
        if (args is CleaningOrderDetailsArgs) {
          return MaterialPageRoute(
            builder: (_) => CleaningOrderDetailsScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/cleaning-order-problem':
        if (args is CleaningOrderProblemReportArgs) {
          return MaterialPageRoute(
            builder: (_) => CleaningOrderProblemReportScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/cleaning-order-reschedule':
        if (args is CleaningOrderRescheduleArgs) {
          return MaterialPageRoute(
            builder: (_) => CleaningOrderRescheduleScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/cleaning-order-sos':
        if (args is CleaningOrderSosArgs) {
          return MaterialPageRoute(
            builder: (_) => CleaningOrderSosScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/cleaning-worker-rating':
        if (args is CleaningWorkerRatingArgs) {
          return MaterialPageRoute(
            builder: (_) => CleaningWorkerRatingScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/restaurant-order-fulfillment':
        if (args is RestaurantOrderFulfillmentArgs) {
          return MaterialPageRoute(
            builder: (_) => RestaurantOrderFulfillmentScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/restaurant-order-tracking':
        if (args is RestaurantOrderTrackingArgs) {
          return MaterialPageRoute(
            builder: (_) => RestaurantOrderTrackingScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/addaddress':
        if (args is MyAddressesScreenParams) {
          return MaterialPageRoute(
            builder: (_) => AddAddressScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/add_edit_shopping_list':
        if (args is AddEditShoppingListScreenArgs) {
          return MaterialPageRoute(
            builder: (_) => AddEditShoppingListScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/coupons':
        return MaterialPageRoute(
          builder: (_) => CouponsScreen(),
          settings: settings,
        );
      case '/group-order/followup':
        if (args is GroupOrderFollowupScreenParams) {
          return MaterialPageRoute(
            builder: (_) => GroupOrderFollowupScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/group-order/create':
        return MaterialPageRoute(
          builder: (_) => GroupOrderSetupScreen(),
          settings: settings,
        );
      case '/luckyboxsetup':
        return MaterialPageRoute(
          builder: (_) => LuckyBoxSetupScreen(),
          settings: settings,
        );
      case '/luckyboxsuggestions':
        if (args is LuckyBoxSuggestionsArgs) {
          return MaterialPageRoute(
            builder: (_) => LuckyBoxSuggestionsScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/myaddresses':
        if (args is bool) {
          return MaterialPageRoute(
            builder: (_) => MyAddressesScreen(selectMode: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => NotificationsScreen(),
          settings: settings,
        );
      case '/ordervoting':
        return MaterialPageRoute(
          builder: (_) => OrderVotingScreen(),
          settings: settings,
        );
      case '/personaldetails':
        if (args is LoggedInUserModel) {
          return MaterialPageRoute(
            builder: (_) => PersonalDetailsScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/shopping_list_details':
        if (args is ShoppingListDetailsScreenArgs) {
          return MaterialPageRoute(
            builder: (_) => ShoppingListDetailsScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/shopping_list':
        return MaterialPageRoute(
          builder: (_) => ShoppingListScreen(),
          settings: settings,
        );
      case '/votefollowup':
        if (args is VoteFollowupScreenParams) {
          return MaterialPageRoute(
            builder: (_) => VoteFollowupScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rs_discover':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => RsDiscoverScreen(selectedView: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rs_product':
        if (args is ProductDetailsScreenParams) {
          return MaterialPageRoute(
            builder: (_) => RsProductDetailsScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rs_store-all-products':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => SmStoreAllProductsScreen(restaurantId: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rs_store-all-reviews':
        if (args is StoreAllReviewsScreenParams) {
          return MaterialPageRoute(
            builder: (_) => SmStoreAllReviewsScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rs_store':
        if (args is StoreDetailsScreenParams) {
          return MaterialPageRoute(
            builder: (_) => RsStoreDetailsScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/rsfavourite':
        return MaterialPageRoute(
          builder: (_) => RsFavouriteScreen(),
          settings: settings,
        );
      case '/rshomecategoryproducts':
        if (args is RsHomeCategoryProductsScreenParams) {
          return MaterialPageRoute(
            builder: (_) => RsHomeCategoryProductsScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/home':
        if (args is RsHomeScreenParams) {
          return MaterialPageRoute(
            builder: (_) => RsHomeScreen(args: args,),

            settings: settings,
          );
        }
        return _errorRoute(settings);


      case '/rsmain':

        if (args is RsMainScreenParams) {
          return MaterialPageRoute(
            builder: (_) => RsMainScreen(args: args,),

            settings: settings,
          );
        }
        return _errorRoute(settings);

      case '/cart_details':
        return MaterialPageRoute(
          builder: (_) => SmCartDetailsScreen(),
          settings: settings,
        );
      case '/cart':
        if (args is SmCartScreenParams?) {
          return MaterialPageRoute(
            builder: (_) => SmCartScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/late_time':
        return MaterialPageRoute(
          builder: (_) => SmLateTimeScreen(),
          settings: settings,
        );
      case '/sm_store-all-products':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => SmAllProductsScreen(storeId: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/sm_autocomplete_demo':
        return MaterialPageRoute(
          builder: (_) => SmAutocompleteDemoScreen(),
          settings: settings,
        );
      case '/sm_discover':
        if (args is SmDiscoverScreenParams) {
          return MaterialPageRoute(
            builder: (_) => SmDiscoverScreen(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/sm_favorite':
        return MaterialPageRoute(
          builder: (_) => SmFavoriteScreen(),
          settings: settings,
        );
      case '/sm_home':
        return MaterialPageRoute(
          builder: (_) => SmHomeScreen(),
          settings: settings,
        );
      case '/smmain':
        if (args is SmMainScreenParams) {
          return MaterialPageRoute(
            builder: (_) => SmMainPage(params: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/sm_offers':
        return MaterialPageRoute(
          builder: (_) => SmOffersScreen(),
          settings: settings,
        );
      case '/order_details':
        if (args is SmOrderDetailsScreenArgs) {
          return MaterialPageRoute(
            builder: (_) => SmOrderDetailsScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/order_tracking':
        return MaterialPageRoute(
          builder: (_) => SmOrderTrackingScreen(),
          settings: settings,
        );
      case '/product':
        if (args is SmProductDetailsScreenArgs) {
          return MaterialPageRoute(
            builder: (_) => SmProductDetailsScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
      case '/store':
        if (args is SmStoreDetailsScreenArgs?) {
          return MaterialPageRoute(
            builder: (_) => SmStoreDetailsScreen(args: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);
    }

    return null;
  }

  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) =>
      const Scaffold(
        body: Center(child: Text('Route Error')),
      ),
      settings: settings,
    );
  }
}
