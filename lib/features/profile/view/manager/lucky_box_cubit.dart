import 'package:common_package/common_package.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/luck_box_api_models.dart';
import '../../domain/usecases/fetch_luck_box_options_use_case.dart';
import '../../domain/usecases/suggest_luck_box_use_case.dart';

class LuckyBoxState {
  final BlocStatus? optionsStatus;
  final LuckBoxOptionsModel? options;
  final BlocStatus? suggestStatus;
  final LuckBoxSuggestResponseModel? suggestResult;
  final String? errorMessage;

  const LuckyBoxState({
    this.optionsStatus,
    this.options,
    this.suggestStatus,
    this.suggestResult,
    this.errorMessage,
  });

  LuckyBoxState copyWith({
    BlocStatus? optionsStatus,
    LuckBoxOptionsModel? options,
    BlocStatus? suggestStatus,
    LuckBoxSuggestResponseModel? suggestResult,
    String? errorMessage,
    bool clearSuggestResult = false,
    bool clearErrorMessage = false,
  }) {
    return LuckyBoxState(
      optionsStatus: optionsStatus ?? this.optionsStatus,
      options: options ?? this.options,
      suggestStatus: suggestStatus ?? this.suggestStatus,
      suggestResult: clearSuggestResult ? null : (suggestResult ?? this.suggestResult),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@injectable
class LuckyBoxCubit extends Cubit<LuckyBoxState> {
  final FetchLuckBoxOptionsUseCase fetchLuckBoxOptionsUseCase;
  final SuggestLuckBoxUseCase suggestLuckBoxUseCase;

  LuckyBoxCubit({
    required this.fetchLuckBoxOptionsUseCase,
    required this.suggestLuckBoxUseCase,
  }) : super(const LuckyBoxState());

  Future<void> loadOptions() async {
    emit(state.copyWith(optionsStatus: BlocStatus.loading, clearErrorMessage: true));
    final res = await fetchLuckBoxOptionsUseCase(NoParams());
    res.fold(
      (f) => emit(
        state.copyWith(
          optionsStatus: BlocStatus.failed,
          errorMessage: f.message,
        ),
      ),
      (options) => emit(
        state.copyWith(
          optionsStatus: BlocStatus.success,
          options: options,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<void> suggestLuckBox(SuggestLuckBoxParams params) async {
    emit(
      state.copyWith(
        suggestStatus: BlocStatus.loading,
        clearErrorMessage: true,
        clearSuggestResult: true,
      ),
    );
    final res = await suggestLuckBoxUseCase(params);
    res.fold(
      (f) => emit(
        state.copyWith(
          suggestStatus: BlocStatus.failed,
          errorMessage: f.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          suggestStatus: BlocStatus.success,
          suggestResult: result,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  void clearSuggestStatus() {
    emit(state.copyWith(suggestStatus: null, clearSuggestResult: true));
  }
}
