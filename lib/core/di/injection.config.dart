// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:common_package/common_package.dart' as _i960;
import 'package:common_package/helpers/dio_network.dart' as _i497;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/repository/auth_repo_impl.dart' as _i751;
import '../../features/auth/data/source/auth_remote_data_source.dart' as _i777;
import '../../features/auth/domain/repository/auth_repo.dart' as _i976;
import '../../features/auth/domain/usecases/login_use_case.dart' as _i37;
import '../../features/auth/domain/usecases/register_use_case.dart' as _i97;
import '../../features/auth/view/manager/bloc/auth_bloc.dart' as _i958;
import '../../features/cl_main/data/repository/cl_main_repo_impl.dart' as _i466;
import '../../features/cl_main/data/source/cl_main_remote_data_source.dart'
    as _i817;
import '../../features/cl_main/domain/repository/cl_main_repo.dart' as _i342;
import '../../features/cl_main/domain/usecases/create_cleaning_order_use_case.dart'
    as _i620;
import '../../features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart'
    as _i762;
import '../../features/cl_main/domain/usecases/get_cleaning_banners_use_case.dart'
    as _i750;
import '../../features/cl_main/domain/usecases/get_cleaning_services_use_case.dart'
    as _i895;
import '../../features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart'
    as _i491;
import '../../features/cl_main/view/manager/bloc/cl_main_bloc.dart' as _i362;
import '../../features/home/data/repository/home_repo_impl.dart' as _i1013;
import '../../features/home/data/source/home_remote_data_source.dart' as _i557;
import '../../features/home/domain/repository/home_repo.dart' as _i396;
import '../../features/home/domain/usecases/fetch_user_offers_use_case.dart'
    as _i487;
import '../../features/home/view/manager/bloc/home_bloc.dart' as _i648;
import '../../features/orders/data/repository/orders_repo_impl.dart' as _i849;
import '../../features/orders/data/source/orders_remote_data_source.dart'
    as _i702;
import '../../features/orders/domain/repository/orders_repo.dart' as _i132;
import '../../features/orders/domain/usecases/cancel_cleaning_order_use_case.dart'
    as _i172;
import '../../features/orders/domain/usecases/check_restaurant_coupon_use_case.dart'
    as _i576;
import '../../features/orders/domain/usecases/confirm_cleaning_completion_use_case.dart'
    as _i28;
import '../../features/orders/domain/usecases/confirm_cleaning_start_verification_use_case.dart'
    as _i561;
import '../../features/orders/domain/usecases/delete_cart_item_use_case.dart'
    as _i242;
import '../../features/orders/domain/usecases/delete_store_cart_item_use_case.dart'
    as _i29;
import '../../features/orders/domain/usecases/extend_cleaning_completion_time_use_case.dart'
    as _i22;
import '../../features/orders/domain/usecases/fetch_cleaning_order_details_use_case.dart'
    as _i232;
import '../../features/orders/domain/usecases/fetch_cleaning_orders_use_case.dart'
    as _i382;
import '../../features/orders/domain/usecases/fetch_cleaning_worker_profile_use_case.dart'
    as _i891;
import '../../features/orders/domain/usecases/fetch_order_details_use_case.dart'
    as _i438;
import '../../features/orders/domain/usecases/fetch_orders_use_case.dart'
    as _i250;
import '../../features/orders/domain/usecases/fetch_restaurant_cart_use_case.dart'
    as _i335;
import '../../features/orders/domain/usecases/fetch_restaurant_order_tracking_use_case.dart'
    as _i556;
import '../../features/orders/domain/usecases/fetch_store_cart_use_case.dart'
    as _i953;
import '../../features/orders/domain/usecases/fetch_store_order_tracking_use_case.dart'
    as _i138;
import '../../features/orders/domain/usecases/patch_cleaning_order_use_case.dart'
    as _i795;
import '../../features/orders/domain/usecases/patch_cleaning_room_assignments_use_case.dart'
    as _i582;
import '../../features/orders/domain/usecases/place_restaurant_order_use_case.dart'
    as _i109;
import '../../features/orders/domain/usecases/place_store_order_use_case.dart'
    as _i969;
import '../../features/orders/domain/usecases/reject_cleaning_completion_use_case.dart'
    as _i51;
import '../../features/orders/domain/usecases/sos_use_cases.dart' as _i988;
import '../../features/orders/domain/usecases/submit_cleaning_review_use_case.dart'
    as _i642;
import '../../features/orders/domain/usecases/update_cart_item_quantity_use_case.dart'
    as _i925;
import '../../features/orders/domain/usecases/update_store_cart_item_quantity_use_case.dart'
    as _i190;
import '../../features/orders/view/manager/bloc/orders_bloc.dart' as _i305;
import '../../features/orders/view/manager/cubit/restaurant_order_checkout_cubit.dart'
    as _i1049;
import '../../features/profile/data/repository/profile_repo_impl.dart' as _i265;
import '../../features/profile/data/repository/shopping_lists_repo_impl.dart'
    as _i387;
import '../../features/profile/data/source/profile_remote_data_source.dart'
    as _i502;
import '../../features/profile/data/source/shopping_lists_remote_data_source.dart'
    as _i1007;
import '../../features/profile/domain/repository/profile_repo.dart' as _i275;
import '../../features/profile/domain/repository/shopping_lists_repo.dart'
    as _i326;
import '../../features/profile/domain/services/user_location_service.dart'
    as _i426;
import '../../features/profile/domain/usecases/add_favorite_restaurant_use_case.dart'
    as _i761;
import '../../features/profile/domain/usecases/add_group_order_item_use_case.dart'
    as _i1062;
import '../../features/profile/domain/usecases/add_shopping_list_item_use_case.dart'
    as _i906;
import '../../features/profile/domain/usecases/add_shopping_list_to_cart_use_case.dart'
    as _i992;
import '../../features/profile/domain/usecases/cancel_group_order_use_case.dart'
    as _i592;
import '../../features/profile/domain/usecases/create_address_use_case.dart'
    as _i687;
import '../../features/profile/domain/usecases/create_group_order_use_case.dart'
    as _i77;
import '../../features/profile/domain/usecases/create_shopping_list_use_case.dart'
    as _i614;
import '../../features/profile/domain/usecases/create_vote_use_case.dart'
    as _i679;
import '../../features/profile/domain/usecases/delete_address_use_case.dart'
    as _i39;
import '../../features/profile/domain/usecases/delete_group_order_item_use_case.dart'
    as _i617;
import '../../features/profile/domain/usecases/delete_shopping_list_item_use_case.dart'
    as _i12;
