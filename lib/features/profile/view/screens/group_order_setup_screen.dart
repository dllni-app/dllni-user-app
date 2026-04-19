import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/group_order_api_models.dart';
import '../../domain/usecases/create_group_order_use_case.dart';
import '../../domain/usecases/fetch_active_group_orders_use_case.dart';
import '../manager/bloc/profile_bloc.dart';
import '../widgets/expandable_numbered_section.dart';
import '../widgets/filled_text_field.dart';
import '../widgets/group_order_created_group_item.dart';
import '../widgets/group_order_created_groups_list.dart';
import '../widgets/group_order_mode.dart';
import '../widgets/group_order_mode_switcher.dart';
import '../widgets/group_order_restaurant_picker_sheet.dart';
import '../widgets/group_order_success_dialog.dart';
import '../widgets/personal_details_app_bar.dart';
import 'group_order_followup_screen.dart';

@AutoRoutePage(path: '/group-order/create')
class GroupOrderSetupScreen extends StatelessWidget {
  const GroupOrderSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => getIt<ProfileBloc>()..add(FetchGroupOrderRestaurantsEvent()),
      child: const _GroupOrderSetupBody(),
    );
  }
}

class _GroupOrderSetupBody extends StatefulWidget {
  const _GroupOrderSetupBody();

  @override
  State<_GroupOrderSetupBody> createState() => _GroupOrderSetupBodyState();
}

class _GroupOrderSetupBodyState extends State<_GroupOrderSetupBody> {
  final TextEditingController _restaurantController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  GroupOrderMode _mode = GroupOrderMode.create;
  bool _isRestaurantExpanded = true;
  bool _isOptionsExpanded = true;

