// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:common_package/common_package.dart' as _i960;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/sm_cart/data/repository/sm_cart_repo_impl.dart' as _i91;
import '../../features/sm_cart/data/source/sm_cart_remote_data_source.dart'
    as _i369;
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
import '../../features/sm_stores/domain/usecases/get_compare_products_use_case.dart'
    as _i802;
import '../../features/sm_stores/domain/usecases/get_supermarket_product_details_use_case.dart'
    as _i749;
import '../../features/sm_stores/domain/usecases/get_supermarket_store_details_use_case.dart'
    as _i151;
import '../../features/sm_stores/view/manager/bloc/sm_stores_bloc.dart'
    as _i883;
import 'injection.dart' as _i464;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final injectableModule = _$InjectableModule();
  gh.factory<_i821.SmCartBloc>(() => _i821.SmCartBloc());
  gh.factory<_i709.SmOffersBloc>(() => _i709.SmOffersBloc());
  gh.factory<_i803.SmOrdersBloc>(() => _i803.SmOrdersBloc());
  gh.singleton<_i960.DioNetwork>(() => injectableModule.dio);
  gh.lazySingleton<_i369.SmCartRemoteDataSource>(
    () => _i369.SmCartRemoteDataSource(),
  );
  gh.lazySingleton<_i875.SmOffersRemoteDataSource>(
    () => _i875.SmOffersRemoteDataSource(),
  );
  gh.lazySingleton<_i400.SmOrdersRemoteDataSource>(
    () => _i400.SmOrdersRemoteDataSource(),
  );
  gh.lazySingleton<_i579.SmCartRepo>(() => _i91.SmCartRepoImpl());
  gh.lazySingleton<_i446.SmOffersRepo>(() => _i213.SmOffersRepoImpl());
  gh.lazySingleton<_i753.SmOrdersRepo>(() => _i290.SmOrdersRepoImpl());
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
  gh.lazySingleton<_i880.SmDiscoverRepo>(
    () => _i43.SmDiscoverRepoImpl(
      smDiscoverRemoteDataSource: gh<_i949.SmDiscoverRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i359.SmStoresRepo>(
    () => _i580.SmStoresRepoImpl(
      smStoresRemoteDataSource: gh<_i179.SmStoresRemoteDataSource>(),
    ),
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
  gh.factory<_i626.SmHomeBloc>(
    () => _i626.SmHomeBloc(
      gh<_i437.GetFeaturedOffersUseCase>(),
      gh<_i690.GetNearbyStoresUseCase>(),
      gh<_i583.ChangeStoreFavoriteUseCase>(),
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
  gh.factory<_i717.SmDiscoverBloc>(
    () => _i717.SmDiscoverBloc(
      gh<_i84.BrowseStoresUseCase>(),
      gh<_i321.BrowseProductsUseCase>(),
      gh<_i327.ChangeStoreFavoriteUseCase>(),
      gh<_i871.ChangeProductFavoriteUseCase>(),
    ),
  );
  gh.factory<_i883.SmStoresBloc>(
    () => _i883.SmStoresBloc(
      gh<_i151.GetSupermarketStoreDetailsUseCase>(),
      gh<_i749.GetSupermarketProductDetailsUseCase>(),
      gh<_i802.GetCompareProductsUseCase>(),
    ),
  );
  gh.factory<_i531.SmFavoriteBloc>(
    () => _i531.SmFavoriteBloc(
      gh<_i1051.GetFavoriteSupermarketStoresUseCase>(),
      gh<_i163.GetFavoriteSupermarketProductsUseCase>(),
    ),
  );
  return getIt;
}

class _$InjectableModule extends _i464.InjectableModule {}
