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

import '../../features/cl_main/data/repository/cl_main_repo_impl.dart' as _i466;
import '../../features/cl_main/data/source/cl_main_remote_data_source.dart'
    as _i817;
import '../../features/cl_main/domain/repository/cl_main_repo.dart' as _i342;
import '../../features/cl_main/domain/usecases/create_cleaning_order_use_case.dart'
    as _i620;
import '../../features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart'
    as _i762;
import '../../features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart'
    as _i491;
import '../../features/cl_main/view/manager/bloc/cl_main_bloc.dart' as _i362;
import 'injection.dart' as _i464;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final injectableModule = _$InjectableModule();
  gh.singleton<_i960.DioNetwork>(() => injectableModule.dio);
  gh.lazySingleton<_i817.ClMainRemoteDataSource>(
    () => _i817.ClMainRemoteDataSource(dioNetwork: gh<_i497.DioNetwork>()),
  );
  gh.lazySingleton<_i342.ClMainRepo>(
    () => _i466.ClMainRepoImpl(
      clMainRemoteDataSource: gh<_i817.ClMainRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i620.CreateCleaningOrderUseCase>(
    () => _i620.CreateCleaningOrderUseCase(clMainRepo: gh<_i342.ClMainRepo>()),
  );
  gh.lazySingleton<_i762.EstimateCleaningPriceUseCase>(
    () =>
        _i762.EstimateCleaningPriceUseCase(clMainRepo: gh<_i342.ClMainRepo>()),
  );
  gh.lazySingleton<_i491.GetPreviousCleaningWorkersUseCase>(
    () => _i491.GetPreviousCleaningWorkersUseCase(
      clMainRepo: gh<_i342.ClMainRepo>(),
    ),
  );
  gh.factory<_i362.ClMainBloc>(
    () => _i362.ClMainBloc(
      estimateCleaningPriceUseCase: gh<_i762.EstimateCleaningPriceUseCase>(),
      getPreviousCleaningWorkersUseCase:
          gh<_i491.GetPreviousCleaningWorkersUseCase>(),
      createCleaningOrderUseCase: gh<_i620.CreateCleaningOrderUseCase>(),
    ),
  );
  return getIt;
}

class _$InjectableModule extends _i464.InjectableModule {}
