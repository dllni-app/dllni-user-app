import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:toastification/toastification.dart';

import '../../../data/models/add_shopping_list_to_cart_model.dart';
import '../../../data/models/fetch_notifications_model.dart';
import '../../../data/models/get_shopping_list_model.dart';
import '../../../data/models/profile_api_models.dart';
import '../../../data/models/shopping_lists_api_models.dart';
import '../../../domain/models/address_list_item.dart';
import '../../../domain/usecases/add_shopping_list_to_cart_use_case.dart';
import '../../../domain/usecases/create_address_use_case.dart';
import '../../../domain/usecases/create_shopping_list_use_case.dart';
import '../../../domain/usecases/create_vote_use_case.dart';
import '../../../domain/usecases/delete_address_use_case.dart';
import '../../../domain/usecases/delete_shopping_list_item_use_case.dart';
import '../../../domain/usecases/end_vote_use_case.dart';
import '../../../domain/usecases/fetch_active_votes_use_case.dart';
import '../../../domain/usecases/fetch_addresses_use_case.dart';
import '../../../domain/usecases/fetch_favorite_restaurants_use_case.dart';
import '../../../domain/usecases/fetch_notifications_use_case.dart';
import '../../../domain/usecases/fetch_shopping_list_detail_use_case.dart';
import '../../../domain/usecases/fetch_vote_suggestions_use_case.dart';
import '../../../domain/usecases/get_shopping_list_use_case.dart';
import '../../../domain/usecases/mark_all_notifications_read_use_case.dart';
import '../../../domain/usecases/remove_favorite_restaurant_use_case.dart';
import '../../../domain/usecases/set_default_address_use_case.dart';
import '../../../domain/usecases/show_vote_use_case.dart';
import '../../../domain/usecases/update_address_use_case.dart';
import '../../../domain/usecases/update_shopping_list_item_use_case.dart';
import '../../../domain/usecases/update_shopping_list_use_case.dart';

