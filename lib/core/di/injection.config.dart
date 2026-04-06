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

import '../../features/home/data/repository/home_repo_impl.dart' as _i1013;
import '../../features/home/data/source/home_remote_data_source.dart' as _i557;
import '../../features/home/domain/repository/home_repo.dart' as _i396;
import '../../features/home/view/manager/bloc/home_bloc.dart' as _i648;
import '../../features/main/data/repository/main_repo_impl.dart' as _i959;
import '../../features/main/data/source/main_remote_data_source.dart' as _i931;
import '../../features/main/domain/repository/main_repo.dart' as _i540;
import '../../features/main/view/manager/bloc/main_bloc.dart' as _i98;
import '../../features/orders/data/repository/orders_repo_impl.dart' as _i849;
import '../../features/orders/data/source/orders_remote_data_source.dart'
    as _i702;
import '../../features/orders/domain/repository/orders_repo.dart' as _i132;
import '../../features/orders/view/manager/bloc/orders_bloc.dart' as _i305;
import '../../features/profile/data/repository/profile_repo_impl.dart' as _i265;
import '../../features/profile/data/source/profile_remote_data_source.dart'
    as _i502;
import '../../features/profile/domain/repository/profile_repo.dart' as _i275;
import '../../features/profile/domain/usecases/add_favorite_restaurant_use_case.dart'
    as _i761;
import '../../features/profile/domain/usecases/create_vote_use_case.dart'
    as _i679;
import '../../features/profile/domain/usecases/end_vote_use_case.dart' as _i875;
import '../../features/profile/domain/usecases/fetch_addresses_use_case.dart'
    as _i376;
import '../../features/profile/domain/usecases/fetch_favorite_restaurants_use_case.dart'
    as _i319;
import '../../features/profile/domain/usecases/fetch_notifications_use_case.dart'
    as _i438;
import '../../features/profile/domain/usecases/remove_favorite_restaurant_use_case.dart'
    as _i999;
import '../../features/profile/domain/usecases/set_default_address_use_case.dart'
    as _i262;
import '../../features/profile/domain/usecases/show_vote_use_case.dart'
    as _i320;
import '../../features/profile/view/manager/bloc/profile_bloc.dart' as _i821;
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
  gh.factory<_i98.MainBloc>(() => _i98.MainBloc());
  gh.factory<_i305.OrdersBloc>(() => _i305.OrdersBloc());
  gh.singleton<_i960.DioNetwork>(() => injectableModule.dio);
  gh.lazySingleton<_i557.HomeRemoteDataSource>(
    () => _i557.HomeRemoteDataSource(),
  );
  gh.lazySingleton<_i931.MainRemoteDataSource>(
    () => _i931.MainRemoteDataSource(),
  );
  gh.lazySingleton<_i702.OrdersRemoteDataSource>(
    () => _i702.OrdersRemoteDataSource(),
  );
  gh.lazySingleton<_i132.OrdersRepo>(() => _i849.OrdersRepoImpl());
  gh.lazySingleton<_i396.HomeRepo>(() => _i1013.HomeRepoImpl());
  gh.lazySingleton<_i540.MainRepo>(() => _i959.MainRepoImpl());
  gh.lazySingleton<_i502.ProfileRemoteDataSource>(
    () => _i502.ProfileRemoteDataSource(dioNetwork: gh<_i960.DioNetwork>()),
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
  gh.lazySingleton<_i761.AddFavoriteRestaurantUseCase>(
    () => _i761.AddFavoriteRestaurantUseCase(
      profileRepo: gh<_i275.ProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i679.CreateVoteUseCase>(
    () => _i679.CreateVoteUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i875.EndVoteUseCase>(
    () => _i875.EndVoteUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i376.FetchAddressesUseCase>(
    () => _i376.FetchAddressesUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i319.FetchFavoriteRestaurantsUseCase>(
    () => _i319.FetchFavoriteRestaurantsUseCase(
      profileRepo: gh<_i275.ProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i438.FetchNotificationsUseCase>(
    () => _i438.FetchNotificationsUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.lazySingleton<_i999.RemoveFavoriteRestaurantUseCase>(
    () => _i999.RemoveFavoriteRestaurantUseCase(
      profileRepo: gh<_i275.ProfileRepo>(),
    ),
  );
  gh.lazySingleton<_i320.ShowVoteUseCase>(
    () => _i320.ShowVoteUseCase(profileRepo: gh<_i275.ProfileRepo>()),
  );
  gh.factory<_i821.ProfileBloc>(
    () => _i821.ProfileBloc(
      gh<_i376.FetchAddressesUseCase>(),
      gh<_i262.SetDefaultAddressUseCase>(),
      gh<_i438.FetchNotificationsUseCase>(),
      gh<_i319.FetchFavoriteRestaurantsUseCase>(),
      gh<_i999.RemoveFavoriteRestaurantUseCase>(),
      gh<_i679.CreateVoteUseCase>(),
      gh<_i320.ShowVoteUseCase>(),
      gh<_i875.EndVoteUseCase>(),
    ),
  );
  return getIt;
}

class _$InjectableModule extends _i464.InjectableModule {}
