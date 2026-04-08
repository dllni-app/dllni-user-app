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
import '../../features/auth/view/manager/bloc/auth_bloc.dart' as _i958;
import '../../features/home/data/repository/home_repo_impl.dart' as _i1013;
import '../../features/home/data/source/home_remote_data_source.dart' as _i557;
import '../../features/home/domain/repository/home_repo.dart' as _i396;
import '../../features/home/view/manager/bloc/home_bloc.dart' as _i648;
import '../../features/orders/data/repository/orders_repo_impl.dart' as _i849;
import '../../features/orders/data/source/orders_remote_data_source.dart'
    as _i702;
import '../../features/orders/domain/repository/orders_repo.dart' as _i132;
import '../../features/orders/view/manager/bloc/orders_bloc.dart' as _i305;
import '../../features/profile/data/repository/profile_repo_impl.dart' as _i265;
import '../../features/profile/data/source/profile_remote_data_source.dart'
    as _i502;
import '../../features/profile/domain/repository/profile_repo.dart' as _i275;
import '../../features/profile/domain/services/user_location_service.dart'
    as _i426;
import '../../features/profile/domain/usecases/add_favorite_restaurant_use_case.dart'
    as _i761;
import '../../features/profile/domain/usecases/create_address_use_case.dart'
    as _i687;
import '../../features/profile/domain/usecases/create_vote_use_case.dart'
    as _i679;
import '../../features/profile/domain/usecases/delete_address_use_case.dart'
    as _i39;
import '../../features/profile/domain/usecases/end_vote_use_case.dart' as _i875;
import '../../features/profile/domain/usecases/fetch_addresses_use_case.dart'
    as _i376;
import '../../features/profile/domain/usecases/fetch_active_votes_use_case.dart'
    as _i200;
import '../../features/profile/domain/usecases/fetch_coupons_use_case.dart'
    as _i879;
import '../../features/profile/domain/usecases/fetch_favorite_restaurants_use_case.dart'
    as _i319;
import '../../features/profile/domain/usecases/fetch_luck_box_options_use_case.dart'
    as _i866;
import '../../features/profile/domain/usecases/fetch_notifications_use_case.dart'
    as _i438;
import '../../features/profile/domain/usecases/fetch_vote_suggestions_use_case.dart'
    as _i381;
import '../../features/profile/domain/usecases/remove_favorite_restaurant_use_case.dart'
    as _i999;
import '../../features/profile/domain/usecases/set_default_address_use_case.dart'
    as _i262;
import '../../features/profile/domain/usecases/show_vote_use_case.dart'
    as _i320;
import '../../features/profile/domain/usecases/suggest_luck_box_use_case.dart'
    as _i89;
import '../../features/profile/domain/usecases/update_address_use_case.dart'
    as _i983;
import '../../features/profile/domain/usecases/update_account_use_case.dart'
    as _i544;
