import 'package:common_package/common_package.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/shopping_lists_api_models.dart';
import '../../domain/usecases/add_shopping_list_item_use_case.dart';
import '../../domain/usecases/add_shopping_list_to_cart_use_case.dart';
import '../../domain/usecases/delete_shopping_list_item_use_case.dart';
import '../../domain/usecases/delete_shopping_list_use_case.dart';
import '../../domain/usecases/fetch_shopping_list_detail_use_case.dart';
import '../../domain/usecases/update_shopping_list_item_use_case.dart';
import '../../domain/usecases/update_shopping_list_use_case.dart';
import 'shopping_lists_cubit.dart';

class ShoppingListDetailState {
  final BlocStatus status;
  final BlocStatus mutationStatus;
  final ShoppingListDetailModel? shoppingList;
  final String? errorMessage;
  final Set<int> updatingItemIds;
  final bool isReorderToCartLoading;

  const ShoppingListDetailState({
    this.status = BlocStatus.init,
    this.mutationStatus = BlocStatus.init,
    this.shoppingList,
    this.errorMessage,
    this.updatingItemIds = const <int>{},
    this.isReorderToCartLoading = false,
  });

  ShoppingListDetailState copyWith({
    BlocStatus? status,
    BlocStatus? mutationStatus,
    ShoppingListDetailModel? shoppingList,
    bool replaceShoppingList = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    Set<int>? updatingItemIds,
    bool? isReorderToCartLoading,
  }) {
    return ShoppingListDetailState(
      status: status ?? this.status,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      shoppingList: replaceShoppingList ? shoppingList : (shoppingList ?? this.shoppingList),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      updatingItemIds: updatingItemIds ?? this.updatingItemIds,
      isReorderToCartLoading: isReorderToCartLoading ?? this.isReorderToCartLoading,
    );
  }
}

@injectable
class ShoppingListDetailCubit extends Cubit<ShoppingListDetailState> {
  final FetchShoppingListDetailUseCase fetchShoppingListDetailUseCase;
  final UpdateShoppingListUseCase updateShoppingListUseCase;
  final DeleteShoppingListUseCase deleteShoppingListUseCase;
  final AddShoppingListItemUseCase addShoppingListItemUseCase;
  final UpdateShoppingListItemUseCase updateShoppingListItemUseCase;
  final DeleteShoppingListItemUseCase deleteShoppingListItemUseCase;
  final AddShoppingListToCartUseCase addShoppingListToCartUseCase;
  final ShoppingListsCubit shoppingListsCubit;

  int? _shoppingListId;

  ShoppingListDetailCubit({
    required this.fetchShoppingListDetailUseCase,
    required this.updateShoppingListUseCase,
    required this.deleteShoppingListUseCase,
    required this.addShoppingListItemUseCase,
    required this.updateShoppingListItemUseCase,
    required this.deleteShoppingListItemUseCase,
    required this.addShoppingListToCartUseCase,
    required this.shoppingListsCubit,
  }) : super(const ShoppingListDetailState());

