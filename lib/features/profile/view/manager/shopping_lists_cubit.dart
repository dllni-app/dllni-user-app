import 'package:common_package/common_package.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/shopping_lists_api_models.dart';
import '../../domain/usecases/create_shopping_list_use_case.dart';
import '../../domain/usecases/fetch_shopping_lists_use_case.dart';

class ShoppingListsState {
  final BlocStatus status;
  final BlocStatus createStatus;
  final List<ShoppingListSummaryModel> lists;
  final String? errorMessage;

  const ShoppingListsState({
    this.status = BlocStatus.init,
    this.createStatus = BlocStatus.init,
    this.lists = const <ShoppingListSummaryModel>[],
    this.errorMessage,
  });

  ShoppingListsState copyWith({
    BlocStatus? status,
    BlocStatus? createStatus,
    List<ShoppingListSummaryModel>? lists,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ShoppingListsState(
      status: status ?? this.status,
      createStatus: createStatus ?? this.createStatus,
      lists: lists ?? this.lists,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

@lazySingleton
class ShoppingListsCubit extends Cubit<ShoppingListsState> {
  final FetchShoppingListsUseCase fetchShoppingListsUseCase;
  final CreateShoppingListUseCase createShoppingListUseCase;

  ShoppingListsCubit({
    required this.fetchShoppingListsUseCase,
    required this.createShoppingListUseCase,
  }) : super(const ShoppingListsState());

  Future<void> loadShoppingLists({bool showLoader = true}) async {
    if (showLoader && !isClosed) {
      emit(state.copyWith(status: BlocStatus.loading, clearErrorMessage: true));
    }
    final res = await fetchShoppingListsUseCase(FetchShoppingListsParams());
    if (isClosed) return;
    res.fold(
      (failure) => emit(
        state.copyWith(
          status: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          status: BlocStatus.success,
          lists: result.data,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<void> createShoppingList({
    required String name,
    String? description,
    bool isActive = true,
    required ShoppingListScheduleParams schedule,
  }) async {
    if (isClosed) return;
    emit(
      state.copyWith(createStatus: BlocStatus.loading, clearErrorMessage: true),
    );
    final res = await createShoppingListUseCase(
      CreateShoppingListParams(
        name: name,
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        isActive: isActive,
        schedule: schedule,
      ),
    );
    if (isClosed) return;
    res.fold(
      (failure) => emit(
        state.copyWith(
          createStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        emit(
          state.copyWith(
            createStatus: BlocStatus.success,
            clearErrorMessage: true,
          ),
        );
        await loadShoppingLists(showLoader: false);
      },
    );
  }
}
