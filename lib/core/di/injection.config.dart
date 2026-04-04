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
import '../../features/rs_discover/data/repository/rs_discover_repo_impl.dart'
    as _i992;
import '../../features/rs_discover/data/source/rs_discover_remote_data_source.dart'
    as _i341;
import '../../features/rs_discover/domain/repository/rs_discover_repo.dart'
    as _i622;
import '../../features/rs_discover/domain/usecases/fetch_discover_restaurants_use_case.dart'
    as _i303;
import '../../features/rs_discover/domain/usecases/fetch_restaurant_details_use_case.dart'
    as _i112;
import '../../features/rs_discover/domain/usecases/fetch_restaurant_product_details_use_case.dart'
    as _i1;
import '../../features/rs_discover/view/manager/bloc/rs_discover_bloc.dart'
    as _i589;
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
import '../../features/rs_offers/view/manager/bloc/rs_offers_bloc.dart'
    as _i391;
import '../../features/rs_orders/data/repository/rs_orders_repo_impl.dart'
    as _i879;
import '../../features/rs_orders/data/source/rs_orders_remote_data_source.dart'
    as _i761;
import '../../features/rs_orders/domain/repository/rs_orders_repo.dart'
    as _i623;
import '../../features/rs_orders/domain/usecases/add_cart_item_use_case.dart'
    as _i466;
import '../../features/rs_orders/domain/usecases/checkout_order_use_case.dart'
    as _i754;
import '../../features/rs_orders/domain/usecases/list_orders_use_case.dart'
    as _i850;
import '../../features/rs_orders/domain/usecases/show_order_use_case.dart'
    as _i538;
import '../../features/rs_orders/view/manager/bloc/rs_orders_bloc.dart'
    as _i761;
import '../../features/rs_profile/data/repository/rs_profile_repo_impl.dart'
    as _i793;
import '../../features/rs_profile/data/source/rs_profile_remote_data_source.dart'
    as _i562;
import '../../features/rs_profile/domain/repository/rs_profile_repo.dart'
    as _i611;
import '../../features/rs_profile/domain/usecases/add_favorite_restaurant_use_case.dart'
    as _i867;
import '../../features/rs_profile/domain/usecases/create_vote_use_case.dart'
    as _i206;
import '../../features/rs_profile/domain/usecases/end_vote_use_case.dart'
    as _i446;
import '../../features/rs_profile/domain/usecases/fetch_addresses_use_case.dart'
    as _i84;
import '../../features/rs_profile/domain/usecases/fetch_favorite_restaurants_use_case.dart'
    as _i431;
import '../../features/rs_profile/domain/usecases/fetch_notifications_use_case.dart'
    as _i353;
import '../../features/rs_profile/domain/usecases/remove_favorite_restaurant_use_case.dart'
    as _i901;
import '../../features/rs_profile/domain/usecases/set_default_address_use_case.dart'
    as _i151;
import '../../features/rs_profile/domain/usecases/show_vote_use_case.dart'
    as _i357;
