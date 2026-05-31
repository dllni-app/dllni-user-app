import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/realtime/pusher_manager.dart';
import 'package:dllni_user_app/features/profile/data/models/group_order_api_models.dart';
import 'package:dllni_user_app/features/profile/domain/models/personal_details_update_input.dart';
import 'package:dllni_user_app/features/profile/domain/repository/profile_repo.dart';
import 'package:dllni_user_app/features/profile/domain/repository/shopping_lists_repo.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/add_group_order_item_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/add_shopping_list_to_cart_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/cancel_group_order_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/create_address_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/create_group_order_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/create_shopping_list_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/create_vote_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/delete_address_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/delete_group_order_item_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/delete_shopping_list_item_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/end_vote_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/fetch_active_group_orders_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/fetch_active_votes_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/fetch_addresses_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/fetch_favorite_restaurants_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/fetch_group_order_menu_sections_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/fetch_notifications_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/fetch_shopping_list_detail_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/fetch_vote_suggestions_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/get_shopping_list_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/join_group_order_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/mark_all_notifications_read_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/mark_notification_read_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/place_group_order_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/remove_favorite_restaurant_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/set_default_address_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/show_group_order_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/show_vote_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/submit_group_order_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/submit_vote_ballot_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/unsubmit_group_order_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/update_address_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/update_group_order_item_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/update_shopping_list_item_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/update_shopping_list_use_case.dart';
import 'package:dllni_user_app/features/profile/view/manager/bloc/profile_bloc.dart';
import 'package:dllni_user_app/features/profile/view/screens/group_order_followup_screen.dart';
import 'package:dllni_user_app/features/profile/view/widgets/group_order_creator_submit_sheet.dart';
import 'package:dllni_user_app/features/profile/view/widgets/group_order_food_card.dart';
import 'package:dllni_user_app/features/profile/view/widgets/group_order_footer_bar.dart';
import 'package:dllni_user_app/features/rs_discover/domain/repository/rs_discover_repo.dart';
import 'package:dllni_user_app/features/rs_discover/domain/usecases/fetch_discover_restaurants_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeProfileRepo implements ProfileRepo {
  int joinCallCount = 0;
  int showCallCount = 0;
  int fetchMenuCallCount = 0;
  int addCallCount = 0;
  int deleteCallCount = 0;
  int submitCallCount = 0;
  int unsubmitCallCount = 0;
  int placeCallCount = 0;

  bool joinShouldFail = false;
  bool addShouldFail = false;
  bool deleteShouldFail = false;
  bool placeShouldFail = false;

  int currentUserId = 10;
  int _nextItemId = 7000;
  Completer<void>? joinGate;
  Completer<void>? addGate;
  Completer<void>? deleteGate;

  GroupOrderDetailsModel showDetails = const GroupOrderDetailsModel(
    groupOrder: GroupOrderCoreModel(id: 42, status: 'active', restaurantId: 7),
  );
  GroupOrderMenuSectionsResponseModel menuResponse =
      const GroupOrderMenuSectionsResponseModel(
        restaurantId: 7,
        sections: <GroupOrderMenuSectionModel>[
          GroupOrderMenuSectionModel(
            id: 1,
            name: 'Main',
            sortOrder: 1,
            items: <GroupOrderMenuSectionItemModel>[
              GroupOrderMenuSectionItemModel(
                id: 100,
                name: 'Menu Pizza',
                sectionName: 'Main',
              ),
            ],
          ),
        ],
      );

  @override
  DataResponse<GroupOrderActionModel> joinGroupOrder(
    JoinGroupOrderParams params,
  ) async {
    joinCallCount++;
    final gate = joinGate;
    if (gate != null) {
      await gate.future;
    }
    if (joinShouldFail) {
      return const Left(ServerFailure(message: 'join failed'));
    }
    return const Right(GroupOrderActionModel(message: 'joined'));
  }

  @override
  DataResponse<GroupOrderDetailsModel> showGroupOrder(
    ShowGroupOrderParams params,
  ) async {
    showCallCount++;
    return Right(showDetails);
  }

  @override
  DataResponse<GroupOrderMenuSectionsResponseModel> fetchGroupOrderMenuSections(
    FetchGroupOrderMenuSectionsParams params,
  ) async {
    fetchMenuCallCount++;
    return Right(menuResponse);
  }

  @override
  DataResponse<GroupOrderActionModel> addGroupOrderItem(
    AddGroupOrderItemParams params,
  ) async {
    addCallCount++;
    final gate = addGate;
    if (gate != null) {
      await gate.future;
    }
    if (addShouldFail) {
      return const Left(ServerFailure(message: 'add failed'));
    }
    final itemId = _nextItemId++;
    _mutateAddItem(productId: params.productId, itemId: itemId);
    return Right(GroupOrderActionModel(message: 'added', itemId: itemId));
  }

  @override
  DataResponse<GroupOrderActionModel> deleteGroupOrderItem(
    DeleteGroupOrderItemParams params,
  ) async {
    deleteCallCount++;
    final gate = deleteGate;
    if (gate != null) {
      await gate.future;
    }
    if (deleteShouldFail) {
      return const Left(ServerFailure(message: 'delete failed'));
    }
    _mutateDeleteItem(itemId: params.itemId);
    return const Right(GroupOrderActionModel(message: 'deleted'));
  }

  @override
  DataResponse<GroupOrderActionModel> submitGroupOrder(
    SubmitGroupOrderParams params,
  ) async {
    submitCallCount++;
    _mutateSubmissionState(submitted: true);
    return const Right(GroupOrderActionModel(message: 'submitted'));
  }

  @override
  DataResponse<GroupOrderActionModel> unsubmitGroupOrder(
    UnsubmitGroupOrderParams params,
  ) async {
    unsubmitCallCount++;
    _mutateSubmissionState(submitted: false);
    return const Right(GroupOrderActionModel(message: 'unsubmitted'));
  }

  @override
  DataResponse<GroupOrderActionModel> placeGroupOrder(
    PlaceGroupOrderParams params,
  ) async {
    placeCallCount++;
    if (placeShouldFail) {
      return const Left(ServerFailure(message: 'place failed'));
    }
    return const Right(GroupOrderActionModel(message: 'placed'));
  }

  GroupOrderParticipantModel _ensureCurrentParticipant(
    List<GroupOrderParticipantModel> participants,
  ) {
    for (final p in participants) {
      if (p.userId == currentUserId) return p;
    }
    final created = GroupOrderParticipantModel(
      userId: currentUserId,
      name: 'Me',
    );
    participants.add(created);
    return created;
  }

  void _mutateAddItem({required int productId, required int itemId}) {
    final participants = [...showDetails.participants];
    final me = _ensureCurrentParticipant(participants);
    final existingItems = [...me.items];
    if (existingItems.any((item) => item.productId == productId)) {
      return;
    }
    final product = menuResponse.sections
        .expand((e) => e.items)
        .firstWhere(
          (item) => item.id == productId,
          orElse: () => GroupOrderMenuSectionItemModel(
            id: productId,
            name: 'Item $productId',
            sectionName: 'Main',
          ),
        );
    existingItems.add(
      GroupOrderItemModel(
        itemId: itemId,
        productId: productId,
        name: product.name,
        quantity: 1,
        imageUrl: product.primaryImageUrl,
      ),
    );
    final nextParticipants = participants.map((p) {
      if (p.userId != currentUserId) return p;
      return GroupOrderParticipantModel(
        participantId: p.participantId,
        userId: p.userId,
        name: p.name,
        status: p.status,
        hasResponded: p.hasResponded,
        submittedAt: p.submittedAt,
        subtotal: p.subtotal,
        itemsCount: existingItems.length,
        items: existingItems,
      );
    }).toList();
    showDetails = GroupOrderDetailsModel(
      groupOrder: showDetails.groupOrder,
      participants: nextParticipants,
      counts: showDetails.counts,
      amounts: showDetails.amounts,
    );
  }

  void _mutateDeleteItem({required int itemId}) {
    final nextParticipants = showDetails.participants.map((p) {
      final items = p.items.where((e) => e.itemId != itemId).toList();
      return GroupOrderParticipantModel(
        participantId: p.participantId,
        userId: p.userId,
        name: p.name,
        status: p.status,
        hasResponded: p.hasResponded,
        submittedAt: p.submittedAt,
        subtotal: p.subtotal,
        itemsCount: items.length,
        items: items,
      );
    }).toList();
    showDetails = GroupOrderDetailsModel(
      groupOrder: showDetails.groupOrder,
      participants: nextParticipants,
      counts: showDetails.counts,
      amounts: showDetails.amounts,
    );
  }

  void _mutateSubmissionState({required bool submitted}) {
    final participants = [...showDetails.participants];
    final me = _ensureCurrentParticipant(participants);
    final updatedMe = GroupOrderParticipantModel(
      participantId: me.participantId,
      userId: me.userId,
      name: me.name,
      status: submitted ? 'submitted' : 'pending',
      hasResponded: submitted,
      submittedAt: submitted ? DateTime.now().toIso8601String() : null,
      subtotal: me.subtotal,
      itemsCount: me.items.length,
      items: me.items,
    );
    final nextParticipants = participants.map((participant) {
      if (participant.userId != currentUserId) {
        return participant;
      }
      return updatedMe;
    }).toList();
    showDetails = GroupOrderDetailsModel(
      groupOrder: showDetails.groupOrder,
      participants: nextParticipants,
      counts: showDetails.counts,
      amounts: showDetails.amounts,
    );
  }

  @override
  Future<void> updatePersonalDetails(PersonalDetailsUpdateInput input) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented in _FakeProfileRepo',
    );
  }
}