import '../../features/profile/domain/usecases/delete_shopping_list_use_case.dart'
    as _i98;
import '../../features/profile/domain/usecases/end_vote_use_case.dart' as _i875;
import '../../features/profile/domain/usecases/fetch_active_group_orders_use_case.dart'
    as _i194;
import '../../features/profile/domain/usecases/fetch_active_votes_use_case.dart'
    as _i808;
import '../../features/profile/domain/usecases/fetch_addresses_use_case.dart'
    as _i376;
import '../../features/profile/domain/usecases/fetch_coupons_use_case.dart'
    as _i879;
import '../../features/profile/domain/usecases/fetch_favorite_restaurants_use_case.dart'
    as _i319;
import '../../features/profile/domain/usecases/fetch_group_order_menu_sections_use_case.dart'
    as _i666;
import '../../features/profile/domain/usecases/fetch_luck_box_options_use_case.dart'
    as _i866;
import '../../features/profile/domain/usecases/fetch_notifications_use_case.dart'
    as _i438;
import '../../features/profile/domain/usecases/fetch_shopping_list_detail_use_case.dart'
    as _i11;
import '../../features/profile/domain/usecases/fetch_shopping_lists_use_case.dart'
    as _i524;
import '../../features/profile/domain/usecases/fetch_vote_suggestions_use_case.dart'
    as _i381;
import '../../features/profile/domain/usecases/get_shopping_list_use_case.dart'
    as _i877;
import '../../features/profile/domain/usecases/join_group_order_use_case.dart'
    as _i461;
import '../../features/profile/domain/usecases/mark_all_notifications_read_use_case.dart'
    as _i10;
import '../../features/profile/domain/usecases/mark_notification_read_use_case.dart'
    as _i338;
import '../../features/profile/domain/usecases/place_group_order_use_case.dart'
    as _i342;
import '../../features/profile/domain/usecases/remove_favorite_restaurant_use_case.dart'
    as _i999;
import '../../features/profile/domain/usecases/set_default_address_use_case.dart'
    as _i262;
import '../../features/profile/domain/usecases/show_group_order_use_case.dart'
    as _i662;
import '../../features/profile/domain/usecases/show_vote_use_case.dart'
    as _i320;
import '../../features/profile/domain/usecases/submit_group_order_use_case.dart'
    as _i467;
import '../../features/profile/domain/usecases/submit_vote_ballot_use_case.dart'
    as _i529;
import '../../features/profile/domain/usecases/suggest_luck_box_use_case.dart'
    as _i89;
import '../../features/profile/domain/usecases/unsubmit_group_order_use_case.dart'
    as _i567;
import '../../features/profile/domain/usecases/update_account_password_use_case.dart'
    as _i591;
import '../../features/profile/domain/usecases/update_account_use_case.dart'
    as _i178;
import '../../features/profile/domain/usecases/update_address_use_case.dart'
    as _i983;
import '../../features/profile/domain/usecases/update_group_order_item_use_case.dart'
    as _i1008;
import '../../features/profile/domain/usecases/update_shopping_list_item_use_case.dart'
    as _i170;
import '../../features/profile/domain/usecases/update_shopping_list_use_case.dart'
    as _i901;
import '../../features/profile/view/manager/bloc/profile_bloc.dart' as _i821;
import '../../features/profile/view/manager/coupons_cubit.dart' as _i767;
import '../../features/profile/view/manager/lucky_box_cubit.dart' as _i849;
import '../../features/rs_discover/data/repository/rs_discover_repo_impl.dart'
    as _i992;
import '../../features/rs_discover/data/source/rs_discover_remote_data_source.dart'
    as _i341;
import '../../features/rs_discover/domain/repository/rs_discover_repo.dart'
    as _i622;
import '../../features/rs_discover/domain/usecases/add_restaurant_cart_item_use_case.dart'
    as _i745;
import '../../features/rs_discover/domain/usecases/fetch_discover_restaurants_use_case.dart'
    as _i303;
import '../../features/rs_discover/domain/usecases/fetch_restaurant_cart_products_count_use_case.dart'
    as _i716;
import '../../features/rs_discover/domain/usecases/fetch_restaurant_details_use_case.dart'
    as _i112;
import '../../features/rs_discover/domain/usecases/fetch_restaurant_product_details_use_case.dart'
    as _i1;
import '../../features/rs_discover/domain/usecases/fetch_restaurant_products_search_use_case.dart'
    as _i526;
import '../../features/rs_discover/view/manager/bloc/rs_discover_bloc.dart'
    as _i589;
import '../../features/rs_favourite/data/repository/rs_favourite_repo_impl.dart'
    as _i489;
import '../../features/rs_favourite/data/source/rs_favourite_remote_data_source.dart'
    as _i206;
import '../../features/rs_favourite/domain/repository/rs_favourite_repo.dart'
    as _i865;
import '../../features/rs_favourite/domain/usecases/fetch_favourite_products_use_case.dart'
    as _i889;
import '../../features/rs_favourite/domain/usecases/fetch_rs_favourites_use_case.dart'
    as _i1021;
import '../../features/rs_favourite/domain/usecases/toggle_product_favourite_use_case.dart'
    as _i973;
import '../../features/rs_favourite/domain/usecases/toggle_restaurant_favourite_use_case.dart'
    as _i365;
import '../../features/rs_favourite/view/manager/bloc/rs_favourite_bloc.dart'
    as _i519;
import '../../features/rs_home/data/repository/rs_home_repo_impl.dart' as _i500;
import '../../features/rs_home/data/source/rs_home_remote_data_source.dart'
    as _i165;
import '../../features/rs_home/domain/repository/rs_home_repo.dart' as _i117;
import '../../features/rs_home/domain/usecases/fetch_featured_offers_use_case.dart'
    as _i555;
import '../../features/rs_home/domain/usecases/fetch_near_by_stores_use_case.dart'
    as _i238;
import '../../features/rs_home/domain/usecases/fetch_restaurant_home_categories_use_case.dart'
    as _i89;
import '../../features/rs_home/domain/usecases/fetch_restaurant_home_category_products_use_case.dart'
    as _i892;
import '../../features/rs_home/domain/usecases/fetch_restaurant_home_exclusive_offers_use_case.dart'
    as _i1047;
import '../../features/rs_home/domain/usecases/fetch_restaurant_home_latest_ordered_products_use_case.dart'
    as _i171;
import '../../features/rs_home/domain/usecases/fetch_restaurant_home_nearest_restaurants_use_case.dart'
    as _i967;
import '../../features/rs_home/domain/usecases/fetch_restaurant_home_suggested_products_use_case.dart'
    as _i339;