import '../../features/rs_profile/view/manager/bloc/rs_profile_bloc.dart'
    as _i637;
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
  gh.factory<_i391.RsOffersBloc>(() => _i391.RsOffersBloc());
  gh.singleton<_i960.DioNetwork>(() => injectableModule.dio);
  gh.lazySingleton<_i1070.RsMainRemoteDataSource>(
    () => _i1070.RsMainRemoteDataSource(),
  );
  gh.lazySingleton<_i908.RsOffersRemoteDataSource>(
    () => _i908.RsOffersRemoteDataSource(),
  );
  gh.lazySingleton<_i75.RsOffersRepo>(() => _i673.RsOffersRepoImpl());
  gh.lazySingleton<_i777.AuthRemoteDataSource>(
    () => _i777.AuthRemoteDataSource(dioNetwork: gh<_i497.DioNetwork>()),
  );
  gh.lazySingleton<_i744.RsMainRepo>(() => _i427.RsMainRepoImpl());
  gh.lazySingleton<_i976.AuthRepo>(
    () => _i751.AuthRepoImpl(
      authRemoteDataSource: gh<_i777.AuthRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i341.RsDiscoverRemoteDataSource>(
    () => _i341.RsDiscoverRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i165.RsHomeRemoteDataSource>(
    () => _i165.RsHomeRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i761.RsOrdersRemoteDataSource>(
    () => _i761.RsOrdersRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i562.RsProfileRemoteDataSource>(
    () => _i562.RsProfileRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
  );
  gh.lazySingleton<_i611.RsProfileRepo>(
    () => _i793.RsProfileRepoImpl(
      rsProfileRemoteDataSource: gh<_i562.RsProfileRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i623.RsOrdersRepo>(
    () => _i879.RsOrdersRepoImpl(
      rsOrdersRemoteDataSource: gh<_i761.RsOrdersRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i622.RsDiscoverRepo>(
    () => _i992.RsDiscoverRepoImpl(
      rsDiscoverRemoteDataSource: gh<_i341.RsDiscoverRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i37.LoginUseCase>(
    () => _i37.LoginUseCase(auth: gh<_i976.AuthRepo>()),
  );
  gh.lazySingleton<_i117.RsHomeRepo>(
    () => _i500.RsHomeRepoImpl(
      rsHomeRemoteDataSource: gh<_i165.RsHomeRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i867.AddFavoriteRestaurantUseCase>(
    () => _i867.AddFavoriteRestaurantUseCase(
      rsProfileRepo: gh<_i611.RsProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i206.CreateVoteUseCase>(
    () => _i206.CreateVoteUseCase(rsProfileRepo: gh<_i611.RsProfileRepo>()),
  );
  gh.lazySingleton<_i446.EndVoteUseCase>(
    () => _i446.EndVoteUseCase(rsProfileRepo: gh<_i611.RsProfileRepo>()),
  );
  gh.lazySingleton<_i84.FetchAddressesUseCase>(
    () => _i84.FetchAddressesUseCase(rsProfileRepo: gh<_i611.RsProfileRepo>()),
  );
  gh.lazySingleton<_i431.FetchFavoriteRestaurantsUseCase>(
    () => _i431.FetchFavoriteRestaurantsUseCase(
      rsProfileRepo: gh<_i611.RsProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i353.FetchNotificationsUseCase>(
    () => _i353.FetchNotificationsUseCase(
      rsProfileRepo: gh<_i611.RsProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i901.RemoveFavoriteRestaurantUseCase>(
    () => _i901.RemoveFavoriteRestaurantUseCase(
      rsProfileRepo: gh<_i611.RsProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i151.SetDefaultAddressUseCase>(
    () => _i151.SetDefaultAddressUseCase(
      rsProfileRepo: gh<_i611.RsProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i357.ShowVoteUseCase>(
    () => _i357.ShowVoteUseCase(rsProfileRepo: gh<_i611.RsProfileRepo>()),
  );
  gh.lazySingleton<_i466.AddCartItemUseCase>(
    () => _i466.AddCartItemUseCase(rsOrdersRepo: gh<_i623.RsOrdersRepo>()),
  );
  gh.lazySingleton<_i754.CheckoutOrderUseCase>(
    () => _i754.CheckoutOrderUseCase(rsOrdersRepo: gh<_i623.RsOrdersRepo>()),
  );
  gh.lazySingleton<_i850.ListOrdersUseCase>(
    () => _i850.ListOrdersUseCase(rsOrdersRepo: gh<_i623.RsOrdersRepo>()),
  );
  gh.lazySingleton<_i538.ShowOrderUseCase>(
    () => _i538.ShowOrderUseCase(rsOrdersRepo: gh<_i623.RsOrdersRepo>()),
  );
  gh.lazySingleton<_i303.FetchDiscoverRestaurantsUseCase>(
    () => _i303.FetchDiscoverRestaurantsUseCase(
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
  gh.factory<_i637.RsProfileBloc>(
    () => _i637.RsProfileBloc(
      gh<_i84.FetchAddressesUseCase>(),
      gh<_i151.SetDefaultAddressUseCase>(),
      gh<_i353.FetchNotificationsUseCase>(),
      gh<_i431.FetchFavoriteRestaurantsUseCase>(),
      gh<_i901.RemoveFavoriteRestaurantUseCase>(),
      gh<_i206.CreateVoteUseCase>(),
      gh<_i357.ShowVoteUseCase>(),
      gh<_i446.EndVoteUseCase>(),
    ),
  );
  gh.factory<_i958.AuthBloc>(() => _i958.AuthBloc(gh<_i37.LoginUseCase>()));
  gh.lazySingleton<_i555.FetchFeaturedOffersUseCase>(
    () => _i555.FetchFeaturedOffersUseCase(rsHome: gh<_i117.RsHomeRepo>()),
  );
  gh.lazySingleton<_i238.FetchNearByStoresUseCase>(
    () => _i238.FetchNearByStoresUseCase(rsHome: gh<_i117.RsHomeRepo>()),
  );
  gh.lazySingleton<_i181.FetchStoresUseCase>(
    () => _i181.FetchStoresUseCase(rsHome: gh<_i117.RsHomeRepo>()),
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
  gh.lazySingleton<_i761.RsOrdersBloc>(
    () => _i761.RsOrdersBloc(
      gh<_i850.ListOrdersUseCase>(),
      gh<_i538.ShowOrderUseCase>(),
      gh<_i754.CheckoutOrderUseCase>(),
      gh<_i466.AddCartItemUseCase>(),
    ),
  );
  gh.factory<_i589.RsDiscoverBloc>(
    () => _i589.RsDiscoverBloc(gh<_i303.FetchDiscoverRestaurantsUseCase>()),
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
      gh<_i892.FetchRestaurantHomeCategoryProductsUseCase>(),
    ),
  );
  return getIt;
}

class _$InjectableModule extends _i464.InjectableModule {}
