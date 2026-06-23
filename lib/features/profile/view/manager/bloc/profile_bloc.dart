import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:common_package/common_package.dart';
import 'package:toastification/toastification.dart';

import '../../../data/models/add_shopping_list_to_cart_model.dart';
import '../../../data/models/fetch_notifications_model.dart';
import '../../../data/models/get_shopping_list_model.dart';
import '../../../data/models/profile_api_models.dart';
import '../../../data/models/group_order_api_models.dart';
import '../../../data/models/shopping_lists_api_models.dart';
import '../../../../rs_discover/data/models/fetch_discover_restaurants_model.dart';
import '../../../domain/models/address_list_item.dart';
import '../../../domain/usecases/add_shopping_list_to_cart_use_case.dart';
import '../../../domain/usecases/add_group_order_item_use_case.dart';
import '../../../domain/usecases/cancel_group_order_use_case.dart';
import '../../../domain/usecases/create_group_order_use_case.dart';
import '../../../domain/usecases/create_shopping_list_use_case.dart';
import '../../../domain/usecases/create_vote_use_case.dart';
import '../../../domain/usecases/create_address_use_case.dart';
import '../../../domain/usecases/delete_group_order_item_use_case.dart';
import '../../../domain/usecases/delete_address_use_case.dart';
import '../../../domain/usecases/delete_shopping_list_item_use_case.dart';
import '../../../domain/usecases/end_vote_use_case.dart';
import '../../../domain/usecases/fetch_active_group_orders_use_case.dart';
import '../../../domain/usecases/fetch_group_order_menu_sections_use_case.dart';
import '../../../domain/usecases/fetch_addresses_use_case.dart';
import '../../../domain/usecases/fetch_favorite_restaurants_use_case.dart';
import '../../../domain/usecases/fetch_notifications_use_case.dart';
import '../../../domain/usecases/fetch_shopping_list_detail_use_case.dart';
import '../../../domain/usecases/get_shopping_list_use_case.dart';
import '../../../domain/usecases/join_group_order_use_case.dart';
import '../../../domain/usecases/mark_all_notifications_read_use_case.dart';
import '../../../domain/usecases/mark_notification_read_use_case.dart';
import '../../../domain/usecases/fetch_vote_suggestions_use_case.dart';
import '../../../domain/usecases/fetch_active_votes_use_case.dart';
import '../../../domain/usecases/place_group_order_use_case.dart';
import '../../../domain/usecases/remove_favorite_restaurant_use_case.dart';
import '../../../domain/usecases/set_default_address_use_case.dart';
import '../../../domain/usecases/show_group_order_use_case.dart';
import '../../../domain/usecases/show_vote_use_case.dart';
import '../../../domain/usecases/submit_group_order_use_case.dart';
import '../../../domain/usecases/submit_vote_ballot_use_case.dart';
import '../../../domain/usecases/unsubmit_group_order_use_case.dart';
import '../../../domain/usecases/update_address_use_case.dart';
import '../../../domain/usecases/update_group_order_item_use_case.dart';
import '../../../domain/usecases/update_shopping_list_use_case.dart';
import '../../../domain/usecases/update_shopping_list_item_use_case.dart';
import '../../../../rs_discover/domain/params/fetch_discover_restaurants_params.dart';
import '../../../../rs_discover/domain/usecases/fetch_discover_restaurants_use_case.dart';

part 'profile_event.dart';

