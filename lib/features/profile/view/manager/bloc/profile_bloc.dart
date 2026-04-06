import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:common_package/common_package.dart';

import '../../../data/models/fetch_notifications_model.dart';
import '../../../data/models/profile_api_models.dart';
import '../../../domain/models/address_list_item.dart';
import '../../../domain/usecases/create_vote_use_case.dart';
import '../../../domain/usecases/end_vote_use_case.dart';
import '../../../domain/usecases/fetch_addresses_use_case.dart';
import '../../../domain/usecases/fetch_favorite_restaurants_use_case.dart';
import '../../../domain/usecases/fetch_notifications_use_case.dart';
import '../../../domain/usecases/remove_favorite_restaurant_use_case.dart';
import '../../../domain/usecases/set_default_address_use_case.dart';
import '../../../domain/usecases/show_vote_use_case.dart';

part 'profile_event.dart';

part 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FetchAddressesUseCase fetchAddressesUseCase;
  final SetDefaultAddressUseCase setDefaultAddressUseCase;
  final FetchNotificationsUseCase fetchNotificationsUseCase;
  final FetchFavoriteRestaurantsUseCase fetchFavoriteRestaurantsUseCase;
  final RemoveFavoriteRestaurantUseCase removeFavoriteRestaurantUseCase;
  final CreateVoteUseCase createVoteUseCase;
  final ShowVoteUseCase showVoteUseCase;
  final EndVoteUseCase endVoteUseCase;

  ProfileBloc(
    this.fetchAddressesUseCase,
    this.setDefaultAddressUseCase,
    this.fetchNotificationsUseCase,
    this.fetchFavoriteRestaurantsUseCase,
    this.removeFavoriteRestaurantUseCase,
    this.createVoteUseCase,
    this.showVoteUseCase,
    this.endVoteUseCase,
  ) : super(ProfileState()) {
    on<FetchAddressesEvent>(_fetchAddresses);
    on<SetDefaultAddressEvent>(_setDefaultAddress);
    on<FetchNotificationsEvent>(_fetchNotifications);
    on<MarkAllNotificationsReadEvent>(_markAllNotificationsRead);
    on<FetchFavoriteRestaurantsEvent>(_fetchFavoriteRestaurants);
    on<RemoveFavoriteRestaurantEvent>(_removeFavoriteRestaurant);
    on<CreateVoteEvent>(_createVote);
    on<ShowVoteEvent>(_showVote);
    on<EndVoteEvent>(_endVote);
  }

  Future<void> _fetchAddresses(FetchAddressesEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(addressesStatus: BlocStatus.loading));
    final response = await fetchAddressesUseCase(event.params);
    response.fold((failure) => emit(state.copyWith(addressesStatus: BlocStatus.failed, errorMessage: failure.message)), (result) {
      final addresses = (result.addresses ?? const <AddressResourceModel>[]).map(_toAddressItem).toList();
      AddressListItem? defaultAddress;
      for (final item in addresses) {
        if (item.isDefault) {
          defaultAddress = item;
          break;
        }
      }
      final fallbackDefault = addresses.isNotEmpty ? addresses.first.id : null;
      emit(state.copyWith(addressesStatus: BlocStatus.success, addresses: addresses, defaultAddressId: defaultAddress?.id ?? fallbackDefault));
    });
  }

  Future<void> _setDefaultAddress(SetDefaultAddressEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(setDefaultAddressStatus: BlocStatus.loading));
    final response = await setDefaultAddressUseCase(SetDefaultAddressParams(addressId: event.addressId));
    await response.fold(
      (failure) async {
        emit(state.copyWith(setDefaultAddressStatus: BlocStatus.failed, errorMessage: failure.message));
      },
      (_) async {
        emit(state.copyWith(setDefaultAddressStatus: BlocStatus.success, actionMessage: 'تم تحديث العنوان الافتراضي'));
        add(FetchAddressesEvent(params: FetchAddressesParams()));
      },
    );
  }

  Future<void> _fetchNotifications(FetchNotificationsEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(notificationsStatus: BlocStatus.loading));
    final response = await fetchNotificationsUseCase(event.params);
    response.fold((failure) => emit(state.copyWith(notificationsStatus: BlocStatus.failed, errorMessage: failure.message)), (result) {
      final mapped = (result.data ?? const <NotificationResourceModel>[]).map(_toNotificationItem).toList();
      emit(state.copyWith(notificationsStatus: BlocStatus.success, notifications: mapped));
    });
  }

  void _markAllNotificationsRead(MarkAllNotificationsReadEvent event, Emitter<ProfileState> emit) {
    emit(state.copyWith(notifications: state.notifications.map((item) => item.copyWith(isRead: true, showTrailingAccent: false)).toList()));
  }

  Future<void> _fetchFavoriteRestaurants(FetchFavoriteRestaurantsEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(favoriteRestaurantsStatus: BlocStatus.loading));
    final response = await fetchFavoriteRestaurantsUseCase(event.params);
    response.fold(
      (failure) => emit(state.copyWith(favoriteRestaurantsStatus: BlocStatus.failed, errorMessage: failure.message)),
      (result) =>
          emit(state.copyWith(favoriteRestaurantsStatus: BlocStatus.success, favoriteRestaurants: result.data ?? const <FavoriteRestaurantModel>[])),
    );
  }

  Future<void> _removeFavoriteRestaurant(RemoveFavoriteRestaurantEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(removeFavoriteRestaurantStatus: BlocStatus.loading));
    final response = await removeFavoriteRestaurantUseCase(RemoveFavoriteRestaurantParams(restaurantId: event.restaurantId));
    await response.fold(
      (failure) async {
        emit(state.copyWith(removeFavoriteRestaurantStatus: BlocStatus.failed, errorMessage: failure.message));
      },
      (_) async {
        emit(state.copyWith(removeFavoriteRestaurantStatus: BlocStatus.success, actionMessage: 'تمت إزالة المطعم من المفضلة'));
        add(FetchFavoriteRestaurantsEvent(params: FetchFavoriteRestaurantsParams()));
      },
    );
  }

  Future<void> _createVote(CreateVoteEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(createVoteStatus: BlocStatus.loading));
    final response = await createVoteUseCase(event.params);
    response.fold(
      (failure) => emit(state.copyWith(createVoteStatus: BlocStatus.failed, errorMessage: failure.message)),
      (result) => emit(state.copyWith(createVoteStatus: BlocStatus.success, createdVote: result)),
    );
  }

  Future<void> _showVote(ShowVoteEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(voteDetailsStatus: BlocStatus.loading));
    final response = await showVoteUseCase(ShowVoteParams(voteId: event.voteId));
    response.fold(
      (failure) => emit(state.copyWith(voteDetailsStatus: BlocStatus.failed, errorMessage: failure.message)),
      (result) => emit(state.copyWith(voteDetailsStatus: BlocStatus.success, voteDetails: result)),
    );
  }

  Future<void> _endVote(EndVoteEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(endVoteStatus: BlocStatus.loading));
    final response = await endVoteUseCase(EndVoteParams(voteId: event.voteId));
    response.fold(
      (failure) => emit(state.copyWith(endVoteStatus: BlocStatus.failed, errorMessage: failure.message)),
      (_) => emit(state.copyWith(endVoteStatus: BlocStatus.success, actionMessage: 'تم إنهاء التصويت بنجاح')),
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
    final label = (model.label ?? '').trim().isNotEmpty ? model.label! : 'العنوان';
    final lineParts = [
      model.city,
      model.neighborhood,
      model.street,
      if ((model.building ?? '').isNotEmpty) 'بناء ${model.building}',
      if ((model.floor ?? '').isNotEmpty) 'طابق ${model.floor}',
    ].where((part) => (part ?? '').trim().isNotEmpty).map((part) => part!.trim()).toList();
    return AddressListItem(
      id: model.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      line1: lineParts.isEmpty ? '-' : lineParts.join(' - '),
      landmark: model.directions,
      type: _mapAddressType(label),
      isDefault: model.isDefault,
    );
  }

  FetchNotificationsModelDataItem _toNotificationItem(NotificationResourceModel item) {
    return FetchNotificationsModelDataItem(
      type: item.type ?? 'system',
      title: item.title,
      body: item.body,
      createdAt: item.createdAt,
      isRead: item.readAt != null,
      showTrailingAccent: item.readAt == null,
    );
  }
}
