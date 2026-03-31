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
import '../../features/sm_discover/view/manager/bloc/sm_discover_bloc.dart'
    as _i717;
import '../../features/sm_home/data/repository/sm_home_repo_impl.dart' as _i991;
import '../../features/sm_home/data/source/sm_home_remote_data_source.dart'
    as _i1025;
import '../../features/sm_home/domain/repository/sm_home_repo.dart' as _i267;
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
import '../../features/sm_profile/data/repository/sm_profile_repo_impl.dart'
    as _i489;
import '../../features/sm_profile/data/source/sm_profile_remote_data_source.dart'
    as _i1065;
import '../../features/sm_profile/domain/repository/sm_profile_repo.dart'
    as _i130;
import '../../features/sm_profile/view/manager/bloc/sm_profile_bloc.dart'
    as _i602;
import '../../features/sm_stores/data/repository/sm_stores_repo_impl.dart'
    as _i580;
import '../../features/sm_stores/data/source/sm_stores_remote_data_source.dart'
    as _i179;
import '../../features/sm_stores/domain/repository/sm_stores_repo.dart'
    as _i359;
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
  gh.factory<_i717.SmDiscoverBloc>(() => _i717.SmDiscoverBloc());
  gh.factory<_i626.SmHomeBloc>(() => _i626.SmHomeBloc());
  gh.factory<_i709.SmOffersBloc>(() => _i709.SmOffersBloc());
  gh.factory<_i803.SmOrdersBloc>(() => _i803.SmOrdersBloc());
  gh.factory<_i602.SmProfileBloc>(() => _i602.SmProfileBloc());
  gh.factory<_i883.SmStoresBloc>(() => _i883.SmStoresBloc());
  gh.singleton<_i960.DioNetwork>(() => injectableModule.dio);
  gh.lazySingleton<_i369.SmCartRemoteDataSource>(
    () => _i369.SmCartRemoteDataSource(),
  );
  gh.lazySingleton<_i949.SmDiscoverRemoteDataSource>(
    () => _i949.SmDiscoverRemoteDataSource(),
  );
  gh.lazySingleton<_i1025.SmHomeRemoteDataSource>(
    () => _i1025.SmHomeRemoteDataSource(),
  );
  gh.lazySingleton<_i875.SmOffersRemoteDataSource>(
    () => _i875.SmOffersRemoteDataSource(),
  );
  gh.lazySingleton<_i400.SmOrdersRemoteDataSource>(
    () => _i400.SmOrdersRemoteDataSource(),
  );
  gh.lazySingleton<_i1065.SmProfileRemoteDataSource>(
    () => _i1065.SmProfileRemoteDataSource(),
  );
  gh.lazySingleton<_i179.SmStoresRemoteDataSource>(
    () => _i179.SmStoresRemoteDataSource(),
  );
  gh.lazySingleton<_i130.SmProfileRepo>(() => _i489.SmProfileRepoImpl());
  gh.lazySingleton<_i267.SmHomeRepo>(() => _i991.SmHomeRepoImpl());
  gh.lazySingleton<_i359.SmStoresRepo>(() => _i580.SmStoresRepoImpl());
  gh.lazySingleton<_i579.SmCartRepo>(() => _i91.SmCartRepoImpl());
  gh.lazySingleton<_i777.AuthRemoteDataSource>(
    () => _i777.AuthRemoteDataSource(dioNetwork: gh<_i497.DioNetwork>()),
  );
  gh.lazySingleton<_i446.SmOffersRepo>(() => _i213.SmOffersRepoImpl());
  gh.lazySingleton<_i880.SmDiscoverRepo>(() => _i43.SmDiscoverRepoImpl());
  gh.lazySingleton<_i753.SmOrdersRepo>(() => _i290.SmOrdersRepoImpl());
  gh.lazySingleton<_i976.AuthRepo>(
    () => _i751.AuthRepoImpl(
      authRemoteDataSource: gh<_i777.AuthRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i37.LoginUseCase>(
    () => _i37.LoginUseCase(auth: gh<_i976.AuthRepo>()),
  );
  gh.factory<_i958.AuthBloc>(() => _i958.AuthBloc(gh<_i37.LoginUseCase>()));
  return getIt;
}

class _$InjectableModule extends _i464.InjectableModule {}