part 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FetchAddressesUseCase fetchAddressesUseCase;
  final SetDefaultAddressUseCase setDefaultAddressUseCase;
  final FetchNotificationsUseCase fetchNotificationsUseCase;
  final MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final FetchFavoriteRestaurantsUseCase fetchFavoriteRestaurantsUseCase;
  final RemoveFavoriteRestaurantUseCase removeFavoriteRestaurantUseCase;
  final CreateVoteUseCase createVoteUseCase;
  final FetchVoteSuggestionsUseCase fetchVoteSuggestionsUseCase;
  final CreateAddressUseCase createAddressUseCase;
  final UpdateAddressUseCase updateAddressUseCase;
  final DeleteAddressUseCase deleteAddressUseCase;
  final ShowVoteUseCase showVoteUseCase;
  final SubmitVoteBallotUseCase submitVoteBallotUseCase;
  final EndVoteUseCase endVoteUseCase;
  final FetchActiveVotesUseCase fetchActiveVotesUseCase;
  final FetchDiscoverRestaurantsUseCase fetchDiscoverRestaurantsUseCase;
  final FetchGroupOrderMenuSectionsUseCase fetchGroupOrderMenuSectionsUseCase;
  final CreateGroupOrderUseCase createGroupOrderUseCase;
  final JoinGroupOrderUseCase joinGroupOrderUseCase;
  final FetchActiveGroupOrdersUseCase fetchActiveGroupOrdersUseCase;
  final ShowGroupOrderUseCase showGroupOrderUseCase;
  final AddGroupOrderItemUseCase addGroupOrderItemUseCase;
  final UpdateGroupOrderItemUseCase updateGroupOrderItemUseCase;
  final DeleteGroupOrderItemUseCase deleteGroupOrderItemUseCase;
  final SubmitGroupOrderUseCase submitGroupOrderUseCase;
  final UnsubmitGroupOrderUseCase unsubmitGroupOrderUseCase;
  final CancelGroupOrderUseCase cancelGroupOrderUseCase;
  final PlaceGroupOrderUseCase placeGroupOrderUseCase;
  final GetShoppingListUseCase getShoppingListUseCase;
  final FetchShoppingListDetailUseCase fetchShoppingListDetailUseCase;
  final CreateShoppingListUseCase createShoppingListUseCase;
  final UpdateShoppingListUseCase updateShoppingListUseCase;
  final UpdateShoppingListItemUseCase updateShoppingListItemUseCase;
  final DeleteShoppingListItemUseCase deleteShoppingListItemUseCase;
  final AddShoppingListToCartUseCase addShoppingListToCartUseCase;

  ProfileBloc(
    this.fetchAddressesUseCase,
    this.setDefaultAddressUseCase,
    this.fetchNotificationsUseCase,
    this.markAllNotificationsReadUseCase,
    this.markNotificationReadUseCase,
    this.fetchFavoriteRestaurantsUseCase,
    this.removeFavoriteRestaurantUseCase,
    this.createVoteUseCase,
    this.fetchVoteSuggestionsUseCase,
    this.createAddressUseCase,
    this.updateAddressUseCase,
    this.deleteAddressUseCase,
    this.showVoteUseCase,
    this.submitVoteBallotUseCase,
    this.endVoteUseCase,
    this.fetchActiveVotesUseCase,
    this.fetchDiscoverRestaurantsUseCase,
    this.fetchGroupOrderMenuSectionsUseCase,
    this.createGroupOrderUseCase,
    this.joinGroupOrderUseCase,
    this.fetchActiveGroupOrdersUseCase,
    this.showGroupOrderUseCase,
    this.addGroupOrderItemUseCase,
    this.updateGroupOrderItemUseCase,
    this.deleteGroupOrderItemUseCase,
    this.submitGroupOrderUseCase,
    this.unsubmitGroupOrderUseCase,
    this.cancelGroupOrderUseCase,
    this.placeGroupOrderUseCase,
    this.getShoppingListUseCase,
    this.fetchShoppingListDetailUseCase,
    this.createShoppingListUseCase,
    this.updateShoppingListUseCase,
    this.updateShoppingListItemUseCase,
    this.deleteShoppingListItemUseCase,
    this.addShoppingListToCartUseCase,
  ) : super(ProfileState()) {
    on<FetchAddressesEvent>(_fetchAddresses);
    on<SetDefaultAddressEvent>(_setDefaultAddress);
    on<FetchNotificationsEvent>(
      _fetchNotifications,
      transformer: paginationEventTransformer(),
    );
    on<MarkAllNotificationsReadEvent>(_markAllNotificationsRead);
    on<MarkNotificationReadEvent>(_markNotificationRead);
    on<FetchFavoriteRestaurantsEvent>(
      _fetchFavoriteRestaurants,
      transformer: paginationEventTransformer(),
    );
    on<RemoveFavoriteRestaurantEvent>(_removeFavoriteRestaurant);
    on<CreateVoteEvent>(_createVote);
    on<FetchVoteSuggestionsEvent>(_fetchVoteSuggestions);
    on<CreateAddressEvent>(_createAddress);
    on<UpdateAddressEvent>(_updateAddress);
    on<DeleteAddressEvent>(_deleteAddress);
    on<ShowVoteEvent>(_showVote);
    on<SubmitVoteBallotEvent>(_submitVoteBallot);
    on<EndVoteEvent>(_endVote);
    on<FetchActiveVotesEvent>(_fetchActiveVotes);
    on<FetchGroupOrderRestaurantsEvent>(_fetchGroupOrderRestaurants);
    on<SelectGroupOrderRestaurantEvent>(_selectGroupOrderRestaurant);
    on<CreateGroupOrderEvent>(_createGroupOrder);
    on<JoinGroupOrderEvent>(_joinGroupOrder);
    on<FetchActiveGroupOrdersEvent>(_fetchActiveGroupOrders);
    on<ShowGroupOrderEvent>(_showGroupOrder);
    on<HydrateGroupOrderFromPayloadEvent>(_hydrateGroupOrderFromPayload);
    on<AddGroupOrderItemEvent>(_addGroupOrderItem);
    on<UpdateGroupOrderItemEvent>(_updateGroupOrderItem);
    on<DeleteGroupOrderItemEvent>(_deleteGroupOrderItem);
    on<SubmitGroupOrderEvent>(_submitGroupOrder);
    on<UnsubmitGroupOrderEvent>(_unsubmitGroupOrder);
    on<CancelGroupOrderEvent>(_cancelGroupOrder);
    on<PlaceGroupOrderEvent>(_placeGroupOrder);
    on<GetShoppingListEvent>(_getShoppingList);
    on<GetShoppingListDetailEvent>(_getShoppingListDetail);
    on<CreateShoppingListEvent>(_createShoppingList);
    on<UpdateShoppingListEvent>(_updateShoppingList);
    on<PatchShoppingListItemQuantityEvent>(_patchShoppingListItemQuantity);
    on<DeleteShoppingListItemEvent>(_deleteShoppingListItem);
    on<AddShoppingListToCartEvent>(_addShoppingListToCart);
    on<ClearShoppingListQuantityPatchErrorEvent>(
      _clearShoppingListQuantityPatchError,
    );
  }

  Future<void> _getShoppingList(
    GetShoppingListEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(shoppingListStatus: BlocStatus.loading));
    final response = await getShoppingListUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          shoppingListStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          shoppingListStatus: BlocStatus.success,
          shoppingList: result,
        ),
      ),
    );
  }

  Future<void> _getShoppingListDetail(
    GetShoppingListDetailEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(shoppingListDetailStatus: BlocStatus.loading));
    final response = await fetchShoppingListDetailUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          shoppingListDetailStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          shoppingListDetailStatus: BlocStatus.success,
          shoppingListDetail: result.data,
        ),
      ),
    );
  }

  Future<void> _createShoppingList(
    CreateShoppingListEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(createShoppingListStatus: BlocStatus.loading));
    final response = await createShoppingListUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          createShoppingListStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          createShoppingListStatus: BlocStatus.success,
          shoppingListDetail: result.data ?? state.shoppingListDetail,
        ),
      ),
    );
  }

  Future<void> _updateShoppingList(
    UpdateShoppingListEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(updateShoppingListStatus: BlocStatus.loading));
    final response = await updateShoppingListUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          updateShoppingListStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          updateShoppingListStatus: BlocStatus.success,
          shoppingListDetail: result.data ?? state.shoppingListDetail,
        ),
      ),
    );
  }

  Future<void> _patchShoppingListItemQuantity(
    PatchShoppingListItemQuantityEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final response = await updateShoppingListItemUseCase(
      UpdateShoppingListItemParams(
        shoppingListId: event.shoppingListId,
        itemId: event.itemId,
        quantity: event.quantity,
      ),
    );
    response.fold(
      (failure) => emit(state.copyWith(quantityPatchError: failure.message)),
      (result) => emit(
        state.copyWith(
          shoppingListDetail: result.data ?? state.shoppingListDetail,
          quantityPatchError: null,
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
        emit(state.copyWith(errorMessage: failure.message));
      },
      (_) async {
        Loading.close();
        final detailResponse = await fetchShoppingListDetailUseCase(
          FetchShoppingListDetailParams(shoppingListId: event.shoppingListId),
        );
        detailResponse.fold(
          (f) => emit(state.copyWith(errorMessage: f.message)),
          (r) => emit(
            state.copyWith(shoppingListDetail: r.data, errorMessage: null),
          ),
        );
      },
    );
  }

  Future<void> _addShoppingListToCart(
    AddShoppingListToCartEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(addShoppingListToCartStatus: BlocStatus.loading));
    final response = await addShoppingListToCartUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          addShoppingListToCartStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (_) =>
          emit(state.copyWith(addShoppingListToCartStatus: BlocStatus.success)),
    );
  }

  void _clearShoppingListQuantityPatchError(
    ClearShoppingListQuantityPatchErrorEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(clearQuantityPatchError: true));
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
            ? addresses.first
            : null;
        emit(
          state.copyWith(
            addressesStatus: BlocStatus.success,
            addresses: addresses,
            defaultAddress: defaultAddress ?? fallbackDefault,

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

  Future<void> _fetchNotifications(
    FetchNotificationsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final pagination = state.notificationsPagination;
    final isLoadMore = event.loadMore && !event.isReload;
    if (isLoadMore && pagination.isEndPage) return;

    emit(
      state.copyWith(
        notificationsPagination: pagination.setLoading(
          isReload: event.isReload,
        ),
        clearNotificationActionError: true,
      ),
    );

    final page = isLoadMore ? pagination.pageNumber : 1;
    final perPage = pagination.perPage;
    final response = await fetchNotificationsUseCase(
      FetchNotificationsParams(
        page: page,
        perPage: perPage,
        unreadOnly: event.params.unreadOnly,
      ),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          notificationsPagination: pagination.setFaild(
            errorMessage: failure.message,
          ),
          errorMessage: failure.message,
        ),
      ),
      (result) {
        final mapped = (result.data ?? const <NotificationResourceModel>[])
            .map(_toNotificationItem)
            .toList();
        emit(
          state.copyWith(
            notificationsPagination: pagination.setSuccess(
              data: mapped,
              total: result.meta?.total ?? pagination.total,
              perPage: result.meta?.perPage ?? perPage,

            ),
            unreadNotification: result.countUnread
          ),
        );
      },
    );
  }

  Future<void> _markAllNotificationsRead(
    MarkAllNotificationsReadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        markAllNotificationsReadStatus: BlocStatus.loading,
        clearNotificationActionError: true,
      ),
    );
    final response = await markAllNotificationsReadUseCase(NoParams());
    await response.fold(
      (failure) async {
        emit(
          state.copyWith(
            clearMarkAllNotificationsReadStatus: true,
            notificationActionError: failure.message,
          ),
        );
      },
      (_) async {
        final updatedNotifications = state.notifications
            .map(
              (item) => item.copyWith(isRead: true, showTrailingAccent: false),
            )
            .toList();
        emit(
          state.copyWith(
            clearMarkAllNotificationsReadStatus: true,
            notificationsPagination: state.notificationsPagination.copyWith(
              list: updatedNotifications,
            ),
            unreadNotification: 0
          ),
        );
      },
    );
  }

  Future<void> _markNotificationRead(
    MarkNotificationReadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final id = event.id.trim();
    if (id.isEmpty) return;

    final response = await markNotificationReadUseCase(
      MarkNotificationReadParams(notificationId: id),
    );
    response.fold(
      (failure) =>
          emit(state.copyWith(notificationActionError: failure.message)),
      (_) {
        final updated = state.notifications.map((item) {
          if (item.id == id) {
            return item.copyWith(isRead: true, showTrailingAccent: false);
          }
          return item;
        }).toList();
        emit(
          state.copyWith(
            notificationsPagination: state.notificationsPagination.copyWith(
              list: updated,
            ),
            notificationActionError: null,
          ),
        );
      },
    );
  }

  Future<void> _fetchFavoriteRestaurants(
    FetchFavoriteRestaurantsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final pagination = state.favoriteRestaurantsPagination;
    final isLoadMore = event.loadMore && !event.isReload;
    if (isLoadMore && pagination.isEndPage) return;

    emit(
      state.copyWith(
        favoriteRestaurantsPagination: pagination.setLoading(
          isReload: event.isReload,
        ),
      ),
    );

    final page = isLoadMore ? pagination.pageNumber : 1;
    final perPage = pagination.perPage;
    final response = await fetchFavoriteRestaurantsUseCase(
      FetchFavoriteRestaurantsParams(page: page, perPage: perPage),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          favoriteRestaurantsPagination: pagination.setFaild(
            errorMessage: failure.message,
          ),
          errorMessage: failure.message,
        ),
      ),
      (result) {
        final items = result.data ?? const <FavoriteRestaurantModel>[];
        final total = isLoadMore
            ? pagination.total + items.length
            : items.length;
        emit(
          state.copyWith(
            favoriteRestaurantsPagination: pagination.setSuccess(
              data: items,
              total: total,
              perPage: perPage,
            ),
          ),
        );
      },
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
            isReload: true,
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
      (_) {
        add(ShowVoteEvent(voteId: event.voteId));
        emit(
          state.copyWith(
            endVoteStatus: BlocStatus.success,
            actionMessage: 'تم إنهاء التصويت بنجاح',
          ),
        );
      },
    );
  }

  Future<void> _submitVoteBallot(
    SubmitVoteBallotEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(voteBallotStatus: BlocStatus.loading));
    final response = await submitVoteBallotUseCase(
      SubmitVoteBallotParams(voteId: event.voteId, optionId: event.optionId),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          voteBallotStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        add(ShowVoteEvent(voteId: event.voteId));
        emit(state.copyWith(voteBallotStatus: BlocStatus.success));
      },
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

  Future<void> _fetchGroupOrderRestaurants(
    FetchGroupOrderRestaurantsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        groupOrderRestaurantsStatus: BlocStatus.loading,
        errorMessage: null,
      ),
    );
    final response = await fetchDiscoverRestaurantsUseCase(
      FetchDiscoverRestaurantsParams(
        page: 1,
        perPage: 20,
        search: event.searchQuery.trim().isEmpty
            ? null
            : event.searchQuery.trim(),
      ),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          groupOrderRestaurantsStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          groupOrderRestaurantsStatus: BlocStatus.success,
          groupOrderRestaurants:
              result.data ?? const <FetchDiscoverRestaurantsModelDataItem>[],
        ),
      ),
    );
  }

  void _selectGroupOrderRestaurant(
    SelectGroupOrderRestaurantEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(selectedGroupOrderRestaurant: event.restaurant));
  }

  Future<void> _createGroupOrder(
    CreateGroupOrderEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(createGroupOrderStatus: BlocStatus.loading));
    final response = await createGroupOrderUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          createGroupOrderStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          createGroupOrderStatus: BlocStatus.success,
          createGroupOrderResult: result,
          actionMessage: result.message,
        ),
      ),
    );
  }

  Future<void> _joinGroupOrder(
    JoinGroupOrderEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(joinGroupOrderStatus: BlocStatus.loading));
    final response = await joinGroupOrderUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          joinGroupOrderStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          joinGroupOrderStatus: BlocStatus.success,
          joinGroupOrderResult: result,
          actionMessage: result.message,
        ),
      ),
    );
  }

  Future<void> _fetchActiveGroupOrders(
    FetchActiveGroupOrdersEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(activeGroupOrdersStatus: BlocStatus.loading));
    final response = await fetchActiveGroupOrdersUseCase(event.params);
    response.fold(
      (failure) => emit(
        state.copyWith(
          activeGroupOrdersStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          activeGroupOrdersStatus: BlocStatus.success,
          activeGroupOrders: result.data,
        ),
      ),
    );
  }

  Future<void> _showGroupOrder(
    ShowGroupOrderEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(groupOrderDetailsStatus: BlocStatus.loading));
    final response = await showGroupOrderUseCase(event.params);
    await response.fold(
      (failure) async => emit(
        state.copyWith(
          groupOrderDetailsStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (details) async {
        if (event.fallbackReason != null) {
          final handledAtMs = DateTime.now().millisecondsSinceEpoch;
          PusherServiceLogger.event(
            'private-group-order.${event.params.groupOrderId}',
            'group-order.updated',
            <String, dynamic>{
              'groupOrderId':
                  details.groupOrder?.id ?? event.params.groupOrderId,
              'status': details.groupOrder?.status,
            },
            eventHandledAtMs: handledAtMs,
            fallbackReason: event.fallbackReason,
          );
        }
        emit(
          state.copyWith(
            groupOrderDetailsStatus: BlocStatus.success,
            groupOrderDetails: details,
          ),
        );
        if (!event.skipMenuFetch) {
          await _loadGroupOrderMenu(details, emit);
        }
      },
    );
  }

  Future<void> _hydrateGroupOrderFromPayload(
    HydrateGroupOrderFromPayloadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final payload = event.payload['data'] is Map
        ? Map<String, dynamic>.from(event.payload['data'] as Map)
        : event.payload;
    final hasGroupOrderPayload =
        payload['groupOrder'] is Map || payload['group_order'] is Map;
    final hasParticipantsPayload = payload['participants'] is List;
    final hasCountsPayload = payload['counts'] is Map;
    final hasAmountsPayload = payload['amounts'] is Map;
    final hasCoreData =
        hasGroupOrderPayload ||
        hasParticipantsPayload ||
        hasCountsPayload ||
        hasAmountsPayload;
    if (!hasCoreData) return;

    final hydrated = GroupOrderDetailsModel.fromJson(payload);
    final previous = state.groupOrderDetails;
    final groupOrderPayloadMap = _groupOrderPayloadMap(payload);
    final mergedGroupOrder = _mergeGroupOrderCore(
      previous: previous?.groupOrder,
      hydrated: hydrated.groupOrder,
      payloadGroupOrder: groupOrderPayloadMap,
    );
    final mergedDetails = GroupOrderDetailsModel(
      groupOrder: mergedGroupOrder,
      participants: hasParticipantsPayload
          ? hydrated.participants
          : (previous?.participants ?? hydrated.participants),
      counts: hasCountsPayload
          ? hydrated.counts
          : (previous?.counts ?? hydrated.counts),
      amounts: hasAmountsPayload
          ? hydrated.amounts
          : (previous?.amounts ?? hydrated.amounts),
    );

    emit(
      state.copyWith(
        groupOrderDetailsStatus: BlocStatus.success,
        groupOrderDetails: mergedDetails,
      ),
    );
  }

  Map<String, dynamic> _groupOrderPayloadMap(Map<String, dynamic> payload) {
    final direct = payload['groupOrder'];
    if (direct is Map) return Map<String, dynamic>.from(direct);
    final fallback = payload['group_order'];
    if (fallback is Map) return Map<String, dynamic>.from(fallback);
    return const <String, dynamic>{};
  }

  GroupOrderCoreModel? _mergeGroupOrderCore({
    required GroupOrderCoreModel? previous,
    required GroupOrderCoreModel? hydrated,
    required Map<String, dynamic> payloadGroupOrder,
  }) {
    if (previous == null) return hydrated;
    if (hydrated == null) return previous;
    if (payloadGroupOrder.isEmpty) return previous;

    bool hasAny(List<String> keys) => keys.any(payloadGroupOrder.containsKey);

    return GroupOrderCoreModel(
      id: hasAny(const <String>['id']) ? hydrated.id : previous.id,
      status: hasAny(const <String>['status'])
          ? hydrated.status
          : previous.status,
      name: hasAny(const <String>['name']) ? hydrated.name : previous.name,
      restaurantId: hasAny(const <String>['restaurantId', 'restaurant_id'])
          ? hydrated.restaurantId
          : previous.restaurantId,
      restaurantName:
          hasAny(const <String>['restaurantName', 'restaurant_name'])
          ? hydrated.restaurantName
          : previous.restaurantName,
      shareToken: hasAny(const <String>['shareToken', 'share_token'])
          ? hydrated.shareToken
          : previous.shareToken,
      endsAt: hasAny(const <String>['endsAt', 'ends_at'])
          ? hydrated.endsAt
          : previous.endsAt,
      secondsRemaining:
          hasAny(const <String>['secondsRemaining', 'seconds_remaining'])
          ? hydrated.secondsRemaining
          : previous.secondsRemaining,
      creatorUserId: hasAny(const <String>['creatorUserId', 'creator_user_id'])
          ? hydrated.creatorUserId
          : previous.creatorUserId,
      isCreator: hasAny(const <String>['isCreator', 'is_creator'])
          ? hydrated.isCreator
          : previous.isCreator,
      placedOrderId: hasAny(const <String>['placedOrderId', 'placed_order_id'])
          ? hydrated.placedOrderId
          : previous.placedOrderId,
      placedAt: hasAny(const <String>['placedAt', 'placed_at'])
          ? hydrated.placedAt
          : previous.placedAt,
    );
  }

  Future<void> _addGroupOrderItem(
    AddGroupOrderItemEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await _performGroupOrderAction(
      emit: emit,
      action: () => addGroupOrderItemUseCase(event.params),
      groupOrderId: event.params.groupOrderId,
    );
  }

  Future<void> _updateGroupOrderItem(
    UpdateGroupOrderItemEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await _performGroupOrderAction(
      emit: emit,
      action: () => updateGroupOrderItemUseCase(event.params),
      groupOrderId: event.params.groupOrderId,
    );
  }

  Future<void> _deleteGroupOrderItem(
    DeleteGroupOrderItemEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await _performGroupOrderAction(
      emit: emit,
      action: () => deleteGroupOrderItemUseCase(event.params),
      groupOrderId: event.params.groupOrderId,
    );
  }

  Future<void> _submitGroupOrder(
    SubmitGroupOrderEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await _performGroupOrderAction(
      emit: emit,
      action: () => submitGroupOrderUseCase(event.params),
      groupOrderId: event.params.groupOrderId,
    );
  }

  Future<void> _unsubmitGroupOrder(
    UnsubmitGroupOrderEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await _performGroupOrderAction(
      emit: emit,
      action: () => unsubmitGroupOrderUseCase(event.params),
      groupOrderId: event.params.groupOrderId,
    );
  }

  Future<void> _cancelGroupOrder(
    CancelGroupOrderEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await _performGroupOrderAction(
      emit: emit,
      action: () => cancelGroupOrderUseCase(event.params),
      groupOrderId: event.params.groupOrderId,
    );
  }

  Future<void> _placeGroupOrder(
    PlaceGroupOrderEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await _performGroupOrderAction(
      emit: emit,
      action: () => placeGroupOrderUseCase(event.params),
      groupOrderId: event.params.groupOrderId,
    );
  }

  Future<void> _performGroupOrderAction({
    required Emitter<ProfileState> emit,
    required DataResponse<GroupOrderActionModel> Function() action,
    required int groupOrderId,
  }) async {
    emit(state.copyWith(groupOrderActionStatus: BlocStatus.loading));
    final response = await action();
    await response.fold(
      (failure) async => emit(
        state.copyWith(
          groupOrderActionStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) async {
        emit(
          state.copyWith(
            groupOrderActionStatus: BlocStatus.success,
            groupOrderActionResult: result,
            actionMessage: result.message,
          ),
        );
        add(
          ShowGroupOrderEvent(
            params: ShowGroupOrderParams(groupOrderId: groupOrderId),
          ),
        );
      },
    );
  }

  Future<void> _loadGroupOrderMenu(
    GroupOrderDetailsModel details,
    Emitter<ProfileState> emit,
  ) async {
    final restaurantId = details.groupOrder?.restaurantId;
    if (restaurantId == null || restaurantId <= 0) return;
    emit(state.copyWith(groupOrderMenuStatus: BlocStatus.loading));
    final response = await fetchGroupOrderMenuSectionsUseCase(
      FetchGroupOrderMenuSectionsParams(
        restaurantId: restaurantId,
        itemsPerSection: 30,
      ),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          groupOrderMenuStatus: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) {
        final sections = <GroupOrderMenuSectionModel>[...result.sections]
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        final products = <GroupOrderMenuSectionItemModel>[];
        final uniqueByProductId = <int, GroupOrderMenuSectionItemModel>{};
        for (final section in sections) {
          for (final item in section.items) {
            final id = item.id;
            if (id == null || id <= 0) continue;
            uniqueByProductId[id] = item.withSection(
              sectionName: section.name,
              sectionId: section.id,
            );
          }
        }
        products.addAll(uniqueByProductId.values);
        emit(
          state.copyWith(
            groupOrderMenuStatus: BlocStatus.success,
            groupOrderMenuSections: sections,
            groupOrderMenuProducts: products,
          ),
        );
      },
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
      latitude: model.latitude,
      longitude: model.longitude,
      type: _mapAddressType(label),
      isDefault: model.isDefault,
    );
  }

  FetchNotificationsModelDataItem _toNotificationItem(
    NotificationResourceModel item,
  ) {
    final read = (item.readAt ?? '').trim().isNotEmpty;
    return FetchNotificationsModelDataItem(
      id: item.id,
      type: item.type ?? 'system',
      title: item.title,
      body: item.body,
      createdAt: item.createdAt,
      isRead: read,
      showTrailingAccent: !read,
      module: item.module,
      icon: item.icon,
      category: item.category,
      priority: item.priority,
      canonicalType: item.canonicalType,
      data: item.data,
    );
  }
}
