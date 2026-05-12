import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_share_targets.dart';
import 'package:dio/dio.dart';
import 'package:dllni_user_app/core/app_config.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../data/models/group_order_api_models.dart';
import '../../domain/usecases/add_group_order_item_use_case.dart';
import '../../domain/usecases/cancel_group_order_use_case.dart';
import '../../domain/usecases/delete_group_order_item_use_case.dart';
import '../../domain/usecases/place_group_order_use_case.dart';
import '../../domain/usecases/show_group_order_use_case.dart';
import '../../domain/usecases/submit_group_order_use_case.dart';
import '../manager/bloc/profile_bloc.dart';
import '../widgets/expandable_numbered_section.dart';
import '../widgets/group_order_footer_bar.dart';
import '../widgets/group_order_food_row.dart';
import '../widgets/group_order_menu_multi_select_sheet.dart';
import '../widgets/group_order_creator_participants_items_section.dart';
import '../widgets/group_order_options_section.dart';
import '../widgets/group_order_requested_foods_section.dart';
import '../widgets/personal_details_app_bar.dart';

class GroupOrderFollowupScreenParams {
  final int groupOrderId;
  final bool needShare;

  const GroupOrderFollowupScreenParams({required this.groupOrderId, this.needShare = false});
}

@AutoRoutePage(path: '/group-order/followup')
class GroupOrderFollowupScreen extends StatelessWidget {
  const GroupOrderFollowupScreen({super.key, required this.params});

  final GroupOrderFollowupScreenParams params;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => getIt<ProfileBloc>()..add(ShowGroupOrderEvent(params: ShowGroupOrderParams(groupOrderId: params.groupOrderId))),
      child: _GroupOrderFollowupBody(params: params),
    );
  }
}

class _GroupOrderFollowupBody extends StatefulWidget {
  final GroupOrderFollowupScreenParams params;

  const _GroupOrderFollowupBody({required this.params});

  @override
  State<_GroupOrderFollowupBody> createState() => _GroupOrderFollowupBodyState();
}

class _GroupOrderFollowupBodyState extends State<_GroupOrderFollowupBody> {
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final Set<int> _selectedProductIds = <int>{};
  String? _channelName;
  bool _isOptionsExpanded = true;
  bool _isSecondSectionExpanded = true;

