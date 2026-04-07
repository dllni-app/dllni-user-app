import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/cart/cart_products_count_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../app_config.dart';
import '../../features/rs_discover/domain/usecases/fetch_restaurant_cart_products_count_use_case.dart';

import 'injection.config.dart';


final GetIt getIt = GetIt.instance;

@InjectableInit(initializerName: r'$initGetIt', preferRelativeImports: true, asExtension: false)
Future<GetIt> configureInjection() async {
  await SharedPreferencesHelper.init();
  $initGetIt(getIt);
  if (!getIt.isRegistered<FetchRestaurantCartProductsCountUseCase>()) {
    getIt.registerLazySingleton<FetchRestaurantCartProductsCountUseCase>(
      () => FetchRestaurantCartProductsCountUseCase(
        rsDiscoverRepo: getIt(),
      ),
    );
  }
  if (!getIt.isRegistered<CartProductsCountCubit>()) {
    getIt.registerLazySingleton<CartProductsCountCubit>(
      () => CartProductsCountCubit(
        fetchRestaurantCartProductsCountUseCase: getIt(),
      ),
    );
  }
  return getIt;
}

@module
abstract class InjectableModule {
  @singleton
  DioNetwork get dio => DioNetwork(
    baseUrl: AppConfig.baseUrl,
    interceptors: [
      TokenInterceptor(
        tokenKey: 'token',
        fcmKey: 'fcm',
        lang: '',
        onRequestFunction: null,
      ),
    ],
  );
}