import '../../features/rs_home/domain/usecases/fetch_stores_use_case.dart'
    as _i181;
import '../../features/rs_home/domain/usecases/reorder_latest_ordered_product_use_case.dart'
    as _i373;
import '../../features/rs_home/view/manager/bloc/rs_home_bloc.dart' as _i836;
import '../../features/rs_main/data/repository/rs_main_repo_impl.dart' as _i427;
import '../../features/rs_main/domain/repository/rs_main_repo.dart' as _i744;
import '../../features/rs_main/view/manager/bloc/rs_main_bloc.dart' as _i752;
import '../../features/rs_offers/data/repository/rs_offers_repo_impl.dart'
    as _i673;
import '../../features/rs_offers/data/source/rs_offers_remote_data_source.dart'
    as _i908;
import '../../features/rs_offers/domain/repository/rs_offers_repo.dart' as _i75;
import '../../features/rs_offers/domain/usecases/fetch_rs_offers_products_use_case.dart'
    as _i317;
import '../../features/rs_offers/view/manager/bloc/rs_offers_bloc.dart'
    as _i391;
import '../../features/sm_cart/data/repository/sm_cart_repo_impl.dart' as _i91;
import '../../features/sm_cart/domain/repository/sm_cart_repo.dart' as _i579;
import '../../features/sm_cart/view/manager/bloc/sm_cart_bloc.dart' as _i821;
import '../../features/sm_discover/data/repository/sm_discover_repo_impl.dart'
    as _i43;
import '../../features/sm_discover/data/source/sm_discover_remote_data_source.dart'
    as _i949;
import '../../features/sm_discover/domain/repository/sm_discover_repo.dart'
    as _i880;
import '../../features/sm_discover/domain/usecases/browse_products_use_case.dart'
    as _i321;
import '../../features/sm_discover/domain/usecases/browse_stores_use_case.dart'
    as _i84;
import '../../features/sm_discover/domain/usecases/change_product_favorite_use_case.dart'
    as _i871;
import '../../features/sm_discover/domain/usecases/change_store_favorite_use_case.dart'
    as _i327;
import '../../features/sm_discover/domain/usecases/normalize_product_text_use_case.dart'
    as _i248;
import '../../features/sm_discover/view/manager/bloc/sm_discover_bloc.dart'
    as _i717;
import '../../features/sm_favorite/data/repository/sm_favorite_repo_impl.dart'
    as _i423;
import '../../features/sm_favorite/data/source/sm_favorite_remote_data_source.dart'
    as _i381;
import '../../features/sm_favorite/domain/repository/sm_favorite_repo.dart'
    as _i957;
import '../../features/sm_favorite/domain/usecases/get_favorite_supermarket_products_use_case.dart'
    as _i163;
import '../../features/sm_favorite/domain/usecases/get_favorite_supermarket_stores_use_case.dart'
    as _i1051;
import '../../features/sm_favorite/view/manager/bloc/sm_favorite_bloc.dart'
    as _i531;
import '../../features/sm_home/data/repository/sm_home_repo_impl.dart' as _i991;
import '../../features/sm_home/data/source/sm_home_remote_data_source.dart'
    as _i1025;
import '../../features/sm_home/domain/repository/sm_home_repo.dart' as _i267;
import '../../features/sm_home/domain/usecases/change_store_favorite_use_case.dart'
    as _i583;
import '../../features/sm_home/domain/usecases/get_featured_offers_use_case.dart'
    as _i437;
import '../../features/sm_home/domain/usecases/get_nearby_stores_use_case.dart'
    as _i690;
import '../../features/sm_home/view/manager/bloc/sm_home_bloc.dart' as _i626;
import '../../features/sm_offers/data/repository/sm_offers_repo_impl.dart'
    as _i213;
import '../../features/sm_offers/data/source/sm_offers_remote_data_source.dart'
    as _i875;
import '../../features/sm_offers/domain/repository/sm_offers_repo.dart'
    as _i446;
import '../../features/sm_offers/view/manager/bloc/sm_offers_bloc.dart'
    as _i709;
import '../../features/sm_orders/data/repository/sm_orders_repo_impl.dart'
    as _i290;
import '../../features/sm_orders/data/source/sm_orders_remote_data_source.dart'
    as _i400;
import '../../features/sm_orders/domain/repository/sm_orders_repo.dart'
    as _i753;
import '../../features/sm_orders/view/manager/bloc/sm_orders_bloc.dart'
    as _i803;
import '../../features/sm_stores/data/repository/sm_stores_repo_impl.dart'
    as _i580;
import '../../features/sm_stores/data/source/sm_stores_remote_data_source.dart'
    as _i179;
import '../../features/sm_stores/domain/repository/sm_stores_repo.dart'
    as _i359;
import '../../features/sm_stores/domain/usecases/add_supermarket_cart_item_use_case.dart'
    as _i431;
import '../../features/sm_stores/domain/usecases/get_compare_products_use_case.dart'
    as _i802;
import '../../features/sm_stores/domain/usecases/get_supermarket_product_details_use_case.dart'
    as _i749;
import '../../features/sm_stores/domain/usecases/get_supermarket_store_details_use_case.dart'
    as _i151;
import '../../features/sm_stores/view/manager/bloc/sm_stores_bloc.dart'
    as _i883;
