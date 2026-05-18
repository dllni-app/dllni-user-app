import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_share_targets.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/realtime/pusher_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/group_order_api_models.dart';
import '../../domain/usecases/add_group_order_item_use_case.dart';
import '../../domain/usecases/cancel_group_order_use_case.dart';
import '../../domain/usecases/delete_group_order_item_use_case.dart';
import '../../domain/usecases/join_group_order_use_case.dart';
import '../../domain/usecases/place_group_order_use_case.dart';
import '../../domain/usecases/show_group_order_use_case.dart';
import '../../domain/usecases/submit_group_order_use_case.dart';
import '../../domain/usecases/unsubmit_group_order_use_case.dart';
import '../manager/bloc/profile_bloc.dart';
import '../widgets/expandable_numbered_section.dart';
import '../widgets/group_order_creator_participants_items_section.dart';
import '../widgets/group_order_creator_submit_sheet.dart';
import '../widgets/group_order_footer_bar.dart';
import '../widgets/group_order_food_row.dart';
import '../widgets/group_order_menu_multi_select_sheet.dart';
import '../widgets/group_order_options_section.dart';
import '../widgets/group_order_requested_foods_section.dart';
import '../widgets/personal_details_app_bar.dart';
import 'group_order_member_requested_foods.dart';

class GroupOrderFollowupScreenParams {
  final int groupOrderId;
  final bool needShare;
  final String? shareToken;

  const GroupOrderFollowupScreenParams({
    required this.groupOrderId,
    this.needShare = false,
    this.shareToken,
  });
}

@AutoRoutePage(path: '/group-order/followup')
class GroupOrderFollowupScreen extends StatelessWidget {
  const GroupOrderFollowupScreen({super.key, required this.params});

  final GroupOrderFollowupScreenParams params;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => getIt<ProfileBloc>(),
      child: _GroupOrderFollowupBody(params: params),
    );
  }
}

class _GroupOrderFollowupBody extends StatefulWidget {
  const _GroupOrderFollowupBody({required this.params});

  final GroupOrderFollowupScreenParams params;

  @override
  State<_GroupOrderFollowupBody> createState() =>
      _GroupOrderFollowupBodyState();
}

class _GroupOrderFollowupBodyState extends State<_GroupOrderFollowupBody> {
  static const Duration _fallbackDebounce = Duration(milliseconds: 150);

  final PusherManager _pusherManager = getIt<PusherManager>();
  final Set<int> _selectedProductIds = <int>{};
  final Set<int> _syncingProductIds = <int>{};
  final Map<int, int> _itemIdByProductId = <int, int>{};
  final Map<int, _PendingSelectionOp> _pendingSelectionOps =
      <int, _PendingSelectionOp>{};