import '../../features/profile/domain/usecases/update_account_password_use_case.dart'
    as _i545;
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
import '../../features/rs_main/data/source/rs_main_remote_data_source.dart'
    as _i1070;
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
import 'injection.dart' as _i464;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final injectableModule = _$InjectableModule();
  gh.factory<_i648.HomeBloc>(() => _i648.HomeBloc());
  gh.factory<_i305.OrdersBloc>(() => _i305.OrdersBloc());
  gh.factory<_i752.RsMainBloc>(() => _i752.RsMainBloc());
  gh.singleton<_i960.DioNetwork>(() => injectableModule.dio);
  gh.lazySingleton<_i557.HomeRemoteDataSource>(
    () => _i557.HomeRemoteDataSource(),
  );
  gh.lazySingleton<_i702.OrdersRemoteDataSource>(
    () => _i702.OrdersRemoteDataSource(),
  );
  gh.lazySingleton<_i426.UserLocationService>(
    () => _i426.UserLocationService(),
  );
  gh.lazySingleton<_i1070.RsMainRemoteDataSource>(
    () => _i1070.RsMainRemoteDataSource(),
  );
  gh.lazySingleton<_i132.OrdersRepo>(() => _i849.OrdersRepoImpl());
  gh.lazySingleton<_i908.RsOffersRemoteDataSource>(
    () => _i908.RsOffersRemoteDataSource(dioNetwork: gh<_i497.DioNetwork>()),
  );
  gh.lazySingleton<_i396.HomeRepo>(() => _i1013.HomeRepoImpl());
  gh.lazySingleton<_i744.RsMainRepo>(() => _i427.RsMainRepoImpl());
  gh.lazySingleton<_i777.AuthRemoteDataSource>(
    () => _i777.AuthRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i502.ProfileRemoteDataSource>(
    () => _i502.ProfileRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
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
  gh.lazySingleton<_i75.RsOffersRepo>(
    () => _i673.RsOffersRepoImpl(
      rsOffersRemoteDataSource: gh<_i908.RsOffersRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i865.RsFavouriteRepo>(
    () => _i489.RsFavouriteRepoImpl(
      rsFavouriteRemoteDataSource: gh<_i206.RsFavouriteRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i622.RsDiscoverRepo>(
    () => _i992.RsDiscoverRepoImpl(
      rsDiscoverRemoteDataSource: gh<_i341.RsDiscoverRemoteDataSource>(),
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
  gh.lazySingleton<_i976.AuthRepo>(
    () => _i751.AuthRepoImpl(
      authRemoteDataSource: gh<_i777.AuthRemoteDataSource>(),
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
  gh.lazySingleton<_i687.CreateAddressUseCase>(
    () => _i687.CreateAddressUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i679.CreateVoteUseCase>(
    () => _i679.CreateVoteUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i39.DeleteAddressUseCase>(
    () => _i39.DeleteAddressUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i875.EndVoteUseCase>(
    () => _i875.EndVoteUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i376.FetchAddressesUseCase>(
    () => _i376.FetchAddressesUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i200.FetchActiveVotesUseCase>(
    () => _i200.FetchActiveVotesUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i879.FetchCouponsUseCase>(
    () => _i879.FetchCouponsUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i319.FetchFavoriteRestaurantsUseCase>(
    () => _i319.FetchFavoriteRestaurantsUseCase(
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
  gh.lazySingleton<_i999.RemoveFavoriteRestaurantUseCase>(
    () => _i999.RemoveFavoriteRestaurantUseCase(
      profileRepo: gh<_i275.ProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i320.ShowVoteUseCase>(
    () => _i320.ShowVoteUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i89.SuggestLuckBoxUseCase>(
    () => _i89.SuggestLuckBoxUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i983.UpdateAddressUseCase>(
    () => _i983.UpdateAddressUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i544.UpdateAccountUseCase>(
    () => _i544.UpdateAccountUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i545.UpdateAccountPasswordUseCase>(
    () => _i545.UpdateAccountPasswordUseCase(
      profileRepo: gh<_i275.ProfileRepo>(),
    ),
  );
  gh.factory<_i589.RsDiscoverBloc>(
    () => _i589.RsDiscoverBloc(
      gh<_i303.FetchDiscoverRestaurantsUseCase>(),
      gh<_i1.FetchRestaurantProductDetailsUseCase>(),
    ),
  );
  gh.lazySingleton<_i37.LoginUseCase>(
    () => _i37.LoginUseCase(authRepo: gh<_i976.AuthRepo>()),
  );
  gh.factory<_i821.ProfileBloc>(
    () => _i821.ProfileBloc(
      gh<_i376.FetchAddressesUseCase>(),
      gh<_i262.SetDefaultAddressUseCase>(),
      gh<_i438.FetchNotificationsUseCase>(),
      gh<_i319.FetchFavoriteRestaurantsUseCase>(),
      gh<_i999.RemoveFavoriteRestaurantUseCase>(),
      gh<_i679.CreateVoteUseCase>(),
      gh<_i381.FetchVoteSuggestionsUseCase>(),
      gh<_i687.CreateAddressUseCase>(),
      gh<_i983.UpdateAddressUseCase>(),
      gh<_i39.DeleteAddressUseCase>(),
      gh<_i320.ShowVoteUseCase>(),
      gh<_i875.EndVoteUseCase>(),
      gh<_i200.FetchActiveVotesUseCase>(),
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
    () => _i958.AuthBloc(loginUseCase: gh<_i37.LoginUseCase>()),
  );
  return getIt;
}

class _$InjectableModule extends _i464.InjectableModule {}