part 'profile_event.dart';
part 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AddShoppingListToCartUseCase addShoppingListToCartUseCase;
  final GetShoppingListUseCase getShoppingListUseCase;
  final CreateShoppingListUseCase createShoppingListUseCase;
  final UpdateShoppingListUseCase updateShoppingListUseCase;
  final FetchShoppingListDetailUseCase fetchShoppingListDetailUseCase;
  final UpdateShoppingListItemUseCase updateShoppingListItemUseCase;
  final DeleteShoppingListItemUseCase deleteShoppingListItemUseCase;
  final FetchAddressesUseCase fetchAddressesUseCase;
  final SetDefaultAddressUseCase setDefaultAddressUseCase;
  final FetchNotificationsUseCase fetchNotificationsUseCase;
  final MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;
  final FetchFavoriteRestaurantsUseCase fetchFavoriteRestaurantsUseCase;
  final RemoveFavoriteRestaurantUseCase removeFavoriteRestaurantUseCase;
  final CreateVoteUseCase createVoteUseCase;
  final FetchVoteSuggestionsUseCase fetchVoteSuggestionsUseCase;
  final CreateAddressUseCase createAddressUseCase;
  final UpdateAddressUseCase updateAddressUseCase;
  final DeleteAddressUseCase deleteAddressUseCase;
  final ShowVoteUseCase showVoteUseCase;
  final EndVoteUseCase endVoteUseCase;
  final FetchActiveVotesUseCase fetchActiveVotesUseCase;

  ProfileBloc(
    this.fetchAddressesUseCase,
    this.setDefaultAddressUseCase,
    this.fetchNotificationsUseCase,
    this.markAllNotificationsReadUseCase,
    this.fetchFavoriteRestaurantsUseCase,
    this.removeFavoriteRestaurantUseCase,
    this.createVoteUseCase,
    this.fetchVoteSuggestionsUseCase,
    this.createAddressUseCase,
    this.updateAddressUseCase,
    this.deleteAddressUseCase,
    this.showVoteUseCase,
    this.endVoteUseCase,
    this.fetchActiveVotesUseCase,
    this.getShoppingListUseCase,
    this.createShoppingListUseCase,
    this.updateShoppingListUseCase,
    this.fetchShoppingListDetailUseCase,
    this.updateShoppingListItemUseCase,
    this.deleteShoppingListItemUseCase,
    this.addShoppingListToCartUseCase,
  ) : super(ProfileState()) {
    on<FetchAddressesEvent>(_fetchAddresses);
    on<SetDefaultAddressEvent>(_setDefaultAddress);
    on<FetchNotificationsEvent>(_fetchNotifications);
    on<MarkAllNotificationsReadEvent>(_markAllNotificationsRead);
    on<FetchFavoriteRestaurantsEvent>(_fetchFavoriteRestaurants);
    on<RemoveFavoriteRestaurantEvent>(_removeFavoriteRestaurant);
    on<CreateVoteEvent>(_createVote);
    on<FetchVoteSuggestionsEvent>(_fetchVoteSuggestions);
    on<CreateAddressEvent>(_createAddress);
    on<UpdateAddressEvent>(_updateAddress);
    on<DeleteAddressEvent>(_deleteAddress);
    on<ShowVoteEvent>(_showVote);
    on<EndVoteEvent>(_endVote);
    on<FetchActiveVotesEvent>(_fetchActiveVotes);

    on<GetShoppingListEvent>(_getShoppingList);
    on<CreateShoppingListEvent>(_createShoppingList);
    on<UpdateShoppingListEvent>(_updateShoppingList);
    on<GetShoppingListDetailEvent>(_getShoppingListDetail);
    on<PatchShoppingListItemQuantityEvent>(_patchShoppingListItemQuantity);
    on<ClearShoppingListQuantityPatchErrorEvent>(
      _clearShoppingListQuantityPatchError,
    );
    on<DeleteShoppingListItemEvent>(_deleteShoppingListItem);
    on<AddShoppingListToCartEvent>(_addShoppingListToCart);
  }

  FutureOr<void> _addShoppingListToCart(
    AddShoppingListToCartEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(addShoppingListToCartStatus: BlocStatus.loading));
    final res = await addShoppingListToCartUseCase(event.params);
    res.fold(
      (l) {
        emit(
          state.copyWith(
            addShoppingListToCartStatus: BlocStatus.failed,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            addShoppingListToCartStatus: BlocStatus.success,
            addShoppingListToCart: AddShoppingListToCartModel(),
          ),
        );
      },
    );
  }

  void _clearShoppingListQuantityPatchError(
    ClearShoppingListQuantityPatchErrorEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(clearQuantityPatchError: true));
  }

  Future<void> _createAddress(
    CreateAddressEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(createAddressStatus: BlocStatus.loading));
    final response = await createAddressUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          createAddressStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) {
        add(FetchAddressesEvent(params: FetchAddressesParams()));
        emit(
          state.copyWith(
            createAddressStatus: BlocStatus.success,
            actionMessage: result.message ?? 'تمت إضافة العنوان بنجاح',
          ),
        );
      },
    );
  }

  Future<void> _createVote(
    CreateVoteEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(createVoteStatus: BlocStatus.loading));
    final response = await createVoteUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          createVoteStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          createVoteStatus: BlocStatus.success,
          createdVote: result,
        ),
      ),
    );
  }

  Future<void> _deleteShoppingListItem(
    DeleteShoppingListItemEvent event,
    Emitter<ProfileState> emit,
  ) async {
    Loading.show(event.context);
    final response = await deleteShoppingListItemUseCase(
      DeleteShoppingListItemParams(
        shoppingListId: event.shoppingListId,
        itemId: event.itemId,
      ),
    );
    await response.fold(
      (failure) async {
        Loading.close();
        AppToast.showToast(
          context: event.context,
          message: failure.message,
          type: ToastificationType.error,
        );
      },
      (_) async {
        Loading.close();
        final detail = state.shoppingListDetail;
        if (detail != null) {
          emit(
            state.copyWith(
              shoppingListDetail: detail.copyWith(
                items: detail.items
                    .where((i) => i.id != event.itemId)
                    .toList(),
              ),
            ),
          );
        }
        AppToast.showToast(
          context: event.context,
          message: 'تم حذف المنتج بنجاح',
          type: ToastificationType.success,
        );
      },
    );
  }

  Future<void> _deleteAddress(
    DeleteAddressEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(deleteAddressStatus: BlocStatus.loading));
    Loading.show(event.context);
    final response = await deleteAddressUseCase(
      DeleteAddressParams(addressId: event.addressId),
    );
    await response.fold(
      (failure) async {
        Loading.close();
        AppToast.showToast(
          context: event.context,
          message: failure.message,
          type: ToastificationType.error,
        );
        emit(
          state.copyWith(
            deleteAddressStatus: BlocStatus.failed,
            errorMessage: failure.message,
          ),
        );
      },
      (_) async {
        Loading.close();
        emit(
          state.copyWith(
            deleteAddressStatus: BlocStatus.success,
            actionMessage: 'تم حذف العنوان بنجاح',
          ),
        );
        add(FetchAddressesEvent(params: FetchAddressesParams()));
      },
    );
  }

  Future<void> _endVote(EndVoteEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(endVoteStatus: BlocStatus.loading));
    final response = await endVoteUseCase(EndVoteParams(voteId: event.voteId));
    response.fold(
      (failure) => emit(
        state.copyWith(
          endVoteStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          endVoteStatus: BlocStatus.success,
          actionMessage: 'تم إنهاء التصويت بنجاح',
        ),
      ),
    );
  }

  Future<void> _fetchActiveVotes(
    FetchActiveVotesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(activeVotesStatus: BlocStatus.loading));
    final response = await fetchActiveVotesUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          activeVotesStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          activeVotesStatus: BlocStatus.success,
          activeVotes: result.data,
        ),
      ),
    );
  }

  Future<void> _fetchAddresses(
    FetchAddressesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(addressesStatus: BlocStatus.loading));
    final response = await fetchAddressesUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          addressesStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) {
        final addresses = (result.addresses ?? const <AddressResourceModel>[])
            .map(_toAddressItem)
            .toList();
        AddressListItem? defaultAddress;
        for (final item in addresses) {
          if (item.isDefault) {
            defaultAddress = item;
            break;
          }
        }
        final fallbackDefault = addresses.isNotEmpty
            ? addresses.first.id
            : null;
        emit(
          state.copyWith(
            addressesStatus: BlocStatus.success,
            addresses: addresses,
            defaultAddressId: defaultAddress?.id ?? fallbackDefault,
          ),
        );
      },
    );
  }

  Future<void> _fetchFavoriteRestaurants(
    FetchFavoriteRestaurantsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(favoriteRestaurantsStatus: BlocStatus.loading));
    final response = await fetchFavoriteRestaurantsUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          favoriteRestaurantsStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          favoriteRestaurantsStatus: BlocStatus.success,
          favoriteRestaurants: result.data ?? const <FavoriteRestaurantModel>[],
        ),
      ),
    );
  }

  Future<void> _fetchNotifications(
    FetchNotificationsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(notificationsStatus: BlocStatus.loading));
    final response = await fetchNotificationsUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          notificationsStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) {
        final mapped = (result.data ?? const <NotificationResourceModel>[])
            .map(_toNotificationItem)
            .toList();
        emit(
          state.copyWith(
            notificationsStatus: BlocStatus.success,
            notifications: mapped,
          ),
        );
        add(MarkAllNotificationsReadEvent());
      },
    );
  }

  Future<void> _fetchVoteSuggestions(
    FetchVoteSuggestionsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final query = event.searchQuery.trim();
    if (query.isEmpty) {
      emit(
        state.copyWith(
          voteSuggestionsStatus: BlocStatus.success,
          voteSuggestions: const VoteSuggestionsModel(),
        ),
      );
      return;
    }
    emit(state.copyWith(voteSuggestionsStatus: BlocStatus.loading));
    final response = await fetchVoteSuggestionsUseCase(
      FetchVoteSuggestionsParams(search: query),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          voteSuggestionsStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          voteSuggestionsStatus: BlocStatus.success,
          voteSuggestions: result,
        ),
      ),
    );
  }

  FutureOr<void> _getShoppingList(
    GetShoppingListEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(shoppingListStatus: BlocStatus.loading));
    final res = await getShoppingListUseCase(event.params);
    res.fold(
      (l) {
        emit(
          state.copyWith(
            shoppingListStatus: BlocStatus.failed,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            shoppingListStatus: BlocStatus.success,
            shoppingList: r,
          ),
        );
      },
    );
  }

  Future<void> _createShoppingList(
    CreateShoppingListEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(createShoppingListStatus: BlocStatus.loading));
    final res = await createShoppingListUseCase(event.params);
    res.fold(
      (failure) => emit(
        state.copyWith(
          createShoppingListStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (r) {
        final detail = r.data;
        if (detail == null) {
          emit(
            state.copyWith(
              createShoppingListStatus: BlocStatus.failed,
              errorMessage: 'Invalid response',
            ),
          );
          return;
        }
        final newItem = _shoppingListDetailToListItem(detail);
        final existing = state.shoppingList?.data ?? <GetShoppingListModelDataItem>[];
        emit(
          state.copyWith(
            createShoppingListStatus: BlocStatus.success,
            shoppingListStatus: BlocStatus.success,
            shoppingList: GetShoppingListModel(
              data: <GetShoppingListModelDataItem>[newItem, ...existing],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateShoppingList(
    UpdateShoppingListEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(updateShoppingListStatus: BlocStatus.loading));
    final res = await updateShoppingListUseCase(event.params);
    res.fold(
      (failure) => emit(
        state.copyWith(
          updateShoppingListStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (r) {
        final detail = r.data;
        if (detail == null) {
          emit(
            state.copyWith(
              updateShoppingListStatus: BlocStatus.failed,
              errorMessage: 'Invalid response',
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            updateShoppingListStatus: BlocStatus.success,
            shoppingListDetail: detail,
            shoppingListDetailStatus: BlocStatus.success,
          ),
        );
      },
    );
  }

  GetShoppingListModelDataItem _shoppingListDetailToListItem(
    ShoppingListDetailModel d,
  ) {
    final s = d.schedule;
    return GetShoppingListModelDataItem(
      id: d.id,
      name: d.name,
      description: d.description,
      isActive: d.isActive,
      itemsCount: d.items.length,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
      schedule: s == null
          ? null
          : GetShoppingListModelDataItemSchedule(
              frequencyType: s.frequencyType,
              weekDays: s.weekDays,
              monthDays: s.monthDays,
              periods: s.periods
                  .map(
                    (p) => GetShoppingListModelDataItemSchedulePeriodsItem(
                      label: p.label,
                      fromTime: p.fromTime,
                      toTime: p.toTime,
                    ),
                  )
                  .toList(),
              isActive: s.isActive,
              nextRunAt: s.nextRunAt,
              lastRunAt: s.lastRunAt,
            ),
    );
  }

  FutureOr<void> _getShoppingListDetail(
    GetShoppingListDetailEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(shoppingListDetailStatus: BlocStatus.loading));
    final res = await fetchShoppingListDetailUseCase(event.params);
    res.fold(
      (l) => emit(
        state.copyWith(
          shoppingListDetailStatus: BlocStatus.failed,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(
        state.copyWith(
          shoppingListDetailStatus: BlocStatus.success,
          shoppingListDetail: r.data,
        ),
      ),
    );
  }

  AddressType _mapAddressType(String? label) {
    final value = (label ?? '').toLowerCase();
    if (value.contains('عمل') || value.contains('work')) {
      return AddressType.work;
    }
    if (value.contains('عائلة') || value.contains('family')) {
      return AddressType.family;
    }
    return AddressType.home;
  }

  Future<void> _markAllNotificationsRead(
    MarkAllNotificationsReadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final response = await markAllNotificationsReadUseCase(NoParams());
    response.fold((_) {}, (_) {
      emit(
        state.copyWith(
          notifications: state.notifications
              .map(
                (item) =>
                    item.copyWith(isRead: true, showTrailingAccent: false),
              )
              .toList(),
        ),
      );
    });
  }

  FutureOr<void> _patchShoppingListItemQuantity(
    PatchShoppingListItemQuantityEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final res = await updateShoppingListItemUseCase(
      UpdateShoppingListItemParams(
        shoppingListId: event.shoppingListId,
        itemId: event.itemId,
        quantity: event.quantity,
      ),
    );
    res.fold(
      (l) => emit(state.copyWith(quantityPatchError: l.message)),
      (r) => emit(
        state.copyWith(
          shoppingListDetail: r.data ?? state.shoppingListDetail,
          shoppingListDetailStatus: BlocStatus.success,
          clearQuantityPatchError: true,
        ),
      ),
    );
  }

  Future<void> _removeFavoriteRestaurant(
    RemoveFavoriteRestaurantEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(removeFavoriteRestaurantStatus: BlocStatus.loading));
    final response = await removeFavoriteRestaurantUseCase(
      RemoveFavoriteRestaurantParams(restaurantId: event.restaurantId),
    );
    await response.fold(
      (failure) async {
        emit(
          state.copyWith(
            removeFavoriteRestaurantStatus: BlocStatus.failed,
            errorMessage: failure.message,
          ),
        );
      },
      (_) async {
        emit(
          state.copyWith(
            removeFavoriteRestaurantStatus: BlocStatus.success,
            actionMessage: 'تمت إزالة المطعم من المفضلة',
          ),
        );
        add(
          FetchFavoriteRestaurantsEvent(
            params: FetchFavoriteRestaurantsParams(),
          ),
        );
      },
    );
  }

  Future<void> _setDefaultAddress(
    SetDefaultAddressEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(setDefaultAddressStatus: BlocStatus.loading));
    Loading.show(event.context);
    final response = await setDefaultAddressUseCase(
      SetDefaultAddressParams(addressId: event.addressId),
    );
    await response.fold(
      (failure) async {
        Loading.close();
        AppToast.showToast(
          context: event.context,
          message: failure.message,
          type: ToastificationType.error,
        );
        emit(
          state.copyWith(
            setDefaultAddressStatus: BlocStatus.failed,
            errorMessage: failure.message,
          ),
        );
      },
      (_) async {
        Loading.close();
        emit(
          state.copyWith(
            setDefaultAddressStatus: BlocStatus.success,
            actionMessage: 'تم تحديث العنوان الافتراضي',
          ),
        );
        add(FetchAddressesEvent(params: FetchAddressesParams()));
      },
    );
  }

  Future<void> _showVote(
    ShowVoteEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(voteDetailsStatus: BlocStatus.loading));
    final response = await showVoteUseCase(
      ShowVoteParams(voteId: event.voteId),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          voteDetailsStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          voteDetailsStatus: BlocStatus.success,
          voteDetails: result,
        ),
      ),
    );
  }

  AddressListItem _toAddressItem(AddressResourceModel model) {
    final label = (model.label ?? '').trim().isNotEmpty
        ? model.label!
        : 'العنوان';
    final lineParts =
        [
              model.city,
              model.neighborhood,
              model.street,
              if ((model.building ?? '').isNotEmpty) 'بناء ${model.building}',
              if ((model.floor ?? '').isNotEmpty) 'طابق ${model.floor}',
            ]
            .where((part) => (part ?? '').trim().isNotEmpty)
            .map((part) => part!.trim())
            .toList();
    return AddressListItem(
      id:
          model.id?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      line1: lineParts.isEmpty ? '-' : lineParts.join(' - '),
      mobile: model.mobile,
      city: model.city,
      neighborhood: model.neighborhood,
      street: model.street,
      building: model.building,
      floor: model.floor,
      directions: model.directions,
      landmark: model.directions,
      type: _mapAddressType(label),
      isDefault: model.isDefault,
    );
  }

  FetchNotificationsModelDataItem _toNotificationItem(
    NotificationResourceModel item,
  ) {
    return FetchNotificationsModelDataItem(
      type: item.type ?? 'system',
      title: item.title,
      body: item.body,
      createdAt: item.createdAt,
      isRead: item.readAt != null,
      showTrailingAccent: item.readAt == null,
    );
  }

  Future<void> _updateAddress(
    UpdateAddressEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(updateAddressStatus: BlocStatus.loading));
    final response = await updateAddressUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          updateAddressStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) {
        add(FetchAddressesEvent(params: FetchAddressesParams()));
        emit(
          state.copyWith(
            updateAddressStatus: BlocStatus.success,
            actionMessage: result.message ?? 'تم تحديث العنوان بنجاح',
          ),
        );
      },
    );
  }
}