  RealtimeListenerHandle? _groupOrderRealtimeHandle;
  Timer? _groupOrderFallbackRefreshDebounce;
  bool _isOptionsExpanded = true;
  bool _isSecondSectionExpanded = true;
  bool _showDispatchedAfterJoin = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _readLoggedInCustomerId();
    if (widget.params.needShare) {
      unawaited(
        shareDeepLinkUrl(
          groupOrderUrl(id: widget.params.groupOrderId),
          context: context,
        ),
      );
    }
    _dispatchInitialLoad();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectRealtime();
    });
  }

  @override
  void dispose() {
    _groupOrderFallbackRefreshDebounce?.cancel();
    final handle = _groupOrderRealtimeHandle;
    _groupOrderRealtimeHandle = null;
    if (handle != null) {
      unawaited(handle.dispose());
    }
    super.dispose();
  }

  void _dispatchInitialLoad() {
    final shareToken = widget.params.shareToken?.trim();
    final bloc = context.read<ProfileBloc>();
    if (shareToken != null && shareToken.isNotEmpty) {
      bloc.add(
        JoinGroupOrderEvent(
          params: JoinGroupOrderParams(shareToken: shareToken),
        ),
      );
      return;
    }
    bloc.add(
      ShowGroupOrderEvent(
        params: ShowGroupOrderParams(groupOrderId: widget.params.groupOrderId),
      ),
    );
  }

  Future<void> _connectRealtime() async {
    if (!mounted) return;
    final channelName = 'private-group-order.${widget.params.groupOrderId}';
    try {
      _groupOrderRealtimeHandle = await _pusherManager.listen(
        channelName: channelName,
        eventNames: const <String>{'group-order.updated'},
        onEvent: _onGroupOrderRealtimeEvent,
      );
    } catch (e, st) {
      debugPrint('GroupOrder Pusher connect failed: $e\n$st');
    }
  }

  void _onGroupOrderRealtimeEvent(RealtimeEvent event) {
    if (!mounted) return;
    final payload = _extractGroupOrderPayload(event.payload);
    final hasHydratablePayload = _hasHydratableGroupOrderPayload(payload);
    if (hasHydratablePayload) {
      context.read<ProfileBloc>().add(
        HydrateGroupOrderFromPayloadEvent(payload: payload),
      );
      return;
    }
    _scheduleGroupOrderFallbackRefresh(
      fallbackReason: 'missing_group_order_payload_fields',
    );
  }

  void _scheduleGroupOrderFallbackRefresh({required String fallbackReason}) {
    _groupOrderFallbackRefreshDebounce?.cancel();
    _groupOrderFallbackRefreshDebounce = Timer(_fallbackDebounce, () {
      if (!mounted) return;
      context.read<ProfileBloc>().add(
        ShowGroupOrderEvent(
          params: ShowGroupOrderParams(
            groupOrderId: widget.params.groupOrderId,
          ),
          skipMenuFetch: true,
          fallbackReason: fallbackReason,
        ),
      );
    });
  }

  Map<String, dynamic> _extractGroupOrderPayload(Map<String, dynamic> payload) {
    if (payload['groupOrder'] is Map ||
        payload['group_order'] is Map ||
        payload['participants'] is List) {
      return payload;
    }
    if (payload['data'] is Map) {
      return Map<String, dynamic>.from(payload['data'] as Map);
    }
    return payload;
  }

  bool _hasHydratableGroupOrderPayload(Map<String, dynamic> payload) {
    return payload['groupOrder'] is Map ||
        payload['group_order'] is Map ||
        payload['participants'] is List;
  }

  List<GroupOrderFoodRow> _buildAllMenuFoods(ProfileState state) {
    final rows = <GroupOrderFoodRow>[];
    for (final section in state.groupOrderMenuSections) {
      for (final item in section.items) {
        final price = item.displayPrice;
        final currency = item.currency ?? '';
        final subtitle = price != null ? 'السعر: $price $currency'.trim() : '';
        rows.add(
          GroupOrderFoodRow(
            itemId: null,
            productId: item.id,
            name: item.name.isEmpty ? '-' : item.name,
            quantity: 0,
            type: section.name.trim().isEmpty ? 'غير مصنف' : section.name,
            subtitle: subtitle,
            imageUrl: item.primaryImageUrl,
            sizeLabel: (item.sizeLabel ?? '').trim().isEmpty
                ? null
                : item.sizeLabel,
          ),
        );
      }
    }
    return rows;
  }

  int? _readLoggedInCustomerId() {
    final raw = SharedPreferencesHelper.getData(key: 'customer_id');
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw.trim());
    return null;
  }

  int? _effectiveCurrentUserId(GroupOrderDetailsModel details) {
    final localId = _currentUserId;
    if (localId != null && localId > 0) return localId;
    final creatorId = details.groupOrder?.creatorUserId;
    if ((details.groupOrder?.isCreator ?? false) &&
        creatorId != null &&
        creatorId > 0) {
      return creatorId;
    }
    return null;
  }

  Map<int, String> _buildTypeByProductId(ProfileState state) {
    final map = <int, String>{};
    for (final product in state.groupOrderMenuProducts) {
      final id = product.id;
      if (id == null || id <= 0) continue;
      final type = product.sectionName.trim();
      map[id] = type.isEmpty ? 'غير مصنف' : type;
    }
    return map;
  }

  List<String> _availableTypes(ProfileState state) {
    final types = <String>[];
    for (final section in state.groupOrderMenuSections) {
      final type = section.name.trim();
      if (type.isEmpty) continue;
      types.add(type);
    }
    return types;
  }

  Map<int, GroupOrderMenuSectionItemModel> _menuByProductId(
    ProfileState state,
  ) {
    final map = <int, GroupOrderMenuSectionItemModel>{};
    for (final item in state.groupOrderMenuProducts) {
      final id = item.id;
      if (id == null || id <= 0) continue;
      map[id] = item;
    }
    return map;
  }

  Map<int, GroupOrderItemModel> _currentUserItemsByProduct(
    GroupOrderDetailsModel details,
  ) {
    final userId = _effectiveCurrentUserId(details);
    if (userId == null || userId <= 0) {
      return const <int, GroupOrderItemModel>{};
    }
    GroupOrderParticipantModel? me;
    for (final participant in details.participants) {
      if (participant.userId != null && participant.userId == userId) {
        me = participant;
        break;
      }
    }
    if (me == null) {
      return const <int, GroupOrderItemModel>{};
    }
    final map = <int, GroupOrderItemModel>{};
    for (final item in me.items) {
      final pid = item.productId;
      if (pid == null || pid <= 0) continue;
      map[pid] = item;
    }
    return map;
  }

  void _syncLocalSelectionFromDetails(GroupOrderDetailsModel details) {
    final effectiveUserId = _effectiveCurrentUserId(details);
    if (effectiveUserId == null || effectiveUserId <= 0) {
      return;
    }
    final serverItems = _currentUserItemsByProduct(details);
    final nextSelected = serverItems.keys.toSet();
    final nextItemIds = <int, int>{};
    for (final entry in serverItems.entries) {
      final itemId = entry.value.itemId;
      if (itemId != null && itemId > 0) {
        nextItemIds[entry.key] = itemId;
      }
    }

    for (final entry in _pendingSelectionOps.entries) {
      final productId = entry.key;
      final op = entry.value;
      if (op == _PendingSelectionOp.add) {
        nextSelected.add(productId);
      } else {
        nextSelected.remove(productId);
      }
    }

    for (final entry in _pendingSelectionOps.entries) {
      if (entry.value != _PendingSelectionOp.remove) continue;
      final cachedId = _itemIdByProductId[entry.key];
      if (cachedId != null && cachedId > 0) {
        nextItemIds[entry.key] = cachedId;
      }
    }

    if (_sameIntSet(_selectedProductIds, nextSelected) &&
        _sameIntMap(_itemIdByProductId, nextItemIds)) {
      return;
    }

    setState(() {
      _selectedProductIds
        ..clear()
        ..addAll(nextSelected);
      _itemIdByProductId
        ..clear()
        ..addAll(nextItemIds);
    });
  }

  bool _sameIntSet(Set<int> a, Set<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final value in a) {
      if (!b.contains(value)) return false;
    }
    return true;
  }

  bool _sameIntMap(Map<int, int> a, Map<int, int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  List<int> _orderedSelectedProductIds(ProfileState state) {
    final ordered = <int>[];
    final seen = <int>{};
    for (final item in state.groupOrderMenuProducts) {
      final id = item.id;
      if (id == null || id <= 0) continue;
      if (_selectedProductIds.contains(id) && seen.add(id)) {
        ordered.add(id);
      }
    }
    for (final id in _selectedProductIds) {
      if (seen.add(id)) {
        ordered.add(id);
      }
    }
    return ordered;
  }

  GroupOrderFoodRow _optimisticRowForProduct({
    required int productId,
    required Map<int, GroupOrderMenuSectionItemModel> menuByProductId,
  }) {
    final menu = menuByProductId[productId];
    final price = menu?.displayPrice;
    final currency = menu?.currency ?? '';
    return GroupOrderFoodRow(
      itemId: _itemIdByProductId[productId],
      productId: productId,
      name: (menu?.name ?? '').trim().isEmpty ? '-' : menu!.name,
      quantity: 1,
      type: menu == null || menu.sectionName.trim().isEmpty
          ? 'غير مصنف'
          : menu.sectionName,
      subtitle: price != null ? 'السعر: $price $currency'.trim() : '',
      imageUrl: menu?.primaryImageUrl,
      sizeLabel: (menu?.sizeLabel ?? '').trim().isEmpty
          ? null
          : menu?.sizeLabel,
    );
  }

  GroupOrderParticipantModel? _currentUserParticipant(
    GroupOrderDetailsModel details,
  ) {
    final userId = _effectiveCurrentUserId(details);
    if (userId == null || userId <= 0) return null;
    for (final participant in details.participants) {
      if (participant.userId != null && participant.userId == userId) {
        return participant;
      }
    }
    return null;
  }

  bool _isCurrentMemberSubmitted(GroupOrderDetailsModel details) {
    final me = _currentUserParticipant(details);
    if (me == null) return false;
    if (me.hasResponded) return true;
    if ((me.submittedAt ?? '').trim().isNotEmpty) return true;
    final status = (me.status ?? '').trim().toLowerCase();
    if (status.isEmpty) return false;
    return status == 'submitted' ||
        status == 'responded' ||
        status == 'done' ||
        status == 'completed';
  }

  List<GroupOrderFoodRow> _buildCurrentUserRequestedFoods({
    required GroupOrderDetailsModel details,
    required ProfileState state,
  }) {
    final typeByProduct = _buildTypeByProductId(state);
    final serverRows = buildMemberRequestedFoodRows(
      details: details,
      typeByProductId: typeByProduct,
      currentUserId: _effectiveCurrentUserId(details),
    );
    final menuByProduct = _menuByProductId(state);
    final serverByProductId = <int, GroupOrderFoodRow>{};
    for (final row in serverRows) {
      final pid = row.productId;
      if (pid == null || pid <= 0) continue;
      serverByProductId[pid] = row;
    }

    final rows = <GroupOrderFoodRow>[];
    final orderedIds = _orderedSelectedProductIds(state);
    for (final pid in orderedIds) {
      final server = serverByProductId[pid];
      if (server != null) {
        rows.add(
          GroupOrderFoodRow(
            itemId: server.itemId ?? _itemIdByProductId[pid],
            productId: server.productId,
            name: server.name,
            quantity: server.quantity,
            type: server.type,
            subtitle: server.subtitle,
            imageUrl: server.imageUrl,
            sizeLabel: server.sizeLabel,
          ),
        );
      } else {
        rows.add(
          _optimisticRowForProduct(
            productId: pid,
            menuByProductId: menuByProduct,
          ),
        );
      }
    }

    for (final row in serverRows) {
      if (row.productId == null || row.productId! <= 0) {
        rows.add(row);
      }
    }

    return rows;
  }

  GroupOrderItemModel _optimisticItemForProduct({
    required int productId,
    required Map<int, GroupOrderMenuSectionItemModel> menuByProductId,
  }) {
    final menu = menuByProductId[productId];
    return GroupOrderItemModel(
      itemId: _itemIdByProductId[productId],
      productId: productId,
      name: (menu?.name ?? '').trim().isEmpty ? '-' : menu!.name,
      quantity: 1,
      unitPrice: menu?.displayPrice,
      imageUrl: menu?.primaryImageUrl,
    );
  }

  GroupOrderDetailsModel _buildCreatorMergedDetails({
    required GroupOrderDetailsModel details,
    required ProfileState state,
  }) {
    final userId = _effectiveCurrentUserId(details);
    if (userId == null || userId <= 0) {
      return details;
    }
    final menuByProductId = _menuByProductId(state);
    var foundMine = false;
    final participants = details.participants.map((participant) {
      if (participant.userId == null || participant.userId != userId) {
        return participant;
      }
      foundMine = true;
      final serverByProductId = <int, GroupOrderItemModel>{};
      final orphanItems = <GroupOrderItemModel>[];
      for (final item in participant.items) {
        final pid = item.productId;
        if (pid == null || pid <= 0) {
          orphanItems.add(item);
          continue;
        }
        serverByProductId[pid] = item;
      }
      final nextItems = <GroupOrderItemModel>[];
      for (final productId in _orderedSelectedProductIds(state)) {
        nextItems.add(
          serverByProductId[productId] ??
              _optimisticItemForProduct(
                productId: productId,
                menuByProductId: menuByProductId,
              ),
        );
      }
      nextItems.addAll(orphanItems);
      return GroupOrderParticipantModel(
        participantId: participant.participantId,
        userId: participant.userId,
        name: participant.name,
        status: participant.status,
        hasResponded: participant.hasResponded,
        submittedAt: participant.submittedAt,
        subtotal: participant.subtotal,
        itemsCount: nextItems.length,
        items: nextItems,
      );
    }).toList();

    if (!foundMine && _selectedProductIds.isNotEmpty) {
      participants.add(
        GroupOrderParticipantModel(
          userId: userId,
          name: 'أنا',
          itemsCount: _selectedProductIds.length,
          items: _orderedSelectedProductIds(state)
              .map(
                (productId) => _optimisticItemForProduct(
                  productId: productId,
                  menuByProductId: menuByProductId,
                ),
              )
              .toList(),
        ),
      );
    }

    return GroupOrderDetailsModel(
      groupOrder: details.groupOrder,
      participants: participants,
      counts: details.counts,
      amounts: details.amounts,
    );
  }

  String _currentUserDisplayName(GroupOrderDetailsModel details) {
    final userId = _effectiveCurrentUserId(details);
    if (userId == null || userId <= 0) return '\u0623\u0646\u0627';
    for (final participant in details.participants) {
      if (participant.userId == null || participant.userId != userId) {
        continue;
      }
      final name = (participant.name ?? '').trim();
      return name.isEmpty ? '\u0623\u0646\u0627' : name;
    }
    return '\u0623\u0646\u0627';
  }

  void _showSyncError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.isEmpty ? 'تعذر مزامنة اختيارك الآن' : message),
      ),
    );
  }

  Future<bool> _addSelectedProduct({
    required int groupOrderId,
    required int productId,
  }) async {
    if (_syncingProductIds.contains(productId)) return false;
    setState(() {
      _selectedProductIds.add(productId);
      _pendingSelectionOps[productId] = _PendingSelectionOp.add;
      _syncingProductIds.add(productId);
    });

    final result = await getIt<AddGroupOrderItemUseCase>()(
      AddGroupOrderItemParams(groupOrderId: groupOrderId, productId: productId),
    );
    if (!mounted) return false;

    return result.fold(
      (failure) {
        setState(() {
          _selectedProductIds.remove(productId);
          _pendingSelectionOps.remove(productId);
          _syncingProductIds.remove(productId);
          _itemIdByProductId.remove(productId);
        });
        _showSyncError(failure.message);
        _scheduleGroupOrderFallbackRefresh(
          fallbackReason: 'local_add_item_failed',
        );
        return false;
      },
      (action) {
        setState(() {
          _selectedProductIds.add(productId);
          _pendingSelectionOps.remove(productId);
          _syncingProductIds.remove(productId);
          final itemId = action.itemId;
          if (itemId != null && itemId > 0) {
            _itemIdByProductId[productId] = itemId;
          }
        });
        return true;
      },
    );
  }

  Future<bool> _removeSelectedProduct({
    required int groupOrderId,
    required int productId,
    int? forcedItemId,
    bool refreshAfterSuccess = false,
  }) async {
    if (_syncingProductIds.contains(productId)) return false;
    final previousItemId = _itemIdByProductId[productId] ?? forcedItemId;
    if (previousItemId == null || previousItemId <= 0) {
      _showSyncError('تعذر حذف العنصر الآن. حاول بعد لحظات.');
      _scheduleGroupOrderFallbackRefresh(
        fallbackReason: 'missing_item_id_for_delete',
      );
      return false;
    }

    setState(() {
      _selectedProductIds.remove(productId);
      _pendingSelectionOps[productId] = _PendingSelectionOp.remove;
      _syncingProductIds.add(productId);
    });

    final result = await getIt<DeleteGroupOrderItemUseCase>()(
      DeleteGroupOrderItemParams(
        groupOrderId: groupOrderId,
        itemId: previousItemId,
      ),
    );
    if (!mounted) return false;

    return result.fold(
      (failure) {
        setState(() {
          _selectedProductIds.add(productId);
          _pendingSelectionOps.remove(productId);
          _syncingProductIds.remove(productId);
          _itemIdByProductId[productId] = previousItemId;
        });
        _showSyncError(failure.message);
        _scheduleGroupOrderFallbackRefresh(
          fallbackReason: 'local_delete_item_failed',
        );
        return false;
      },
      (_) {
        setState(() {
          _selectedProductIds.remove(productId);
          _pendingSelectionOps.remove(productId);
          _syncingProductIds.remove(productId);
          _itemIdByProductId.remove(productId);
        });
        if (refreshAfterSuccess) {
          context.read<ProfileBloc>().add(
            ShowGroupOrderEvent(
              params: ShowGroupOrderParams(groupOrderId: groupOrderId),
              skipMenuFetch: true,
            ),
          );
        }
        return true;
      },
    );
  }

  Future<bool> _deleteParticipantItem({
    required int groupOrderId,
    required GroupOrderItemModel item,
    bool refreshAfterSuccess = true,
  }) async {
    final itemId = item.itemId;
    if (itemId == null || itemId <= 0) {
      _showSyncError('تعذر حذف العنصر الآن');
      return false;
    }

    final pid = item.productId;
    if (pid != null && pid > 0) {
      if (_syncingProductIds.contains(pid)) return false;
      setState(() {
        _syncingProductIds.add(pid);
      });
    }

    final result = await getIt<DeleteGroupOrderItemUseCase>()(
      DeleteGroupOrderItemParams(groupOrderId: groupOrderId, itemId: itemId),
    );
    if (!mounted) return false;

    return result.fold(
      (failure) {
        if (pid != null && pid > 0) {
          setState(() {
            _syncingProductIds.remove(pid);
          });
        }
        _showSyncError(failure.message);
        _scheduleGroupOrderFallbackRefresh(
          fallbackReason: 'creator_delete_item_failed',
        );
        return false;
      },
      (_) {
        if (pid != null && pid > 0) {
          setState(() {
            _syncingProductIds.remove(pid);
          });
        }
        if (refreshAfterSuccess) {
          context.read<ProfileBloc>().add(
            ShowGroupOrderEvent(
              params: ShowGroupOrderParams(groupOrderId: groupOrderId),
              skipMenuFetch: true,
            ),
          );
        }
        return true;
      },
    );
  }

  Future<void> _onMenuProductTap({
    required int groupOrderId,
    required GroupOrderFoodRow row,
  }) async {
    final productId = row.productId;
    if (productId == null || productId <= 0) return;
    if (_syncingProductIds.contains(productId)) return;
    if (_selectedProductIds.contains(productId)) {
      await _removeSelectedProduct(
        groupOrderId: groupOrderId,
        productId: productId,
      );
      return;
    }
    await _addSelectedProduct(groupOrderId: groupOrderId, productId: productId);
  }

  Future<void> _addMultipleItems({
    required int groupOrderId,
    required List<GroupOrderMenuSectionItemModel> menuProducts,
  }) async {
    final picked = await GroupOrderMenuMultiSelectSheet.show(
      context,
      products: menuProducts,
      selectedIds: Set<int>.from(_selectedProductIds),
    );
    if (!mounted || picked == null || picked.isEmpty) return;
    for (final product in picked) {
      final productId = product.id;
      if (productId == null || productId <= 0) continue;
      if (_selectedProductIds.contains(productId) ||
          _syncingProductIds.contains(productId)) {
        continue;
      }
      unawaited(
        _addSelectedProduct(groupOrderId: groupOrderId, productId: productId),
      );
    }
  }

  GroupOrderDetailsModel _removeItemFromDetailsLocally({
    required GroupOrderDetailsModel details,
    required GroupOrderParticipantModel participant,
    required GroupOrderItemModel item,
  }) {
    final participants = details.participants.map((p) {
      if (p.participantId != null &&
          participant.participantId != null &&
          p.participantId == participant.participantId) {
        final items = p.items.where((i) {
          if (item.itemId != null && i.itemId != null) {
            return i.itemId != item.itemId;
          }
          return !(i.productId == item.productId && i.name == item.name);
        }).toList();
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
      }
      return p;
    }).toList();

    return GroupOrderDetailsModel(
      groupOrder: details.groupOrder,
      participants: participants,
      counts: details.counts,
      amounts: details.amounts,
    );
  }

  Future<void> _showCreatorSubmitSheet({
    required int groupOrderId,
    required GroupOrderDetailsModel details,
    required ProfileState state,
  }) async {
    var sheetDetails = _buildCreatorMergedDetails(
      details: details,
      state: state,
    );
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return GroupOrderCreatorSubmitSheet(
              details: sheetDetails,
              isPlacing: false,
              syncingProductIds: _syncingProductIds,
              onDeleteItem: (participant, item) async {
                final isCurrentUser =
                    participant.userId != null &&
                    participant.userId == _effectiveCurrentUserId(details);
                bool success = false;
                if (isCurrentUser &&
                    item.productId != null &&
                    _selectedProductIds.contains(item.productId)) {
                  success = await _removeSelectedProduct(
                    groupOrderId: groupOrderId,
                    productId: item.productId!,
                    forcedItemId: item.itemId,
                    refreshAfterSuccess: true,
                  );
                } else {
                  success = await _deleteParticipantItem(
                    groupOrderId: groupOrderId,
                    item: item,
                    refreshAfterSuccess: true,
                  );
                }
                if (!mounted || !success) return;
                setModalState(() {
                  sheetDetails = _removeItemFromDetailsLocally(
                    details: sheetDetails,
                    participant: participant,
                    item: item,
                  );
                });
              },
              onSubmit: () {
                Navigator.of(modalContext).pop();
                context.read<ProfileBloc>().add(
                  PlaceGroupOrderEvent(
                    params: PlaceGroupOrderParams(groupOrderId: groupOrderId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.joinGroupOrderStatus != current.joinGroupOrderStatus,
      listener: (context, state) {
        if (state.joinGroupOrderStatus == BlocStatus.success &&
            !_showDispatchedAfterJoin) {
          _showDispatchedAfterJoin = true;
          context.read<ProfileBloc>().add(
            ShowGroupOrderEvent(
              params: ShowGroupOrderParams(
                groupOrderId: widget.params.groupOrderId,
              ),
            ),
          );
        }
      },
      child: BlocListener<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) =>
            previous.groupOrderDetails != current.groupOrderDetails,
        listener: (context, state) {
          final details = state.groupOrderDetails;
          if (details == null) return;
          _syncLocalSelectionFromDetails(details);
        },
        child: BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage ||
              previous.actionMessage != current.actionMessage,
          listener: (context, state) {
            final error = state.errorMessage;
            if (error != null && error.isNotEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error)));
            }
            final action = state.actionMessage;
            if (action != null && action.isNotEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(action)));
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xffF9FAFB),
            body: SafeArea(
              child: Column(
                children: [
                  BlocBuilder<ProfileBloc, ProfileState>(
                    buildWhen: (previous, current) =>
                        previous.groupOrderDetails != current.groupOrderDetails,
                    builder: (context, state) {
                      final go = state.groupOrderDetails?.groupOrder;
                      final id = go?.id ?? widget.params.groupOrderId;
                      return PersonalDetailsAppBar(
                        title: 'متابعة الطلب الجماعي',
                        trailing: id > 0
                            ? IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 42,
                                  minHeight: 42,
                                ),
                                onPressed: () {
                                  unawaited(
                                    shareDeepLinkUrl(
                                      groupOrderUrl(
                                        id: id,
                                        shareToken: go?.shareToken,
                                      ),
                                      context: context,
                                    ),
                                  );
                                },
                                icon: FaIcon(
                                  FontAwesomeIcons.shareNodes,
                                  color: context.primary,
                                  size: 20,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: BlocBuilder<ProfileBloc, ProfileState>(
                      buildWhen: (previous, current) =>
                          previous.joinGroupOrderStatus !=
                              current.joinGroupOrderStatus ||
                          previous.groupOrderDetailsStatus !=
                              current.groupOrderDetailsStatus ||
                          previous.groupOrderDetails !=
                              current.groupOrderDetails ||
                          previous.groupOrderMenuStatus !=
                              current.groupOrderMenuStatus ||
                          previous.groupOrderMenuSections !=
                              current.groupOrderMenuSections ||
                          previous.groupOrderMenuProducts !=
                              current.groupOrderMenuProducts ||
                          previous.groupOrderActionStatus !=
                              current.groupOrderActionStatus,
                      builder: (context, state) {
                        final shareToken = widget.params.shareToken?.trim();
                        final hasShareToken =
                            shareToken != null && shareToken.isNotEmpty;
                        final awaitingShareJoin =
                            hasShareToken &&
                            state.groupOrderDetails == null &&
                            state.joinGroupOrderStatus != BlocStatus.failed;

                        final showLoading =
                            (state.groupOrderDetailsStatus ==
                                    BlocStatus.loading &&
                                state.groupOrderDetails == null) ||
                            (awaitingShareJoin &&
                                (state.joinGroupOrderStatus == null ||
                                    state.joinGroupOrderStatus ==
                                        BlocStatus.loading)) ||
                            (awaitingShareJoin &&
                                state.joinGroupOrderStatus ==
                                    BlocStatus.success &&
                                state.groupOrderDetailsStatus !=
                                    BlocStatus.failed);

                        if (showLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final details = state.groupOrderDetails;
                        if (details == null) {
                          final joinFailed =
                              hasShareToken &&
                              state.joinGroupOrderStatus == BlocStatus.failed;
                          return Center(
                            child: AppText.bodyMedium(
                              joinFailed
                                  ? 'تعذر الانضمام إلى الطلب الجماعي'
                                  : 'تعذر تحميل تفاصيل الجلسة',
                              color: const Color(0xff6B7280),
                            ),
                          );
                        }

                        final isCreator =
                            details.groupOrder?.isCreator ?? false;
                        final groupOrderId =
                            details.groupOrder?.id ??
                            widget.params.groupOrderId;
                        final canSubmit =
                            (details.groupOrder?.status ?? '').toLowerCase() ==
                            'active';
                        final isMemberSubmitted =
                            !isCreator && _isCurrentMemberSubmitted(details);
                        final allFoods = _buildAllMenuFoods(state);
                        final requestedFoods = _buildCurrentUserRequestedFoods(
                          details: details,
                          state: state,
                        );
                        final memberCanSend =
                            canSubmit && requestedFoods.isNotEmpty;
                        final memberCanUnsend = canSubmit;
                        final creatorDetails = _buildCreatorMergedDetails(
                          details: details,
                          state: state,
                        );

                        return Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: Column(
                                  children: [
                                    ExpandableNumberedSection(
                                      sectionNumber: '1',
                                      title: 'خيارات التصويت',
                                      isExpanded: _isOptionsExpanded,
                                      onHeaderTap: () {
                                        setState(() {
                                          _isOptionsExpanded =
                                              !_isOptionsExpanded;
                                        });
                                      },
                                      child:
                                          state.groupOrderMenuStatus ==
                                              BlocStatus.loading
                                          ? const Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 24,
                                              ),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            )
                                          : GroupOrderOptionsSection(
                                              foods: allFoods,
                                              availableTypes: _availableTypes(
                                                state,
                                              ),
                                              selectedProductIds:
                                                  _selectedProductIds,
                                              syncingProductIds:
                                                  _syncingProductIds,
                                              onAddMultiTap:
                                                  isCreator && canSubmit
                                                  ? () => _addMultipleItems(
                                                      groupOrderId:
                                                          groupOrderId,
                                                      menuProducts: state
                                                          .groupOrderMenuProducts,
                                                    )
                                                  : null,
                                              onMenuProductTap: canSubmit
                                                  ? (row) => unawaited(
                                                      _onMenuProductTap(
                                                        groupOrderId:
                                                            groupOrderId,
                                                        row: row,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                    ),
                                    const SizedBox(height: 14),
                                    ExpandableNumberedSection(
                                      sectionNumber: '2',
                                      title: 'الأطعمة المختارة',
                                      isExpanded: _isSecondSectionExpanded,
                                      onHeaderTap: () {
                                        setState(() {
                                          _isSecondSectionExpanded =
                                              !_isSecondSectionExpanded;
                                        });
                                      },
                                      child: isCreator
                                          ? GroupOrderCreatorParticipantsItemsSection(
                                              details: creatorDetails,
                                            )
                                          : GroupOrderRequestedFoodsSection(
                                              foods: requestedFoods,
                                              memberName:
                                                  _currentUserDisplayName(
                                                    details,
                                                  ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isCreator || canSubmit)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: GroupOrderFooterBar(
                                  isCreator: isCreator,
                                  isLoading:
                                      state.groupOrderActionStatus ==
                                      BlocStatus.loading,
                                  canSubmit: isCreator
                                      ? canSubmit
                                      : (isMemberSubmitted
                                            ? memberCanUnsend
                                            : memberCanSend),
                                  primaryButtonLabel: isCreator
                                      ? 'مراجعة الطلب'
                                      : (isMemberSubmitted
                                            ? 'إلغاء الإرسال'
                                            : 'إرسال اختياراتي'),
                                  onSubmitOrPlace: () {
                                    if (isCreator) {
                                      _showCreatorSubmitSheet(
                                        groupOrderId: groupOrderId,
                                        details: creatorDetails,
                                        state: state,
                                      );
                                      return;
                                    }
                                    context.read<ProfileBloc>().add(
                                      isMemberSubmitted
                                          ? UnsubmitGroupOrderEvent(
                                              params: UnsubmitGroupOrderParams(
                                                groupOrderId: groupOrderId,
                                              ),
                                            )
                                          : SubmitGroupOrderEvent(
                                              params: SubmitGroupOrderParams(
                                                groupOrderId: groupOrderId,
                                              ),
                                            ),
                                    );
                                  },
                                  onCancel: isCreator
                                      ? () {
                                          context.read<ProfileBloc>().add(
                                            CancelGroupOrderEvent(
                                              params: CancelGroupOrderParams(
                                                groupOrderId: groupOrderId,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                ),
                              ),
                            const SizedBox(height: 14),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _PendingSelectionOp { add, remove }