import '../deeplink/deep_link_remote_data_source.dart' as _i229;
import '../deeplink/deep_link_service.dart' as _i359;
import '../realtime/cleaning_booking_pusher_service.dart' as _i432;
import 'injection.dart' as _i464;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final injectableModule = _$InjectableModule();
  gh.factory<_i752.RsMainBloc>(() => _i752.RsMainBloc());
  gh.factory<_i821.SmCartBloc>(() => _i821.SmCartBloc());
  gh.factory<_i709.SmOffersBloc>(() => _i709.SmOffersBloc());
  gh.factory<_i803.SmOrdersBloc>(() => _i803.SmOrdersBloc());
  gh.singleton<_i960.DioNetwork>(() => injectableModule.dio);
  gh.lazySingleton<_i432.CleaningBookingPusherService>(
    () => _i432.CleaningBookingPusherService(),
  );
  gh.lazySingleton<_i426.UserLocationService>(
    () => _i426.UserLocationService(),
  );
  gh.lazySingleton<_i875.SmOffersRemoteDataSource>(
    () => _i875.SmOffersRemoteDataSource(),
  );
  gh.lazySingleton<_i400.SmOrdersRemoteDataSource>(
    () => _i400.SmOrdersRemoteDataSource(),
  );
  gh.lazySingleton<_i579.SmCartRepo>(() => _i91.SmCartRepoImpl());
  gh.lazySingleton<_i817.ClMainRemoteDataSource>(
    () => _i817.ClMainRemoteDataSource(dioNetwork: gh<_i497.DioNetwork>()),
  );
  gh.lazySingleton<_i557.HomeRemoteDataSource>(
    () => _i557.HomeRemoteDataSource(dioNetwork: gh<_i497.DioNetwork>()),
  );
  gh.lazySingleton<_i702.OrdersRemoteDataSource>(
    () => _i702.OrdersRemoteDataSource(dioNetwork: gh<_i497.DioNetwork>()),
  );
  gh.lazySingleton<_i908.RsOffersRemoteDataSource>(
    () => _i908.RsOffersRemoteDataSource(dioNetwork: gh<_i497.DioNetwork>()),
  );
  gh.lazySingleton<_i446.SmOffersRepo>(() => _i213.SmOffersRepoImpl());
  gh.lazySingleton<_i753.SmOrdersRepo>(() => _i290.SmOrdersRepoImpl());
  gh.lazySingleton<_i744.RsMainRepo>(() => _i427.RsMainRepoImpl());
  gh.lazySingleton<_i229.DeepLinkRemoteDataSource>(
    () => _i229.DeepLinkRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i777.AuthRemoteDataSource>(
    () => _i777.AuthRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i502.ProfileRemoteDataSource>(
    () => _i502.ProfileRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i1007.ShoppingListsRemoteDataSource>(
    () => _i1007.ShoppingListsRemoteDataSource(
      dioNetwork: gh<_i960.DioNetwork>(),
    ),
  );
  gh.lazySingleton<_i341.RsDiscoverRemoteDataSource>(
    () => _i341.RsDiscoverRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i206.RsFavouriteRemoteDataSource>(
    () => _i206.RsFavouriteRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i165.RsHomeRemoteDataSource>(
    () => _i165.RsHomeRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i949.SmDiscoverRemoteDataSource>(
    () => _i949.SmDiscoverRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i381.SmFavoriteRemoteDataSource>(
    () => _i381.SmFavoriteRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i1025.SmHomeRemoteDataSource>(
    () => _i1025.SmHomeRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i179.SmStoresRemoteDataSource>(
    () => _i179.SmStoresRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i267.SmHomeRepo>(
    () => _i991.SmHomeRepoImpl(
      smHomeRemoteDataSource: gh<_i1025.SmHomeRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i75.RsOffersRepo>(
    () => _i673.RsOffersRepoImpl(
      rsOffersRemoteDataSource: gh<_i908.RsOffersRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i396.HomeRepo>(
    () => _i1013.HomeRepoImpl(
      homeRemoteDataSource: gh<_i557.HomeRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i880.SmDiscoverRepo>(
    () => _i43.SmDiscoverRepoImpl(
      smDiscoverRemoteDataSource: gh<_i949.SmDiscoverRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i865.RsFavouriteRepo>(
    () => _i489.RsFavouriteRepoImpl(
      rsFavouriteRemoteDataSource: gh<_i206.RsFavouriteRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i359.DeepLinkService>(
    () => _i359.DeepLinkService(gh<_i229.DeepLinkRemoteDataSource>()),
  );
  gh.lazySingleton<_i359.SmStoresRepo>(
    () => _i580.SmStoresRepoImpl(
      smStoresRemoteDataSource: gh<_i179.SmStoresRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i622.RsDiscoverRepo>(
    () => _i992.RsDiscoverRepoImpl(
      rsDiscoverRemoteDataSource: gh<_i341.RsDiscoverRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i132.OrdersRepo>(
    () => _i849.OrdersRepoImpl(
      ordersRemoteDataSource: gh<_i702.OrdersRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i342.ClMainRepo>(
    () => _i466.ClMainRepoImpl(
      clMainRemoteDataSource: gh<_i817.ClMainRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i431.AddSupermarketCartItemUseCase>(
    () =>
        _i431.AddSupermarketCartItemUseCase(smStores: gh<_i359.SmStoresRepo>()),
  );
  gh.lazySingleton<_i802.GetCompareProductsUseCase>(
    () => _i802.GetCompareProductsUseCase(smStores: gh<_i359.SmStoresRepo>()),
  );
  gh.lazySingleton<_i749.GetSupermarketProductDetailsUseCase>(
    () => _i749.GetSupermarketProductDetailsUseCase(
      smStores: gh<_i359.SmStoresRepo>(),
    ),
  );
  gh.lazySingleton<_i151.GetSupermarketStoreDetailsUseCase>(
    () => _i151.GetSupermarketStoreDetailsUseCase(
      smStores: gh<_i359.SmStoresRepo>(),
    ),
  );
  gh.lazySingleton<_i326.ShoppingListsRepo>(
    () => _i387.ShoppingListsRepoImpl(
      shoppingListsRemoteDataSource: gh<_i1007.ShoppingListsRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i117.RsHomeRepo>(
    () => _i500.RsHomeRepoImpl(
      rsHomeRemoteDataSource: gh<_i165.RsHomeRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i317.FetchRsOffersProductsUseCase>(
    () => _i317.FetchRsOffersProductsUseCase(
      rsOffersRepo: gh<_i75.RsOffersRepo>(),
    ),
  );
  gh.lazySingleton<_i487.FetchUserOffersUseCase>(
    () => _i487.FetchUserOffersUseCase(homeRepo: gh<_i396.HomeRepo>()),
  );
  gh.lazySingleton<_i583.ChangeStoreFavoriteUseCase>(
    () => _i583.ChangeStoreFavoriteUseCase(smHome: gh<_i267.SmHomeRepo>()),
  );
  gh.lazySingleton<_i437.GetFeaturedOffersUseCase>(
    () => _i437.GetFeaturedOffersUseCase(smHome: gh<_i267.SmHomeRepo>()),
  );
  gh.lazySingleton<_i690.GetNearbyStoresUseCase>(
    () => _i690.GetNearbyStoresUseCase(smHome: gh<_i267.SmHomeRepo>()),
  );
  gh.lazySingleton<_i957.SmFavoriteRepo>(
    () => _i423.SmFavoriteRepoImpl(
      smFavoriteRemoteDataSource: gh<_i381.SmFavoriteRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i275.ProfileRepo>(
    () => _i265.ProfileRepoImpl(
      profileRemoteDataSource: gh<_i502.ProfileRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i262.SetDefaultAddressUseCase>(
    () =>
        _i262.SetDefaultAddressUseCase(rsProfileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i889.FetchFavouriteProductsUseCase>(
    () => _i889.FetchFavouriteProductsUseCase(
      rsFavourite: gh<_i865.RsFavouriteRepo>(),
    ),
  );
  gh.lazySingleton<_i1021.FetchRsFavouritesUseCase>(
    () => _i1021.FetchRsFavouritesUseCase(
      rsFavourite: gh<_i865.RsFavouriteRepo>(),
    ),
  );
  gh.lazySingleton<_i973.ToggleProductFavouriteUseCase>(
    () => _i973.ToggleProductFavouriteUseCase(
      rsFavourite: gh<_i865.RsFavouriteRepo>(),
    ),
  );
  gh.lazySingleton<_i365.ToggleRestaurantFavouriteUseCase>(
    () => _i365.ToggleRestaurantFavouriteUseCase(
      rsFavourite: gh<_i865.RsFavouriteRepo>(),
    ),
  );
  gh.factory<_i626.SmHomeBloc>(
    () => _i626.SmHomeBloc(
      gh<_i437.GetFeaturedOffersUseCase>(),
      gh<_i690.GetNearbyStoresUseCase>(),
      gh<_i583.ChangeStoreFavoriteUseCase>(),
    ),
  );
  gh.lazySingleton<_i877.GetShoppingListUseCase>(
    () => _i877.GetShoppingListUseCase(profile: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i906.AddShoppingListItemUseCase>(
    () => _i906.AddShoppingListItemUseCase(
      shoppingListsRepo: gh<_i326.ShoppingListsRepo>(),
    ),
  );
  gh.lazySingleton<_i992.AddShoppingListToCartUseCase>(
    () => _i992.AddShoppingListToCartUseCase(
      shoppingListsRepo: gh<_i326.ShoppingListsRepo>(),
    ),
  );
  gh.lazySingleton<_i614.CreateShoppingListUseCase>(
    () => _i614.CreateShoppingListUseCase(
      shoppingListsRepo: gh<_i326.ShoppingListsRepo>(),
    ),
  );
  gh.lazySingleton<_i12.DeleteShoppingListItemUseCase>(
    () => _i12.DeleteShoppingListItemUseCase(
      shoppingListsRepo: gh<_i326.ShoppingListsRepo>(),
    ),
  );
  gh.lazySingleton<_i98.DeleteShoppingListUseCase>(
    () => _i98.DeleteShoppingListUseCase(
      shoppingListsRepo: gh<_i326.ShoppingListsRepo>(),
    ),
  );
  gh.lazySingleton<_i11.FetchShoppingListDetailUseCase>(
    () => _i11.FetchShoppingListDetailUseCase(
      shoppingListsRepo: gh<_i326.ShoppingListsRepo>(),
    ),
  );
  gh.lazySingleton<_i524.FetchShoppingListsUseCase>(
    () => _i524.FetchShoppingListsUseCase(
      shoppingListsRepo: gh<_i326.ShoppingListsRepo>(),
    ),
  );
  gh.lazySingleton<_i170.UpdateShoppingListItemUseCase>(
    () => _i170.UpdateShoppingListItemUseCase(
      shoppingListsRepo: gh<_i326.ShoppingListsRepo>(),
    ),
  );
  gh.lazySingleton<_i901.UpdateShoppingListUseCase>(
    () => _i901.UpdateShoppingListUseCase(
      shoppingListsRepo: gh<_i326.ShoppingListsRepo>(),
    ),
  );
  gh.lazySingleton<_i976.AuthRepo>(
    () => _i751.AuthRepoImpl(
      authRemoteDataSource: gh<_i777.AuthRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i172.CancelCleaningOrderUseCase>(
    () => _i172.CancelCleaningOrderUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i576.CheckRestaurantCouponUseCase>(
    () =>
        _i576.CheckRestaurantCouponUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i28.ConfirmCleaningCompletionUseCase>(
    () => _i28.ConfirmCleaningCompletionUseCase(
      ordersRepo: gh<_i132.OrdersRepo>(),
    ),
  );
  gh.lazySingleton<_i561.ConfirmCleaningStartVerificationUseCase>(
    () => _i561.ConfirmCleaningStartVerificationUseCase(
      ordersRepo: gh<_i132.OrdersRepo>(),
    ),
  );
  gh.lazySingleton<_i242.DeleteCartItemUseCase>(
    () => _i242.DeleteCartItemUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i29.DeleteStoreCartItemUseCase>(
    () => _i29.DeleteStoreCartItemUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i22.ExtendCleaningCompletionTimeUseCase>(
    () => _i22.ExtendCleaningCompletionTimeUseCase(
      ordersRepo: gh<_i132.OrdersRepo>(),
    ),
  );
  gh.lazySingleton<_i232.FetchCleaningOrderDetailsUseCase>(
    () => _i232.FetchCleaningOrderDetailsUseCase(
      ordersRepo: gh<_i132.OrdersRepo>(),
    ),
  );
  gh.lazySingleton<_i382.FetchCleaningOrdersUseCase>(
    () => _i382.FetchCleaningOrdersUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i891.FetchCleaningWorkerProfileUseCase>(
    () => _i891.FetchCleaningWorkerProfileUseCase(
      ordersRepo: gh<_i132.OrdersRepo>(),
    ),
  );
  gh.lazySingleton<_i438.FetchOrderDetailsUseCase>(
    () => _i438.FetchOrderDetailsUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i250.FetchOrdersUseCase>(
    () => _i250.FetchOrdersUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i335.FetchRestaurantCartUseCase>(
    () => _i335.FetchRestaurantCartUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i556.FetchRestaurantOrderTrackingUseCase>(
    () => _i556.FetchRestaurantOrderTrackingUseCase(
      ordersRepo: gh<_i132.OrdersRepo>(),
    ),
  );
  gh.lazySingleton<_i953.FetchStoreCartUseCase>(
    () => _i953.FetchStoreCartUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i138.FetchStoreOrderTrackingUseCase>(
    () => _i138.FetchStoreOrderTrackingUseCase(
      ordersRepo: gh<_i132.OrdersRepo>(),
    ),
  );
  gh.lazySingleton<_i795.PatchCleaningOrderUseCase>(
    () => _i795.PatchCleaningOrderUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i582.PatchCleaningRoomAssignmentsUseCase>(
    () => _i582.PatchCleaningRoomAssignmentsUseCase(
      ordersRepo: gh<_i132.OrdersRepo>(),
    ),
  );
  gh.lazySingleton<_i109.PlaceRestaurantOrderUseCase>(
    () => _i109.PlaceRestaurantOrderUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i969.PlaceStoreOrderUseCase>(
    () => _i969.PlaceStoreOrderUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i51.RejectCleaningCompletionUseCase>(
    () => _i51.RejectCleaningCompletionUseCase(
      ordersRepo: gh<_i132.OrdersRepo>(),
    ),
  );
  gh.lazySingleton<_i988.CreateUserSosUseCase>(
    () => _i988.CreateUserSosUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i988.FetchSosAlertsUseCase>(
    () => _i988.FetchSosAlertsUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i988.FetchSosAlertDetailsUseCase>(
    () => _i988.FetchSosAlertDetailsUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i642.SubmitCleaningReviewUseCase>(
    () => _i642.SubmitCleaningReviewUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i925.UpdateCartItemQuantityUseCase>(
    () =>
        _i925.UpdateCartItemQuantityUseCase(ordersRepo: gh<_i132.OrdersRepo>()),
  );
  gh.lazySingleton<_i190.UpdateStoreCartItemQuantityUseCase>(
    () => _i190.UpdateStoreCartItemQuantityUseCase(
      ordersRepo: gh<_i132.OrdersRepo>(),
    ),
  );
  gh.lazySingleton<_i163.GetFavoriteSupermarketProductsUseCase>(
    () => _i163.GetFavoriteSupermarketProductsUseCase(
      smFavorite: gh<_i957.SmFavoriteRepo>(),
    ),
  );
  gh.lazySingleton<_i1051.GetFavoriteSupermarketStoresUseCase>(
    () => _i1051.GetFavoriteSupermarketStoresUseCase(
      smFavorite: gh<_i957.SmFavoriteRepo>(),
    ),
  );
  gh.lazySingleton<_i321.BrowseProductsUseCase>(
    () => _i321.BrowseProductsUseCase(smDiscover: gh<_i880.SmDiscoverRepo>()),
  );
  gh.lazySingleton<_i84.BrowseStoresUseCase>(
    () => _i84.BrowseStoresUseCase(smDiscover: gh<_i880.SmDiscoverRepo>()),
  );
  gh.lazySingleton<_i871.ChangeProductFavoriteUseCase>(
    () => _i871.ChangeProductFavoriteUseCase(
      smDiscover: gh<_i880.SmDiscoverRepo>(),
    ),
  );
  gh.lazySingleton<_i327.ChangeStoreFavoriteUseCase>(
    () => _i327.ChangeStoreFavoriteUseCase(
      smDiscover: gh<_i880.SmDiscoverRepo>(),
    ),
  );
  gh.lazySingleton<_i248.NormalizeProductTextUseCase>(
    () => _i248.NormalizeProductTextUseCase(
      smDiscover: gh<_i880.SmDiscoverRepo>(),
    ),
  );
  gh.factory<_i648.HomeBloc>(
    () => _i648.HomeBloc(
      fetchUserOffersUseCase: gh<_i487.FetchUserOffersUseCase>(),
    ),
  );
  gh.factory<_i717.SmDiscoverBloc>(
    () => _i717.SmDiscoverBloc(
      gh<_i84.BrowseStoresUseCase>(),
      gh<_i321.BrowseProductsUseCase>(),
      gh<_i327.ChangeStoreFavoriteUseCase>(),
      gh<_i871.ChangeProductFavoriteUseCase>(),
    ),
  );
  gh.factory<_i519.RsFavouriteBloc>(
    () => _i519.RsFavouriteBloc(
      gh<_i1021.FetchRsFavouritesUseCase>(),
      gh<_i889.FetchFavouriteProductsUseCase>(),
      gh<_i365.ToggleRestaurantFavouriteUseCase>(),
      gh<_i973.ToggleProductFavouriteUseCase>(),
    ),
  );
  gh.factory<_i305.OrdersBloc>(
    () => _i305.OrdersBloc(
      gh<_i250.FetchOrdersUseCase>(),
      gh<_i382.FetchCleaningOrdersUseCase>(),
      gh<_i172.CancelCleaningOrderUseCase>(),
      gh<_i335.FetchRestaurantCartUseCase>(),
      gh<_i953.FetchStoreCartUseCase>(),
      gh<_i925.UpdateCartItemQuantityUseCase>(),
      gh<_i190.UpdateStoreCartItemQuantityUseCase>(),
      gh<_i242.DeleteCartItemUseCase>(),
      gh<_i29.DeleteStoreCartItemUseCase>(),
      gh<_i576.CheckRestaurantCouponUseCase>(),
      gh<_i109.PlaceRestaurantOrderUseCase>(),
      gh<_i969.PlaceStoreOrderUseCase>(),
    ),
  );
  gh.lazySingleton<_i745.AddRestaurantCartItemUseCase>(
    () => _i745.AddRestaurantCartItemUseCase(
      rsDiscoverRepo: gh<_i622.RsDiscoverRepo>(),
    ),
  );
  gh.lazySingleton<_i303.FetchDiscoverRestaurantsUseCase>(
    () => _i303.FetchDiscoverRestaurantsUseCase(
      rsDiscoverRepo: gh<_i622.RsDiscoverRepo>(),
    ),
  );
  gh.lazySingleton<_i716.FetchRestaurantCartProductsCountUseCase>(
    () => _i716.FetchRestaurantCartProductsCountUseCase(
      rsDiscoverRepo: gh<_i622.RsDiscoverRepo>(),
    ),
  );
  gh.lazySingleton<_i112.FetchRestaurantDetailsUseCase>(
    () => _i112.FetchRestaurantDetailsUseCase(
      rsDiscoverRepo: gh<_i622.RsDiscoverRepo>(),
    ),
  );
  gh.lazySingleton<_i1.FetchRestaurantProductDetailsUseCase>(
    () => _i1.FetchRestaurantProductDetailsUseCase(
      rsDiscoverRepo: gh<_i622.RsDiscoverRepo>(),
    ),
  );
  gh.lazySingleton<_i620.CreateCleaningOrderUseCase>(
    () => _i620.CreateCleaningOrderUseCase(clMainRepo: gh<_i342.ClMainRepo>()),
  );
  gh.lazySingleton<_i762.EstimateCleaningPriceUseCase>(
    () =>
        _i762.EstimateCleaningPriceUseCase(clMainRepo: gh<_i342.ClMainRepo>()),
  );
  gh.lazySingleton<_i750.GetCleaningBannersUseCase>(
    () => _i750.GetCleaningBannersUseCase(clMainRepo: gh<_i342.ClMainRepo>()),
  );
  gh.lazySingleton<_i895.GetCleaningServicesUseCase>(
    () => _i895.GetCleaningServicesUseCase(clMainRepo: gh<_i342.ClMainRepo>()),
  );
  gh.lazySingleton<_i491.GetPreviousCleaningWorkersUseCase>(
    () => _i491.GetPreviousCleaningWorkersUseCase(
      clMainRepo: gh<_i342.ClMainRepo>(),
    ),
  );
  gh.factory<_i531.SmFavoriteBloc>(
    () => _i531.SmFavoriteBloc(
      gh<_i1051.GetFavoriteSupermarketStoresUseCase>(),
      gh<_i163.GetFavoriteSupermarketProductsUseCase>(),
    ),
  );
  gh.lazySingleton<_i555.FetchFeaturedOffersUseCase>(
    () => _i555.FetchFeaturedOffersUseCase(rsHome: gh<_i117.RsHomeRepo>()),
  );
  gh.lazySingleton<_i238.FetchNearByStoresUseCase>(
    () => _i238.FetchNearByStoresUseCase(rsHome: gh<_i117.RsHomeRepo>()),
  );
  gh.lazySingleton<_i181.FetchStoresUseCase>(
    () => _i181.FetchStoresUseCase(rsHome: gh<_i117.RsHomeRepo>()),
  );
  gh.factory<_i391.RsOffersBloc>(
    () => _i391.RsOffersBloc(gh<_i317.FetchRsOffersProductsUseCase>()),
  );
  gh.lazySingleton<_i89.FetchRestaurantHomeCategoriesUseCase>(
    () => _i89.FetchRestaurantHomeCategoriesUseCase(
      rsHomeRepo: gh<_i117.RsHomeRepo>(),
    ),
  );
  gh.lazySingleton<_i892.FetchRestaurantHomeCategoryProductsUseCase>(
    () => _i892.FetchRestaurantHomeCategoryProductsUseCase(
      rsHomeRepo: gh<_i117.RsHomeRepo>(),
    ),
  );
  gh.lazySingleton<_i1047.FetchRestaurantHomeExclusiveOffersUseCase>(
    () => _i1047.FetchRestaurantHomeExclusiveOffersUseCase(
      rsHomeRepo: gh<_i117.RsHomeRepo>(),
    ),
  );
  gh.lazySingleton<_i171.FetchRestaurantHomeLatestOrderedProductsUseCase>(
    () => _i171.FetchRestaurantHomeLatestOrderedProductsUseCase(
      rsHomeRepo: gh<_i117.RsHomeRepo>(),
    ),
  );
  gh.lazySingleton<_i967.FetchRestaurantHomeNearestRestaurantsUseCase>(
    () => _i967.FetchRestaurantHomeNearestRestaurantsUseCase(
      rsHomeRepo: gh<_i117.RsHomeRepo>(),
    ),
  );
  gh.lazySingleton<_i339.FetchRestaurantHomeSuggestedProductsUseCase>(
    () => _i339.FetchRestaurantHomeSuggestedProductsUseCase(
      rsHomeRepo: gh<_i117.RsHomeRepo>(),
    ),
  );
  gh.lazySingleton<_i373.ReorderLatestOrderedProductUseCase>(
    () => _i373.ReorderLatestOrderedProductUseCase(
      rsHomeRepo: gh<_i117.RsHomeRepo>(),
    ),
  );
  gh.lazySingleton<_i761.AddFavoriteRestaurantUseCase>(
    () => _i761.AddFavoriteRestaurantUseCase(
      profileRepo: gh<_i275.ProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i1062.AddGroupOrderItemUseCase>(
    () => _i1062.AddGroupOrderItemUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i592.CancelGroupOrderUseCase>(
    () => _i592.CancelGroupOrderUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i687.CreateAddressUseCase>(
    () => _i687.CreateAddressUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i77.CreateGroupOrderUseCase>(
    () => _i77.CreateGroupOrderUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i679.CreateVoteUseCase>(
    () => _i679.CreateVoteUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i39.DeleteAddressUseCase>(
    () => _i39.DeleteAddressUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i617.DeleteGroupOrderItemUseCase>(
    () =>
        _i617.DeleteGroupOrderItemUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i875.EndVoteUseCase>(
    () => _i875.EndVoteUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i194.FetchActiveGroupOrdersUseCase>(
    () => _i194.FetchActiveGroupOrdersUseCase(
      profileRepo: gh<_i275.ProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i808.FetchActiveVotesUseCase>(
    () => _i808.FetchActiveVotesUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i376.FetchAddressesUseCase>(
    () => _i376.FetchAddressesUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i879.FetchCouponsUseCase>(
    () => _i879.FetchCouponsUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i319.FetchFavoriteRestaurantsUseCase>(
    () => _i319.FetchFavoriteRestaurantsUseCase(
      profileRepo: gh<_i275.ProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i666.FetchGroupOrderMenuSectionsUseCase>(
    () => _i666.FetchGroupOrderMenuSectionsUseCase(
      profileRepo: gh<_i275.ProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i866.FetchLuckBoxOptionsUseCase>(
    () =>
        _i866.FetchLuckBoxOptionsUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i438.FetchNotificationsUseCase>(
    () => _i438.FetchNotificationsUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i381.FetchVoteSuggestionsUseCase>(
    () =>
        _i381.FetchVoteSuggestionsUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i461.JoinGroupOrderUseCase>(
    () => _i461.JoinGroupOrderUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i10.MarkAllNotificationsReadUseCase>(
    () => _i10.MarkAllNotificationsReadUseCase(
      profileRepo: gh<_i275.ProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i338.MarkNotificationReadUseCase>(
    () =>
        _i338.MarkNotificationReadUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i342.PlaceGroupOrderUseCase>(
    () => _i342.PlaceGroupOrderUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i999.RemoveFavoriteRestaurantUseCase>(
    () => _i999.RemoveFavoriteRestaurantUseCase(
      profileRepo: gh<_i275.ProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i662.ShowGroupOrderUseCase>(
    () => _i662.ShowGroupOrderUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i320.ShowVoteUseCase>(
    () => _i320.ShowVoteUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i467.SubmitGroupOrderUseCase>(
    () => _i467.SubmitGroupOrderUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i529.SubmitVoteBallotUseCase>(
    () => _i529.SubmitVoteBallotUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i89.SuggestLuckBoxUseCase>(
    () => _i89.SuggestLuckBoxUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i567.UnsubmitGroupOrderUseCase>(
    () => _i567.UnsubmitGroupOrderUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i591.UpdateAccountPasswordUseCase>(
    () => _i591.UpdateAccountPasswordUseCase(
      profileRepo: gh<_i275.ProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i178.UpdateAccountUseCase>(
    () => _i178.UpdateAccountUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i983.UpdateAddressUseCase>(
    () => _i983.UpdateAddressUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i1008.UpdateGroupOrderItemUseCase>(
    () => _i1008.UpdateGroupOrderItemUseCase(
      profileRepo: gh<_i275.ProfileRepo>(),
    ),
  );
  gh.factory<_i883.SmStoresBloc>(
    () => _i883.SmStoresBloc(
      gh<_i151.GetSupermarketStoreDetailsUseCase>(),
      gh<_i749.GetSupermarketProductDetailsUseCase>(),
      gh<_i802.GetCompareProductsUseCase>(),
      gh<_i431.AddSupermarketCartItemUseCase>(),
      gh<_i524.FetchShoppingListsUseCase>(),
    ),
  );
  gh.factory<_i1049.RestaurantOrderCheckoutCubit>(
    () => _i1049.RestaurantOrderCheckoutCubit(
      gh<_i438.FetchOrderDetailsUseCase>(),
      gh<_i925.UpdateCartItemQuantityUseCase>(),
      gh<_i242.DeleteCartItemUseCase>(),
      gh<_i576.CheckRestaurantCouponUseCase>(),
    ),
  );
  gh.factory<_i821.ProfileBloc>(
    () => _i821.ProfileBloc(
      gh<_i376.FetchAddressesUseCase>(),
      gh<_i262.SetDefaultAddressUseCase>(),
      gh<_i438.FetchNotificationsUseCase>(),
      gh<_i10.MarkAllNotificationsReadUseCase>(),
      gh<_i338.MarkNotificationReadUseCase>(),
      gh<_i319.FetchFavoriteRestaurantsUseCase>(),
      gh<_i999.RemoveFavoriteRestaurantUseCase>(),
      gh<_i679.CreateVoteUseCase>(),
      gh<_i381.FetchVoteSuggestionsUseCase>(),
      gh<_i687.CreateAddressUseCase>(),
      gh<_i983.UpdateAddressUseCase>(),
      gh<_i39.DeleteAddressUseCase>(),
      gh<_i320.ShowVoteUseCase>(),
      gh<_i529.SubmitVoteBallotUseCase>(),
      gh<_i875.EndVoteUseCase>(),
      gh<_i808.FetchActiveVotesUseCase>(),
      gh<_i303.FetchDiscoverRestaurantsUseCase>(),
      gh<_i666.FetchGroupOrderMenuSectionsUseCase>(),
      gh<_i77.CreateGroupOrderUseCase>(),
      gh<_i461.JoinGroupOrderUseCase>(),
      gh<_i194.FetchActiveGroupOrdersUseCase>(),
      gh<_i662.ShowGroupOrderUseCase>(),
      gh<_i1062.AddGroupOrderItemUseCase>(),
      gh<_i1008.UpdateGroupOrderItemUseCase>(),
      gh<_i617.DeleteGroupOrderItemUseCase>(),
      gh<_i467.SubmitGroupOrderUseCase>(),
      gh<_i567.UnsubmitGroupOrderUseCase>(),
      gh<_i592.CancelGroupOrderUseCase>(),
      gh<_i342.PlaceGroupOrderUseCase>(),
      gh<_i877.GetShoppingListUseCase>(),
      gh<_i11.FetchShoppingListDetailUseCase>(),
      gh<_i614.CreateShoppingListUseCase>(),
      gh<_i901.UpdateShoppingListUseCase>(),
      gh<_i170.UpdateShoppingListItemUseCase>(),
      gh<_i12.DeleteShoppingListItemUseCase>(),
      gh<_i992.AddShoppingListToCartUseCase>(),
    ),
  );
  gh.lazySingleton<_i37.LoginUseCase>(
    () => _i37.LoginUseCase(authRepo: gh<_i976.AuthRepo>()),
  );
  gh.lazySingleton<_i97.RegisterUseCase>(
    () => _i97.RegisterUseCase(authRepo: gh<_i976.AuthRepo>()),
  );
  gh.factory<_i589.RsDiscoverBloc>(
    () => _i589.RsDiscoverBloc(
      gh<_i303.FetchDiscoverRestaurantsUseCase>(),
      gh<_i1.FetchRestaurantProductDetailsUseCase>(),
      gh<_i426.UserLocationService>(),
      fetchRestaurantProductsSearchUseCase:
          gh<_i526.FetchRestaurantProductsSearchUseCase>(),
    ),
  );
  gh.factory<_i362.ClMainBloc>(
    () => _i362.ClMainBloc(
      estimateCleaningPriceUseCase: gh<_i762.EstimateCleaningPriceUseCase>(),
      getCleaningServicesUseCase: gh<_i895.GetCleaningServicesUseCase>(),
      getPreviousCleaningWorkersUseCase:
          gh<_i491.GetPreviousCleaningWorkersUseCase>(),
      createCleaningOrderUseCase: gh<_i620.CreateCleaningOrderUseCase>(),
    ),
  );
  gh.factory<_i836.RsHomeBloc>(
    () => _i836.RsHomeBloc(
      gh<_i181.FetchStoresUseCase>(),
      gh<_i238.FetchNearByStoresUseCase>(),
      gh<_i555.FetchFeaturedOffersUseCase>(),
      gh<_i89.FetchRestaurantHomeCategoriesUseCase>(),
      gh<_i1047.FetchRestaurantHomeExclusiveOffersUseCase>(),
      gh<_i339.FetchRestaurantHomeSuggestedProductsUseCase>(),
      gh<_i967.FetchRestaurantHomeNearestRestaurantsUseCase>(),
      gh<_i171.FetchRestaurantHomeLatestOrderedProductsUseCase>(),
      gh<_i373.ReorderLatestOrderedProductUseCase>(),
      gh<_i892.FetchRestaurantHomeCategoryProductsUseCase>(),
    ),
  );
  gh.factory<_i849.LuckyBoxCubit>(
    () => _i849.LuckyBoxCubit(
      fetchLuckBoxOptionsUseCase: gh<_i866.FetchLuckBoxOptionsUseCase>(),
      suggestLuckBoxUseCase: gh<_i89.SuggestLuckBoxUseCase>(),
    ),
  );
  gh.factory<_i767.CouponsCubit>(
    () => _i767.CouponsCubit(
      fetchCouponsUseCase: gh<_i879.FetchCouponsUseCase>(),
    ),
  );
  gh.factory<_i958.AuthBloc>(
    () => _i958.AuthBloc(
      loginUseCase: gh<_i37.LoginUseCase>(),
      registerUseCase: gh<_i97.RegisterUseCase>(),
    ),
  );
  return getIt;
}

class _$InjectableModule extends _i464.InjectableModule {}