  Future<void> loadShoppingList(int shoppingListId, {bool showLoader = true}) async {
    _shoppingListId = shoppingListId;
    if (showLoader) {
      emit(state.copyWith(status: BlocStatus.loading, clearErrorMessage: true));
    }
    final res = await fetchShoppingListDetailUseCase(
      FetchShoppingListDetailParams(shoppingListId: shoppingListId),
    );
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
          shoppingList: result.data,
          replaceShoppingList: true,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<void> refetchAll() async {
    final shoppingListId = _shoppingListId;
    if (shoppingListId == null) return;
    await shoppingListsCubit.loadShoppingLists(showLoader: false);
    await loadShoppingList(shoppingListId, showLoader: false);
  }

  Future<void> updateShoppingList({
    String? name,
    String? description,
    bool? isActive,
  }) async {
    final shoppingListId = _shoppingListId;
    if (shoppingListId == null) return;
    emit(state.copyWith(mutationStatus: BlocStatus.loading, clearErrorMessage: true));
    final res = await updateShoppingListUseCase(
      UpdateShoppingListParams(
        shoppingListId: shoppingListId,
        name: name,
        description: description,
        isActive: isActive,
      ),
    );
    res.fold(
      (failure) => emit(
        state.copyWith(
          mutationStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        emit(state.copyWith(mutationStatus: BlocStatus.success, clearErrorMessage: true));
        await refetchAll();
      },
    );
  }

  Future<bool> deleteShoppingList() async {
    final shoppingListId = _shoppingListId;
    if (shoppingListId == null) return false;
    emit(state.copyWith(mutationStatus: BlocStatus.loading, clearErrorMessage: true));
    final res = await deleteShoppingListUseCase(
      DeleteShoppingListParams(shoppingListId: shoppingListId),
    );
    return res.fold(
      (failure) {
        emit(
          state.copyWith(
            mutationStatus: BlocStatus.failed,
            errorMessage: failure.message,
          ),
        );
        return false;
      },
      (_) async {
        emit(state.copyWith(mutationStatus: BlocStatus.success, clearErrorMessage: true));
        await shoppingListsCubit.loadShoppingLists(showLoader: false);
        return true;
      },
    );
  }

  Future<void> addItem({
    required int masterProductId,
    num quantity = 1,
    String? unit,
  }) async {
    final shoppingListId = _shoppingListId;
    if (shoppingListId == null) return;
    emit(state.copyWith(mutationStatus: BlocStatus.loading, clearErrorMessage: true));
    final res = await addShoppingListItemUseCase(
      AddShoppingListItemParams(
        shoppingListId: shoppingListId,
        masterProductId: masterProductId,
        quantity: quantity,
        unit: unit,
      ),
    );
    res.fold(
      (failure) => emit(
        state.copyWith(
          mutationStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        emit(state.copyWith(mutationStatus: BlocStatus.success, clearErrorMessage: true));
        await refetchAll();
      },
    );
  }

  Future<void> deleteItem(int itemId) async {
    final shoppingListId = _shoppingListId;
    if (shoppingListId == null) return;
    emit(state.copyWith(mutationStatus: BlocStatus.loading, clearErrorMessage: true));
    final res = await deleteShoppingListItemUseCase(
      DeleteShoppingListItemParams(shoppingListId: shoppingListId, itemId: itemId),
    );
    res.fold(
      (failure) => emit(
        state.copyWith(
          mutationStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        emit(state.copyWith(mutationStatus: BlocStatus.success, clearErrorMessage: true));
        await refetchAll();
      },
    );
  }

  Future<void> toggleItemIncluded({
    required int itemId,
    required bool isIncluded,
  }) async {
    final shoppingListId = _shoppingListId;
    if (shoppingListId == null) return;
    final res = await updateShoppingListItemUseCase(
      UpdateShoppingListItemParams(
        shoppingListId: shoppingListId,
        itemId: itemId,
        isIncluded: isIncluded,
      ),
    );
    res.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) async {
        emit(state.copyWith(mutationStatus: BlocStatus.success, clearErrorMessage: true));
        await refetchAll();
      },
    );
  }

  Future<void> updateItemQuantityOptimistic({
    required int itemId,
    required double quantity,
  }) async {
    final shoppingListId = _shoppingListId;
    final currentList = state.shoppingList;
    if (shoppingListId == null || currentList == null) return;

    final currentItems = currentList.items;
    final updatedItems = currentItems
        .map((item) => item.id == itemId ? item.copyWith(quantity: quantity) : item)
        .toList();
    final previousList = currentList;
    final updatingIds = Set<int>.from(state.updatingItemIds)..add(itemId);

    emit(
      state.copyWith(
        shoppingList: currentList.copyWith(items: updatedItems),
        updatingItemIds: updatingIds,
        replaceShoppingList: true,
      ),
    );

    final res = await updateShoppingListItemUseCase(
      UpdateShoppingListItemParams(
        shoppingListId: shoppingListId,
        itemId: itemId,
        quantity: quantity,
      ),
    );

    final doneUpdatingIds = Set<int>.from(state.updatingItemIds)..remove(itemId);

    res.fold(
      (failure) => emit(
        state.copyWith(
          shoppingList: previousList,
          replaceShoppingList: true,
          mutationStatus: BlocStatus.failed,
          errorMessage: failure.message,
          updatingItemIds: doneUpdatingIds,
        ),
      ),
      (_) async {
        emit(
          state.copyWith(
            mutationStatus: BlocStatus.success,
            clearErrorMessage: true,
            updatingItemIds: doneUpdatingIds,
          ),
        );
        await refetchAll();
      },
    );
  }

  Future<void> reorderToCart({required int storeId}) async {
    final shoppingListId = _shoppingListId;
    if (shoppingListId == null) return;
    if (state.isReorderToCartLoading) return;
    emit(
      state.copyWith(
        mutationStatus: BlocStatus.loading,
        isReorderToCartLoading: true,
        clearErrorMessage: true,
      ),
    );
    final res = await addShoppingListToCartUseCase(
      AddShoppingListToCartParams(shoppingListId: shoppingListId, storeId: storeId),
    );
    res.fold(
      (failure) => emit(
        state.copyWith(
          mutationStatus: BlocStatus.failed,
          errorMessage: failure.message,
          isReorderToCartLoading: false,
        ),
      ),
      (_) async {
        emit(state.copyWith(mutationStatus: BlocStatus.success, clearErrorMessage: true));
        await refetchAll();
        emit(state.copyWith(isReorderToCartLoading: false));
      },
    );
  }
}