  @override
  void initState() {
    super.initState();
    if (widget.params.needShare) {
      unawaited(
        shareDeepLinkUrl(
          groupOrderUrl(id: widget.params.groupOrderId),
          context: context,
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectRealtime();
    });
  }

  @override
  void dispose() {
    final channel = _channelName;
    if (channel != null) {
      unawaited(_pusher.unsubscribe(channelName: channel).catchError((_) {}));
    }
    unawaited(_pusher.disconnect().catchError((_) {}));
    super.dispose();
  }

  Future<void> _connectRealtime() async {
    if (!mounted) return;
    final channelName = 'private-group-order.${widget.params.groupOrderId}';
    _channelName = channelName;
    try {
      await _pusher.init(
        apiKey: AppConfig.pusherKey,
        cluster: AppConfig.pusherCluster,
        useTLS: true,
        authEndpoint: '${AppConfig.baseUrl}/broadcasting/auth',
        onAuthorizer: (channelName_, socketId, dynamic options) async {
          final token = (SharedPreferencesHelper.getData(key: 'token') ?? '').toString();
          final res = await DioNetwork.dio.post<Map<String, dynamic>>(
            '/broadcasting/auth',
            data: <String, dynamic>{'channel_name': channelName_, 'socket_id': socketId},
            options: Options(
              headers: <String, dynamic>{
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                if (token.isNotEmpty) 'Authorization': 'Bearer $token',
              },
              contentType: Headers.formUrlEncodedContentType,
              responseType: ResponseType.json,
            ),
          );
          final body = res.data;
          if (body == null || body['auth'] == null) {
            throw StateError('Invalid broadcasting auth response');
          }
          return <String, dynamic>{'auth': body['auth'], if (body['channel_data'] != null) 'channel_data': body['channel_data']};
        },
        onEvent: (PusherEvent event) {
          if (event.channelName == channelName && event.eventName == 'group-order.updated') {
            context.read<ProfileBloc>().add(
              ShowGroupOrderEvent(
                params: ShowGroupOrderParams(groupOrderId: widget.params.groupOrderId),
                skipMenuFetch: true,
              ),
            );
          }
        },
      );
      await _pusher.connect();
      await _pusher.subscribe(channelName: channelName);
    } catch (_) {}
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
            sizeLabel: (item.sizeLabel ?? '').trim().isEmpty ? null : item.sizeLabel,
          ),
        );
      }
    }
    return rows;
  }

  List<GroupOrderFoodRow> _buildRequestedFoods(GroupOrderDetailsModel details) {
    final source = details.participants;
    final rows = <GroupOrderFoodRow>[];
    final typeByProduct = _buildTypeByProductId();
    for (final participant in source) {
      for (final item in participant.items) {
        rows.add(
          GroupOrderFoodRow(
            itemId: item.itemId,
            productId: item.productId,
            name: item.name ?? '-',
            quantity: item.quantity,
            type: typeByProduct[item.productId] ?? 'غير مصنف',
            subtitle: item.notes ?? '',
            imageUrl: item.imageUrl,
          ),
        );
      }
    }
    return rows;
  }

  Map<int, String> _buildTypeByProductId() {
    final state = context.read<ProfileBloc>().state;
    final map = <int, String>{};
    for (final product in state.groupOrderMenuProducts) {
      final id = product.id;
      if (id == null || id <= 0) continue;
      final type = product.sectionName.trim();
      map[id] = type.isEmpty ? 'غير مصنف' : type;
    }
    return map;
  }

  List<String> _availableTypes() {
    final state = context.read<ProfileBloc>().state;
    final types = <String>[];
    for (final section in state.groupOrderMenuSections) {
      final type = section.name.trim();
      if (type.isEmpty) continue;
      types.add(type);
    }
    return types;
  }

  Future<void> _addMultipleItems({
    required int groupOrderId,
    required List<GroupOrderMenuSectionItemModel> menuProducts,
  }) async {
    final picked = await GroupOrderMenuMultiSelectSheet.show(context, products: menuProducts, selectedIds: _selectedProductIds);
    if (!mounted || picked == null || picked.isEmpty) return;
    for (final product in picked) {
      final productId = product.id;
      if (productId == null || productId <= 0) continue;
      context.read<ProfileBloc>().add(
        AddGroupOrderItemEvent(
          params: AddGroupOrderItemParams(groupOrderId: groupOrderId, productId: productId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) => previous.errorMessage != current.errorMessage || previous.actionMessage != current.actionMessage,
      listener: (context, state) {
        final error = state.errorMessage;
        if (error != null && error.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
        final action = state.actionMessage;
        if (action != null && action.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(action)));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF9FAFB),
        body: SafeArea(
          child: Column(
            children: [
              BlocBuilder<ProfileBloc, ProfileState>(
                buildWhen: (previous, current) => previous.groupOrderDetails != current.groupOrderDetails,
                builder: (context, state) {
                  final go = state.groupOrderDetails?.groupOrder;
                  final id = go?.id ?? widget.params.groupOrderId;
                  return PersonalDetailsAppBar(
                    title: 'متابعة الطلب الجماعي',
                    trailing: id > 0
                        ? IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
                            onPressed: () {
                              unawaited(
                                shareDeepLinkUrl(
                                  groupOrderUrl(id: id, shareToken: go?.shareToken),
                                  context: context,
                                ),
                              );
                            },
                            icon: FaIcon(FontAwesomeIcons.shareNodes, color: context.primary, size: 20),
                          )
                        : null,
                  );
                },
              ),
              const SizedBox(height: 14),
              Expanded(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  buildWhen: (previous, current) =>
                      previous.groupOrderDetailsStatus != current.groupOrderDetailsStatus ||
                      previous.groupOrderDetails != current.groupOrderDetails ||
                      previous.groupOrderMenuStatus != current.groupOrderMenuStatus ||
                      previous.groupOrderMenuSections != current.groupOrderMenuSections ||
                      previous.groupOrderMenuProducts != current.groupOrderMenuProducts ||
                      previous.groupOrderActionStatus != current.groupOrderActionStatus,
                  builder: (context, state) {
                    if (state.groupOrderDetailsStatus == BlocStatus.loading && state.groupOrderDetails == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final details = state.groupOrderDetails;
                    if (details == null) {
                      return Center(child: AppText.bodyMedium('تعذر تحميل تفاصيل الجلسة', color: const Color(0xff6B7280)));
                    }

                    final isCreator = details.groupOrder?.isCreator ?? false;
                    final groupOrderId = details.groupOrder?.id ?? widget.params.groupOrderId;
                    final canSubmit = (details.groupOrder?.status ?? '').toLowerCase() == 'active';
                    final allFoods = _buildAllMenuFoods(state);
                    final requestedFoods = _buildRequestedFoods(details);

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                            child: Column(
                              children: [
                                ExpandableNumberedSection(
                                  sectionNumber: '1',
                                  title: 'خيارات التصويت',
                                  isExpanded: _isOptionsExpanded,
                                  onHeaderTap: () {
                                    setState(() {
                                      _isOptionsExpanded = !_isOptionsExpanded;
                                    });
                                  },
                                  child: state.groupOrderMenuStatus == BlocStatus.loading
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 24),
                                          child: Center(child: CircularProgressIndicator()),
                                        )
                                      : GroupOrderOptionsSection(
                                          foods: allFoods,
                                          availableTypes: _availableTypes(),
                                          onAddMultiTap: canSubmit
                                              ? () => _addMultipleItems(groupOrderId: groupOrderId, menuProducts: state.groupOrderMenuProducts)
                                              : null,
                                          onMenuProductTap: canSubmit
                                              ? (row) {
                                                  final pid = row.productId;
                                                  if (pid == null || pid <= 0) return;
                                                  context.read<ProfileBloc>().add(
                                                    AddGroupOrderItemEvent(
                                                      params: AddGroupOrderItemParams(groupOrderId: groupOrderId, productId: pid),
                                                    ),
                                                  );
                                                }
                                              : null,
                                        ),
                                ),
                                const SizedBox(height: 14),
                                ExpandableNumberedSection(
                                  sectionNumber: '2',
                                  title: isCreator ? 'اختيارات الأعضاء' : 'الاطعمة المطلوبة',
                                  isExpanded: _isSecondSectionExpanded,
                                  onHeaderTap: () {
                                    setState(() {
                                      _isSecondSectionExpanded = !_isSecondSectionExpanded;
                                    });
                                  },
                                  child: isCreator
                                      ? GroupOrderCreatorParticipantsItemsSection(
                                          details: details,
                                          menuProducts: state.groupOrderMenuProducts,
                                        )
                                      : GroupOrderRequestedFoodsSection(
                                          foods: requestedFoods,
                                          onDelete: (row) {
                                            final itemId = row.itemId;
                                            if (itemId == null) return;
                                            context.read<ProfileBloc>().add(
                                              DeleteGroupOrderItemEvent(
                                                params: DeleteGroupOrderItemParams(groupOrderId: groupOrderId, itemId: itemId),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GroupOrderFooterBar(
                            isCreator: isCreator,
                            isLoading: state.groupOrderActionStatus == BlocStatus.loading,
                            canSubmit: canSubmit,
                            onSubmitOrPlace: () {
                              if (isCreator) {
                                context.read<ProfileBloc>().add(PlaceGroupOrderEvent(params: PlaceGroupOrderParams(groupOrderId: groupOrderId)));
                              } else {
                                context.read<ProfileBloc>().add(SubmitGroupOrderEvent(params: SubmitGroupOrderParams(groupOrderId: groupOrderId)));
                              }
                            },
                            onCancel: isCreator
                                ? () {
                                    context.read<ProfileBloc>().add(
                                      CancelGroupOrderEvent(params: CancelGroupOrderParams(groupOrderId: groupOrderId)),
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
    );
  }
}