class _FakeShoppingListsRepo implements ShoppingListsRepo {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented in _FakeShoppingListsRepo',
    );
  }
}

class _FakeRsDiscoverRepo implements RsDiscoverRepo {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented in _FakeRsDiscoverRepo',
    );
  }
}

class _NoopPusherClientBridge implements PusherClientBridge {
  @override
  Future<void> init({
    required String apiKey,
    required String cluster,
    required bool useTls,
    required Future<Map<String, dynamic>> Function(
      String channelName,
      String socketId,
      dynamic options,
    )
    onAuthorizer,
    required void Function(String message, dynamic error) onSubscriptionError,
    required void Function(String message, int? code, dynamic error) onError,
    required void Function(String channelName, dynamic data)
    onSubscriptionSucceeded,
    required void Function(String currentState, String previousState)
    onConnectionStateChange,
    required void Function(PusherEvent event) onEvent,
  }) async {}

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> subscribe({required String channelName}) async {}

  @override
  Future<void> unsubscribe({required String channelName}) async {}
}

class _TestPusherManager extends PusherManager {
  _TestPusherManager() : super(clientBridge: _NoopPusherClientBridge());

  final Map<String, RealtimeEventCallback> _listenersByChannel =
      <String, RealtimeEventCallback>{};

  @override
  Future<RealtimeListenerHandle> listen({
    required String channelName,
    Set<String>? eventNames,
    RealtimeChannelErrorCallback? onChannelError,
    required RealtimeEventCallback onEvent,
  }) async {
    _listenersByChannel[channelName] = onEvent;
    return RealtimeListenerHandle(() async {
      _listenersByChannel.remove(channelName);
    });
  }

