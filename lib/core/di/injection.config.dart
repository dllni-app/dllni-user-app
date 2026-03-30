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

import '../../features/rs_discover/data/repository/rs_discover_repo_impl.dart'
    as _i992;
import '../../features/rs_discover/data/source/rs_discover_remote_data_source.dart'
    as _i341;
import '../../features/rs_discover/domain/repository/rs_discover_repo.dart'
    as _i622;
import '../../features/rs_discover/view/manager/bloc/rs_discover_bloc.dart'
    as _i589;
import '../../features/rs_home/data/repository/rs_home_repo_impl.dart' as _i500;
import '../../features/rs_home/data/source/rs_home_remote_data_source.dart'
    as _i165;
import '../../features/rs_home/domain/repository/rs_home_repo.dart' as _i117;
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
import '../../features/rs_orders/view/manager/bloc/rs_orders_bloc.dart'
    as _i761;
import '../../features/rs_profile/data/repository/rs_profile_repo_impl.dart'
    as _i793;
import '../../features/rs_profile/data/source/rs_profile_remote_data_source.dart'
    as _i562;
import '../../features/rs_profile/domain/repository/rs_profile_repo.dart'
    as _i611;
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
  gh.factory<_i589.RsDiscoverBloc>(() => _i589.RsDiscoverBloc());
  gh.factory<_i836.RsHomeBloc>(() => _i836.RsHomeBloc());
  gh.factory<_i752.RsMainBloc>(() => _i752.RsMainBloc());
  gh.factory<_i391.RsOffersBloc>(() => _i391.RsOffersBloc());
  gh.factory<_i761.RsOrdersBloc>(() => _i761.RsOrdersBloc());
  gh.factory<_i637.RsProfileBloc>(() => _i637.RsProfileBloc());
  gh.singleton<_i960.DioNetwork>(() => injectableModule.dio);
  gh.lazySingleton<_i341.RsDiscoverRemoteDataSource>(
    () => _i341.RsDiscoverRemoteDataSource(),
  );
  gh.lazySingleton<_i165.RsHomeRemoteDataSource>(
    () => _i165.RsHomeRemoteDataSource(),
  );
  gh.lazySingleton<_i1070.RsMainRemoteDataSource>(
    () => _i1070.RsMainRemoteDataSource(),
  );
  gh.lazySingleton<_i908.RsOffersRemoteDataSource>(
    () => _i908.RsOffersRemoteDataSource(),
  );
  gh.lazySingleton<_i761.RsOrdersRemoteDataSource>(
    () => _i761.RsOrdersRemoteDataSource(),
  );
  gh.lazySingleton<_i562.RsProfileRemoteDataSource>(
    () => _i562.RsProfileRemoteDataSource(),
  );
  gh.lazySingleton<_i75.RsOffersRepo>(() => _i673.RsOffersRepoImpl());
  gh.lazySingleton<_i611.RsProfileRepo>(() => _i793.RsProfileRepoImpl());
  gh.lazySingleton<_i622.RsDiscoverRepo>(() => _i992.RsDiscoverRepoImpl());
  gh.lazySingleton<_i117.RsHomeRepo>(() => _i500.RsHomeRepoImpl());
  gh.lazySingleton<_i623.RsOrdersRepo>(() => _i879.RsOrdersRepoImpl());
  gh.lazySingleton<_i744.RsMainRepo>(() => _i427.RsMainRepoImpl());
  return getIt;
}

class _$InjectableModule extends _i464.InjectableModule {}