  @override
  void dispose() {
    _restaurantController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickRestaurant() async {
    final selected = await GroupOrderRestaurantPickerSheet.show(context);
    if (!mounted || selected == null) return;
    context.read<ProfileBloc>().add(SelectGroupOrderRestaurantEvent(restaurant: selected));
    _restaurantController.text = selected.name ?? '';
  }

  void _showSuccessDialog({required int groupOrderId, required String? shareToken}) {
    showGroupOrderSuccessSheet(
      context,
      shareToken: shareToken,
      onFollowupTap: () {
        context.pushRoute(
          '/group-order/followup',
          arguments: GroupOrderFollowupScreenParams(groupOrderId: groupOrderId),
        );
      },
    );
  }

  void _onModeChanged(GroupOrderMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
    });
    if (mode == GroupOrderMode.existingGroups) {
      context.read<ProfileBloc>().add(
            FetchActiveGroupOrdersEvent(params: FetchActiveGroupOrdersParams()),
          );
    }
  }

  List<GroupOrderCreatedGroupItem> _mapActiveGroupsToItems(
    List<GroupOrderDetailsModel> groups,
  ) {
    return groups.where((e) => e.groupOrder?.id != null).map((entry) {
      final groupOrder = entry.groupOrder!;
      final id = groupOrder.id!;
      final title = (groupOrder.name ?? '').trim().isNotEmpty
          ? groupOrder.name!.trim()
          : ((groupOrder.restaurantName ?? '').trim().isNotEmpty
                ? groupOrder.restaurantName!.trim()
                : 'جلسة #$id');
      final participants = entry.counts?.participants ?? entry.participants.length;
      final responded = entry.counts?.responded ??
          entry.participants.where((e) => e.hasResponded).length;
      final pending = entry.counts?.pending ?? (participants - responded).clamp(0, participants);
      final itemsCount = entry.counts?.items ??
          entry.participants.fold<int>(0, (acc, p) => acc + p.items.length);
      final total = entry.amounts?.total;
      final detailParts = <String>[
        '$responded/$participants مشارك',
        '$pending بانتظار الرد',
        '$itemsCount عنصر',
        if (total != null && total > 0) '${total.toStringAsFixed(1)} ر.س',
        _statusLabel(groupOrder.status),
      ];
      final remaining = _remainingLabel(groupOrder.secondsRemaining);
      if (remaining != null) {
        detailParts.add(remaining);
      }
      return GroupOrderCreatedGroupItem(
        title: title,
        detail: detailParts.join(' • '),
        groupOrderId: id,
        initialData: entry,
      );
    }).toList();
  }

  String _statusLabel(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'active':
        return 'نشطة';
      case 'placing':
        return 'جارٍ التنفيذ';
      case 'placed':
        return 'تم الطلب';
      case 'expired':
        return 'منتهية';
      case 'cancelled':
        return 'ملغاة';
      default:
        return 'غير معروف';
    }
  }

  String? _remainingLabel(int? secondsRemaining) {
    if (secondsRemaining == null) return null;
    if (secondsRemaining <= 0) return 'ينتهي قريبًا';
    if (secondsRemaining < 60) return '$secondsRemaining ثانية متبقية';
    final minutes = secondsRemaining ~/ 60;
    return '$minutes دقيقة متبقية';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage || previous.createGroupOrderStatus != current.createGroupOrderStatus,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message != null && message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
        if (state.createGroupOrderStatus == BlocStatus.success) {
          final result = state.createGroupOrderResult;
          final groupOrderId = result?.groupOrderId ?? result?.details?.groupOrder?.id;
          if (groupOrderId != null) {
            _showSuccessDialog(groupOrderId: groupOrderId, shareToken: result?.details?.groupOrder?.shareToken);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF9FAFB),
        body: SafeArea(
          child: Column(
            children: [
              const PersonalDetailsAppBar(title: 'التكامل الاجتماعي'),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                child: GroupOrderModeSwitcher(
                  mode: _mode,
                  onModeChanged: _onModeChanged,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                  child: _mode == GroupOrderMode.create
                      ? Column(
                          children: [
                            ExpandableNumberedSection(
                              sectionNumber: '1',
                              title: 'من أين سنأكل اليوم؟',
                              isExpanded: _isRestaurantExpanded,
                              onHeaderTap: () {
                                setState(() {
                                  _isRestaurantExpanded = !_isRestaurantExpanded;
                                });
                              },
                              child: FilledTextField(
                                label: 'اسم المطعم',
                                isRequired: true,
                                controller: _restaurantController,
                                readOnly: true,
                                onTap: _pickRestaurant,
                                suffixIcon:
                                    const Icon(Icons.keyboard_arrow_down_rounded),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ExpandableNumberedSection(
                              sectionNumber: '2',
                              title: 'خيارات إضافية',
                              isExpanded: _isOptionsExpanded,
                              onHeaderTap: () {
                                setState(() {
                                  _isOptionsExpanded = !_isOptionsExpanded;
                                });
                              },
                              child: FilledTextField(
                                label: 'اسم الجلسة (اختياري)',
                                controller: _nameController,
                              ),
                            ),
                          ],
                        )
                      : BlocBuilder<ProfileBloc, ProfileState>(
                          buildWhen: (previous, current) =>
                              previous.activeGroupOrdersStatus !=
                                  current.activeGroupOrdersStatus ||
                              previous.activeGroupOrders !=
                                  current.activeGroupOrders,
                          builder: (context, state) {
                            if (state.activeGroupOrdersStatus ==
                                BlocStatus.loading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (state.activeGroupOrdersStatus ==
                                BlocStatus.failed) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  children: [
                                    AppText.bodyMedium(
                                      state.errorMessage ??
                                          'تعذر تحميل الجلسات القائمة',
                                      color: const Color(0xff6B7280),
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton(
                                      onPressed: () {
                                        context.read<ProfileBloc>().add(
                                              FetchActiveGroupOrdersEvent(
                                                params:
                                                    FetchActiveGroupOrdersParams(),
                                              ),
                                            );
                                      },
                                      child: const Text('إعادة المحاولة'),
                                    ),
                                  ],
                                ),
                              );
                            }
                            final items = _mapActiveGroupsToItems(
                              state.activeGroupOrders,
                            );
                            if (items.isEmpty) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: AppText.bodyMedium(
                                  'لا توجد جلسات قائمة حالياً',
                                  color: const Color(0xff6B7280),
                                ),
                              );
                            }
                            return GroupOrderCreatedGroupsList(
                              items: items,
                              onGroupTap: (item) {
                                context.pushRoute(
                                  '/group-order/followup',
                                  arguments: GroupOrderFollowupScreenParams(
                                    groupOrderId: item.groupOrderId,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
              if (_mode == GroupOrderMode.create)
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: BlocBuilder<ProfileBloc, ProfileState>(
                          buildWhen: (previous, current) =>
                              previous.createGroupOrderStatus !=
                                  current.createGroupOrderStatus ||
                              previous.selectedGroupOrderRestaurant !=
                                  current.selectedGroupOrderRestaurant,
                          builder: (context, state) {
                            final isLoading =
                                state.createGroupOrderStatus ==
                                    BlocStatus.loading;
                            return ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      final selectedRestaurantId = state
                                          .selectedGroupOrderRestaurant
                                          ?.id;
                                      if (selectedRestaurantId == null ||
                                          selectedRestaurantId <= 0) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'يرجى اختيار مطعم أولاً',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      context.read<ProfileBloc>().add(
                                            CreateGroupOrderEvent(
                                              params: CreateGroupOrderParams(
                                                restaurantId:
                                                    selectedRestaurantId,
                                                name: _nameController.text
                                                        .trim()
                                                        .isEmpty
                                                    ? null
                                                    : _nameController.text
                                                          .trim(),
                                              ),
                                            ),
                                          );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primary,
                                foregroundColor: context.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : AppText.labelLarge(
                                      'إنشاء التصويت',
                                      color: context.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: context.error.withAlpha(200)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: AppText.labelLarge(
                            'إلغاء',
                            color: context.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