  void emitGroupOrderUpdated({
    required int groupOrderId,
    required Map<String, dynamic> payload,
  }) {
    final callback = _listenersByChannel['private-group-order.$groupOrderId'];
    if (callback == null) return;
    callback(
      RealtimeEvent(
        channelName: 'private-group-order.$groupOrderId',
        eventName: 'group-order.updated',
        payload: payload,
        receivedAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}

_TestPusherManager? _testPusherManager;

ProfileBloc _buildBloc(
  _FakeProfileRepo repo,
  _FakeRsDiscoverRepo rsRepo,
  _FakeShoppingListsRepo shoppingListsRepo,
) {
  return ProfileBloc(
    FetchAddressesUseCase(profileRepo: repo),
    SetDefaultAddressUseCase(rsProfileRepo: repo),
    FetchNotificationsUseCase(profileRepo: repo),
    MarkAllNotificationsReadUseCase(profileRepo: repo),
    MarkNotificationReadUseCase(profileRepo: repo),
    FetchFavoriteRestaurantsUseCase(profileRepo: repo),
    RemoveFavoriteRestaurantUseCase(profileRepo: repo),
    CreateVoteUseCase(profileRepo: repo),
    FetchVoteSuggestionsUseCase(profileRepo: repo),
    CreateAddressUseCase(profileRepo: repo),
    UpdateAddressUseCase(profileRepo: repo),
    DeleteAddressUseCase(profileRepo: repo),
    ShowVoteUseCase(profileRepo: repo),
    SubmitVoteBallotUseCase(profileRepo: repo),
    EndVoteUseCase(profileRepo: repo),
    FetchActiveVotesUseCase(profileRepo: repo),
    FetchDiscoverRestaurantsUseCase(rsDiscoverRepo: rsRepo),
    FetchGroupOrderMenuSectionsUseCase(profileRepo: repo),
    CreateGroupOrderUseCase(profileRepo: repo),
    JoinGroupOrderUseCase(profileRepo: repo),
    FetchActiveGroupOrdersUseCase(profileRepo: repo),
    ShowGroupOrderUseCase(profileRepo: repo),
    AddGroupOrderItemUseCase(profileRepo: repo),
    UpdateGroupOrderItemUseCase(profileRepo: repo),
    DeleteGroupOrderItemUseCase(profileRepo: repo),
    SubmitGroupOrderUseCase(profileRepo: repo),
    UnsubmitGroupOrderUseCase(profileRepo: repo),
    CancelGroupOrderUseCase(profileRepo: repo),
    PlaceGroupOrderUseCase(profileRepo: repo),
    GetShoppingListUseCase(profile: repo),
    FetchShoppingListDetailUseCase(shoppingListsRepo: shoppingListsRepo),
    CreateShoppingListUseCase(shoppingListsRepo: shoppingListsRepo),
    UpdateShoppingListUseCase(shoppingListsRepo: shoppingListsRepo),
    UpdateShoppingListItemUseCase(shoppingListsRepo: shoppingListsRepo),
    DeleteShoppingListItemUseCase(shoppingListsRepo: shoppingListsRepo),
    AddShoppingListToCartUseCase(shoppingListsRepo: shoppingListsRepo),
  );
}

Future<_FakeProfileRepo> _setUpTestDeps() async {
  SharedPreferences.setMockInitialValues(const <String, Object>{'customer_id': 10});
  await SharedPreferencesHelper.init();

  if (getIt.isRegistered<PusherManager>()) {
    await getIt.unregister<PusherManager>();
  }
  if (getIt.isRegistered<ProfileBloc>()) {
    await getIt.unregister<ProfileBloc>();
  }
  if (getIt.isRegistered<AddGroupOrderItemUseCase>()) {
    await getIt.unregister<AddGroupOrderItemUseCase>();
  }
  if (getIt.isRegistered<DeleteGroupOrderItemUseCase>()) {
    await getIt.unregister<DeleteGroupOrderItemUseCase>();
  }

  final repo = _FakeProfileRepo();
  final rsRepo = _FakeRsDiscoverRepo();
  final shoppingListsRepo = _FakeShoppingListsRepo();
  final pusherManager = _TestPusherManager();
  _testPusherManager = pusherManager;
  getIt.registerLazySingleton<PusherManager>(() => pusherManager);
  getIt.registerFactory<ProfileBloc>(
    () => _buildBloc(repo, rsRepo, shoppingListsRepo),
  );
  getIt.registerLazySingleton<AddGroupOrderItemUseCase>(
    () => AddGroupOrderItemUseCase(profileRepo: repo),
  );
  getIt.registerLazySingleton<DeleteGroupOrderItemUseCase>(
    () => DeleteGroupOrderItemUseCase(profileRepo: repo),
  );
  return repo;
}

Future<void> _tearDownTestDeps() async {
  if (getIt.isRegistered<PusherManager>()) {
    await getIt.unregister<PusherManager>();
  }
  if (getIt.isRegistered<ProfileBloc>()) {
    await getIt.unregister<ProfileBloc>();
  }
  if (getIt.isRegistered<AddGroupOrderItemUseCase>()) {
    await getIt.unregister<AddGroupOrderItemUseCase>();
  }
  if (getIt.isRegistered<DeleteGroupOrderItemUseCase>()) {
    await getIt.unregister<DeleteGroupOrderItemUseCase>();
  }
  _testPusherManager = null;
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required int groupOrderId,
  String? shareToken,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: GroupOrderFollowupScreen(
        params: GroupOrderFollowupScreenParams(
          groupOrderId: groupOrderId,
          shareToken: shareToken,
        ),
      ),
    ),
  );
}

Future<void> _pumpFor(WidgetTester tester, {int frames = 10}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _emitRealtimeGroupOrderUpdate(
  WidgetTester tester, {
  required Map<String, dynamic> payload,
  int groupOrderId = 42,
}) async {
  final manager = _testPusherManager;
  expect(manager, isNotNull);
  manager!.emitGroupOrderUpdated(groupOrderId: groupOrderId, payload: payload);
  await tester.pump();
}

Finder _findSummaryWithAll(List<String> fragments) {
  return find.byWidgetPredicate((widget) {
    if (widget is! Text) return false;
    final text = widget.data;
    if (text == null || text.isEmpty) return false;
    if (!text.contains('(')) return false;
    return fragments.every(text.contains);
  });
}

Future<void> _openCreatorReviewSheet(WidgetTester tester) async {
  final reviewButton = find.descendant(
    of: find.byType(GroupOrderFooterBar),
    matching: find.byType(ElevatedButton),
  );
  expect(reviewButton, findsOneWidget);
  await tester.tap(reviewButton);
  await _pumpFor(tester);
}

GroupOrderDetailsModel _memberDetails({
  List<GroupOrderItemModel> myItems = const <GroupOrderItemModel>[],
  bool hasResponded = false,
  String? submittedAt,
  String? status,
}) {
  return GroupOrderDetailsModel(
    groupOrder: const GroupOrderCoreModel(
      id: 42,
      status: 'active',
      isCreator: false,
      restaurantId: 7,
    ),
    participants: <GroupOrderParticipantModel>[
      GroupOrderParticipantModel(
        userId: 10,
        name: 'Me',
        status: status ?? (hasResponded ? 'submitted' : null),
        hasResponded: hasResponded,
        submittedAt:
            submittedAt ?? (hasResponded ? '2026-01-01T00:00:00Z' : null),
        itemsCount: myItems.length,
        items: myItems,
      ),
      const GroupOrderParticipantModel(userId: 11, name: 'Other'),
    ],
  );
}

GroupOrderDetailsModel _creatorDetails() {
  return const GroupOrderDetailsModel(
    groupOrder: GroupOrderCoreModel(
      id: 42,
      status: 'active',
      isCreator: true,
      creatorUserId: 10,
      restaurantId: 7,
    ),
    participants: <GroupOrderParticipantModel>[
      GroupOrderParticipantModel(
        participantId: 1,
        userId: 10,
        name: 'Creator',
        itemsCount: 1,
        items: <GroupOrderItemModel>[
          GroupOrderItemModel(
            itemId: 901,
            productId: 100,
            name: 'Creator Dish',
            quantity: 1,
          ),
        ],
      ),
      GroupOrderParticipantModel(
        participantId: 2,
        userId: 11,
        name: 'Ali',
        itemsCount: 1,
        items: <GroupOrderItemModel>[
          GroupOrderItemModel(
            itemId: 902,
            productId: 101,
            name: 'Ali Dish',
            quantity: 1,
          ),
        ],
      ),
    ],
  );
}

GroupOrderMenuSectionsResponseModel _menuData() {
  return const GroupOrderMenuSectionsResponseModel(
    restaurantId: 7,
    sections: <GroupOrderMenuSectionModel>[
      GroupOrderMenuSectionModel(
        id: 1,
        name: 'Main',
        sortOrder: 1,
        items: <GroupOrderMenuSectionItemModel>[
          GroupOrderMenuSectionItemModel(
            id: 100,
            name: 'Menu Pizza',
            sectionName: 'Main',
          ),
          GroupOrderMenuSectionItemModel(
            id: 101,
            name: 'Menu Pasta',
            sectionName: 'Main',
          ),
        ],
      ),
    ],
  );
}

GroupOrderFoodCard _findOptionCardByName(WidgetTester tester, String name) {
  final cards = tester
      .widgetList<GroupOrderFoodCard>(find.byType(GroupOrderFoodCard))
      .toList();
  for (final card in cards) {
    if (card.row.name == name && card.row.quantity == 0) {
      return card;
    }
  }
  return cards.firstWhere((card) => card.row.name == name);
}

void main() {
  tearDown(() async {
    await _tearDownTestDeps();
  });

  testWidgets(
    'share-token entry dispatches join first, then show after success',
    (WidgetTester tester) async {
      final repo = await _setUpTestDeps();
      repo.joinGate = Completer<void>();

      await _pumpScreen(tester, groupOrderId: 42, shareToken: 'share-abc');
      await tester.pump();

      expect(repo.joinCallCount, 1);
      expect(repo.showCallCount, 0);

      repo.joinGate!.complete();
      await _pumpFor(tester);

      expect(repo.showCallCount, 1);
    },
  );

  testWidgets('share-token entry does not dispatch show when join fails', (
    WidgetTester tester,
  ) async {
    final repo = await _setUpTestDeps();
    repo.joinShouldFail = true;

    await _pumpScreen(tester, groupOrderId: 42, shareToken: 'share-abc');
    await _pumpFor(tester);

    expect(repo.joinCallCount, 1);
    expect(repo.showCallCount, 0);
  });

  testWidgets(
    'in-app entry without share token fetches immediately without joining',
    (WidgetTester tester) async {
      final repo = await _setUpTestDeps();

      await _pumpScreen(tester, groupOrderId: 42);
      await _pumpFor(tester);

      expect(repo.joinCallCount, 0);
      expect(repo.showCallCount, 1);
    },
  );

  testWidgets(
    'member view shows send footer and hides multi-select add button',
    (WidgetTester tester) async {
      final repo = await _setUpTestDeps();
      repo.showDetails = _memberDetails();
      repo.menuResponse = _menuData();

      await _pumpScreen(tester, groupOrderId: 42);
      await _pumpFor(tester);

      expect(find.byType(GroupOrderFooterBar), findsOneWidget);
      expect(find.text('إرسال اختياراتي'), findsOneWidget);
      expect(find.text('إضافة خيارات متعددة'), findsNothing);

      final sendButtonFinder = find.descendant(
        of: find.byType(GroupOrderFooterBar),
        matching: find.byType(ElevatedButton),
      );
      final sendButton = tester.widget<ElevatedButton>(sendButtonFinder);
      expect(sendButton.onPressed, isNull);
    },
  );

  testWidgets('member send action dispatches submit group order', (
    WidgetTester tester,
  ) async {
    final repo = await _setUpTestDeps();
    repo.showDetails = _memberDetails(
      myItems: const <GroupOrderItemModel>[
        GroupOrderItemModel(
          itemId: 901,
          productId: 100,
          name: 'Menu Pizza',
          quantity: 1,
        ),
      ],
    );
    repo.menuResponse = _menuData();

    await _pumpScreen(tester, groupOrderId: 42);
    await _pumpFor(tester);

    expect(find.text('إرسال اختياراتي'), findsOneWidget);
    await tester.tap(find.text('إرسال اختياراتي'));
    await _pumpFor(tester);

    expect(repo.submitCallCount, 1);
    expect(repo.unsubmitCallCount, 0);
    expect(find.text('إلغاء الإرسال'), findsOneWidget);
  });

  testWidgets('member unsend action dispatches unsubmit group order', (
    WidgetTester tester,
  ) async {
    final repo = await _setUpTestDeps();
    repo.showDetails = _memberDetails(hasResponded: true);
    repo.menuResponse = _menuData();

    await _pumpScreen(tester, groupOrderId: 42);
    await _pumpFor(tester);

    expect(find.text('إلغاء الإرسال'), findsOneWidget);
    await tester.tap(find.text('إلغاء الإرسال'));
    await _pumpFor(tester);

    expect(repo.unsubmitCallCount, 1);
    expect(repo.submitCallCount, 0);
    expect(find.text('إرسال اختياراتي'), findsOneWidget);
  });

  testWidgets(
    'member tap selects product locally and updates selected foods immediately',
    (WidgetTester tester) async {
      final repo = await _setUpTestDeps();
      repo.showDetails = _memberDetails();
      repo.menuResponse = _menuData();
      repo.addGate = Completer<void>();

      await _pumpScreen(tester, groupOrderId: 42);
      await _pumpFor(tester);

      expect(_findSummaryWithAll(const <String>['Menu Pizza']), findsNothing);

      await tester.tap(find.byType(GroupOrderFoodCard).first);
      await tester.pump();

      expect(repo.addCallCount, 1);
      expect(_findSummaryWithAll(const <String>['Menu Pizza']), findsOneWidget);
      expect(_findOptionCardByName(tester, 'Menu Pizza').isSelected, isTrue);

      repo.addGate!.complete();
      await _pumpFor(tester);
    },
  );

  testWidgets('member add failure rolls back optimistic selection', (
    WidgetTester tester,
  ) async {
    final repo = await _setUpTestDeps();
    repo.showDetails = _memberDetails();
    repo.menuResponse = _menuData();
    repo.addShouldFail = true;
    repo.addGate = Completer<void>();

    await _pumpScreen(tester, groupOrderId: 42);
    await _pumpFor(tester);

    await tester.tap(find.byType(GroupOrderFoodCard).first);
    await tester.pump();
    expect(_findOptionCardByName(tester, 'Menu Pizza').isSelected, isTrue);

    repo.addGate!.complete();
    await _pumpFor(tester);
    expect(repo.addCallCount, 1);
    expect(_findSummaryWithAll(const <String>['Menu Pizza']), findsNothing);
    expect(_findOptionCardByName(tester, 'Menu Pizza').isSelected, isFalse);
  });

  testWidgets('member delete failure rolls back optimistic unselect', (
    WidgetTester tester,
  ) async {
    final repo = await _setUpTestDeps();
    repo.showDetails = _memberDetails();
    repo.menuResponse = _menuData();

    await _pumpScreen(tester, groupOrderId: 42);
    await _pumpFor(tester);

    await tester.tap(find.byType(GroupOrderFoodCard).first);
    await _pumpFor(tester);
    expect(repo.addCallCount, 1);
    expect(_findOptionCardByName(tester, 'Menu Pizza').isSelected, isTrue);

    repo.deleteShouldFail = true;
    repo.deleteGate = Completer<void>();
    await tester.tap(find.byType(GroupOrderFoodCard).first);
    await tester.pump();
    expect(_findOptionCardByName(tester, 'Menu Pizza').isSelected, isFalse);

    repo.deleteGate!.complete();
    await _pumpFor(tester);
    expect(repo.deleteCallCount, 1);
    expect(_findOptionCardByName(tester, 'Menu Pizza').isSelected, isTrue);
  });

  testWidgets('creator submit opens grouped review sheet', (
    WidgetTester tester,
  ) async {
    final repo = await _setUpTestDeps();
    repo.showDetails = _creatorDetails();
    repo.menuResponse = _menuData();

    await _pumpScreen(tester, groupOrderId: 42);
    await _pumpFor(tester);

    await _openCreatorReviewSheet(tester);

    final sheet = find.byType(GroupOrderCreatorSubmitSheet);
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(of: sheet, matching: find.text('1- Creator')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('2- Ali')),
      findsOneWidget,
    );
    expect(_findSummaryWithAll(const <String>['Creator Dish']), findsWidgets);
  });

  testWidgets('creator can delete item from review sheet', (
    WidgetTester tester,
  ) async {
    final repo = await _setUpTestDeps();
    repo.showDetails = _creatorDetails();
    repo.menuResponse = _menuData();

    await _pumpScreen(tester, groupOrderId: 42);
    await _pumpFor(tester);

    await _openCreatorReviewSheet(tester);

    final sheet = find.byType(GroupOrderCreatorSubmitSheet);
    final creatorDish = find.descendant(
      of: sheet,
      matching: find.textContaining('Creator Dish'),
    );
    final aliDish = find.descendant(
      of: sheet,
      matching: find.textContaining('Ali Dish'),
    );
    expect(creatorDish, findsWidgets);
    expect(aliDish, findsWidgets);
    final beforeTotal =
        creatorDish.evaluate().length + aliDish.evaluate().length;

    final deleteButtons = find.descendant(
      of: sheet,
      matching: find.byIcon(Icons.delete_outline),
    );
    await tester.ensureVisible(deleteButtons.first);
    await tester.tap(deleteButtons.first, warnIfMissed: false);
    await _pumpFor(tester);

    expect(repo.deleteCallCount, 1);
    final afterTotal =
        find
            .descendant(
              of: sheet,
              matching: find.textContaining('Creator Dish'),
            )
            .evaluate()
            .length +
        find
            .descendant(of: sheet, matching: find.textContaining('Ali Dish'))
            .evaluate()
            .length;
    expect(afterTotal, lessThan(beforeTotal));
  });

  testWidgets(
    'member can select multiple products from same category and summary keeps both',
    (WidgetTester tester) async {
      final repo = await _setUpTestDeps();
      repo.showDetails = _memberDetails();
      repo.menuResponse = _menuData();

      await _pumpScreen(tester, groupOrderId: 42);
      await _pumpFor(tester);

      await tester.tap(find.byType(GroupOrderFoodCard).at(0));
      await _pumpFor(tester);
      await tester.tap(find.byType(GroupOrderFoodCard).at(1));
      await _pumpFor(tester);

      expect(_findOptionCardByName(tester, 'Menu Pizza').isSelected, isTrue);
      expect(_findOptionCardByName(tester, 'Menu Pasta').isSelected, isTrue);
      expect(
        _findSummaryWithAll(const <String>['Menu Pizza', 'Menu Pasta']),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'partial realtime payload keeps creator mode and participant selections',
    (WidgetTester tester) async {
      final repo = await _setUpTestDeps();
      repo.showDetails = _creatorDetails();
      repo.menuResponse = _menuData();

      await _pumpScreen(tester, groupOrderId: 42);
      await _pumpFor(tester);

      expect(find.byType(GroupOrderFooterBar), findsOneWidget);
      expect(
        _findSummaryWithAll(const <String>['Creator Dish']),
        findsOneWidget,
      );

      await _emitRealtimeGroupOrderUpdate(
        tester,
        payload: <String, dynamic>{
          'groupOrder': <String, dynamic>{'id': 42, 'status': 'active'},
        },
      );
      await _pumpFor(tester, frames: 3);

      expect(find.byType(GroupOrderFooterBar), findsOneWidget);
      expect(
        _findSummaryWithAll(const <String>['Creator Dish']),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'counts-only realtime payload triggers fallback refresh instead of hydration',
    (WidgetTester tester) async {
      final repo = await _setUpTestDeps();
      repo.showDetails = _memberDetails();
      repo.menuResponse = _menuData();

      await _pumpScreen(tester, groupOrderId: 42);
      await _pumpFor(tester);
      final initialShowCalls = repo.showCallCount;

      await _emitRealtimeGroupOrderUpdate(
        tester,
        payload: <String, dynamic>{
          'counts': <String, dynamic>{'participants': 2, 'responded': 1},
        },
      );
      await _pumpFor(tester, frames: 4);

      expect(repo.showCallCount, greaterThan(initialShowCalls));
    },
  );
  testWidgets('creator submit from review sheet triggers place order', (
    WidgetTester tester,
  ) async {
    final repo = await _setUpTestDeps();
    repo.showDetails = _creatorDetails();
    repo.menuResponse = _menuData();

    await _pumpScreen(tester, groupOrderId: 42);
    await _pumpFor(tester);

    await _openCreatorReviewSheet(tester);

    final submitButton = find.descendant(
      of: find.byType(GroupOrderCreatorSubmitSheet),
      matching: find.byType(ElevatedButton),
    );
    await tester.tap(submitButton);
    await _pumpFor(tester);

    expect(repo.placeCallCount, 1);
  });
}
