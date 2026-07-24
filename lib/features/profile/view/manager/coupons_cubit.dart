import 'package:common_package/common_package.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/platform_coupon_models.dart';
import '../../domain/usecases/fetch_coupons_use_case.dart';

class CouponsState {
  final BlocStatus? couponsStatus;
  final List<PlatformCouponModel> coupons;
  final String? errorMessage;

  const CouponsState({
    this.couponsStatus,
    this.coupons = const <PlatformCouponModel>[],
    this.errorMessage,
  });

  CouponsState copyWith({
    BlocStatus? couponsStatus,
    List<PlatformCouponModel>? coupons,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CouponsState(
      couponsStatus: couponsStatus ?? this.couponsStatus,
      coupons: coupons ?? this.coupons,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@injectable
class CouponsCubit extends Cubit<CouponsState> {
  final FetchCouponsUseCase fetchCouponsUseCase;

  CouponsCubit({required this.fetchCouponsUseCase}) : super(const CouponsState());

  Future<void> loadCoupons() async {
    emit(state.copyWith(couponsStatus: BlocStatus.loading, clearErrorMessage: true));
    final res = await fetchCouponsUseCase(NoParams());
    res.fold(
      (failure) => emit(
        state.copyWith(
          couponsStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          couponsStatus: BlocStatus.success,
          coupons: result.coupons.whereType<PlatformCouponModel>().toList(growable: false),
          clearErrorMessage: true,
        ),
      ),
    );
  }
}
