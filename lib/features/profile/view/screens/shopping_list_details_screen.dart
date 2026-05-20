import 'dart:ui' as ui;

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../../../../core/widgets/app_text_fields.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../../core/widgets/step_details.dart';
import '../../data/models/shopping_lists_api_models.dart';
import '../../domain/usecases/add_shopping_list_item_use_case.dart';
import '../../domain/usecases/add_shopping_list_to_cart_use_case.dart';
import '../../domain/usecases/delete_shopping_list_item_use_case.dart';
import '../../domain/usecases/fetch_shopping_list_detail_use_case.dart';
import '../manager/bloc/profile_bloc.dart';
import '../widgets/shopping_list_quantity_stepper.dart';
import 'add_edit_shopping_list_screen.dart';
import 'shopping_list_master_products_search_screen.dart';

/// API: `weekDays` uses 1–7 (same as [DateTime.weekday]): 1 = Monday … 7 = Sunday.
const List<String> _weekDaysAr = [
  '',
  'الاثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];

const List<String> _weekDaysEn = [
  '',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

String _arPeriodTitle(int index) {
  const ordinals = [
    'الأولى',
    'الثانية',
    'الثالثة',
    'الرابعة',
    'الخامسة',
    'السادسة',
    'السابعة',
    'الثامنة',
    'التاسعة',
    'العاشرة',
  ];
  if (index >= 0 && index < ordinals.length) {
    return 'الفترة ${ordinals[index]}';
  }
  return 'الفترة ${index + 1}';
}

String? _frequencyTypeAr(String? t) {
  switch (t) {
    case 'weekly':
      return 'تكرار مرة كل أسبوع';
    case 'monthly':
      return 'تكرار مرة كل شهر';
    case 'once':
      return 'مرة واحدة';
    default:
      return t;
  }
}

@AutoRoutePage(path: '/shopping_list_details')
class ShoppingListDetailsScreen extends StatelessWidget {
  final ShoppingListDetailsScreenArgs args;

  const ShoppingListDetailsScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    if (args.shoppingListId <= 0) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: Column(
          children: [
            AppSimpleAppBar2(
              title: args.shoppingListName.isNotEmpty
                  ? args.shoppingListName
                  : 'قائمة التسوق',
              arrowBackType: ArrowBackType.cupertino,
            ),
            const Expanded(
              child: Center(child: Text('أضف قائمة من الشاشة السابقة')),
            ),
          ],
        ),
      );
    }
    return BlocProvider<ProfileBloc>(
      create: (_) => getIt<ProfileBloc>()
        ..add(
          GetShoppingListDetailEvent(
            params: FetchShoppingListDetailParams(
              shoppingListId: args.shoppingListId,
            ),
          ),
        ),
      child: _ShoppingListDetailsBody(args: args),
    );
  }
}

class ShoppingListDetailsScreenArgs {
  final int shoppingListId;
  final String shoppingListName;

  ShoppingListDetailsScreenArgs({
    required this.shoppingListId,
    required this.shoppingListName,
  });
}

class _DayLabel extends StatelessWidget {
  final String dayAr;
  final String dayEn;

  const _DayLabel({required this.dayAr, required this.dayEn});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          dayAr,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 24 / 16,
          ),
        ),
        AppText(
          dayEn,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            height: 16 / 12,
          ),
        ),
      ],
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final String title;
  final String from;
  final String to;

  const _PeriodCard({
    required this.title,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                title,
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 16 / 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: AppText(
                        'من',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 16 / 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.solidClock,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 16),
                          AppText(
                            from,
                            textDirection: ui.TextDirection.ltr,
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 20 / 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: AppText(
                        'إلى',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 16 / 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.solidClock,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 16),
                          AppText(
                            to,
                            textDirection: ui.TextDirection.ltr,
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 20 / 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShoppingListDetailsBody extends StatefulWidget {
  final ShoppingListDetailsScreenArgs args;

  const _ShoppingListDetailsBody({required this.args});

  @override
  State<_ShoppingListDetailsBody> createState() =>
      _ShoppingListDetailsBodyState();
}

class _ShoppingListDetailsBodyState extends State<_ShoppingListDetailsBody> {
  late final TextEditingController _nameController;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.quantityPatchError != current.quantityPatchError &&
          (current.quantityPatchError?.isNotEmpty ?? false),
      listener: (context, state) {
        final msg = state.quantityPatchError;
        if (msg == null || msg.isEmpty) return;
        AppToast.showToast(
          context: context,
          message: msg,
          type: ToastificationType.error,
        );
        context.read<ProfileBloc>().add(
          ClearShoppingListQuantityPatchErrorEvent(),
        );
      },
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) =>
            previous.shoppingListDetail != current.shoppingListDetail,
        listener: (context, state) {
          final name = state.shoppingListDetail?.name;
          if (name != null && name.isNotEmpty && _nameController.text != name) {
            _nameController.text = name;
          }
        },
        buildWhen: (previous, current) =>
            previous.shoppingListDetailStatus !=
                current.shoppingListDetailStatus ||
            previous.shoppingListDetail != current.shoppingListDetail,
        builder: (context, state) {
          final title = state.shoppingListDetail?.name.isNotEmpty == true
              ? state.shoppingListDetail!.name
              : widget.args.shoppingListName;
          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            body: Column(
              children: [
                AppSimpleAppBar2(
                  title: title,
                  arrowBackType: ArrowBackType.cupertino,
                ),
                Expanded(child: _buildBody(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.args.shoppingListName);
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state.shoppingListDetailStatus == BlocStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.shoppingListDetailStatus == BlocStatus.failed) {
      return Center(
        child: FailureWidget(
          message: state.errorMessage ?? '',
          onRetry: () => _reloadDetail(context),
        ),
      );
    }

    final list = state.shoppingListDetail;
    if (list == null) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    final schedule = list.schedule;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          StepDetails(
            number: 1,
            title: 'المعلومات الأساسية',
            child: AppTextField(
              title: 'اسم القائمة',
              isRequired: true,
              hintText: 'ضع اسماً للقائمة: المنزل - العمل ...',
              readOnly: true,
              controller: _nameController,
            ),
          ),
          const SizedBox(height: 20),
          StepDetails(
            number: 2,
            title: 'أضف منتجاتك',
            leading: TextButton(
              onPressed: () => _openMasterProductsPicker(list),
              child: AppText(
                "اختر منتجاتك",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE5E7EB)),
                  ),
                  child: AppText(
                    "المنتجات المختارة: ${list.items.length}",
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                if (list.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: AppText(
                      'لا يوجد منتجات',
                      style: TextStyle(
                        color: Color(0xE52F2B3D),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: list.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = list.items[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: ShoppingListDetailProductRow(
                            key: ValueKey(item.id),
                            shoppingListId: widget.args.shoppingListId,
                            item: item,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StepDetails(
            number: 3,
            title: 'جدولة القائمة',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Color(0x0D000000),
                  ),
                ],
              ),
              child: schedule == null
                  ? AppText(
                      'لا يوجد جدولة',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (schedule.frequencyType == 'weekly' &&
                            schedule.weekDays.isNotEmpty)
                          Wrap(
                            spacing: 40,
                            runSpacing: 5,
                            children: [
                              for (final d in schedule.weekDays)
                                if (d >= 1 && d <= 7)
                                  _DayLabel(
                                    dayAr: _weekDaysAr[d],
                                    dayEn: _weekDaysEn[d],
                                  ),
                            ],
                          )
                        else if (schedule.frequencyType == 'monthly' &&
                            schedule.monthDays.isNotEmpty)
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              for (final m in schedule.monthDays)
                                AppText(
                                  '$m',
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        if (schedule.periods.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          for (var i = 0; i < schedule.periods.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            _PeriodCard(
                              title:
                                  schedule.periods[i].label
                                          ?.trim()
                                          .isNotEmpty ==
                                      true
                                  ? schedule.periods[i].label!
                                  : _arPeriodTitle(i),
                              from: schedule.periods[i].fromTime ?? '—',
                              to: schedule.periods[i].toTime ?? '—',
                            ),
                          ],
                        ],
                        if (_frequencyTypeAr(schedule.frequencyType) !=
                            null) ...[
                          const SizedBox(height: 10),
                          AppText(
                            _frequencyTypeAr(schedule.frequencyType)!,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 20 / 13,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          BlocConsumer<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) =>
                previous.addShoppingListToCartStatus !=
                current.addShoppingListToCartStatus,
            listener: (context, state) {
              if (state.addShoppingListToCartStatus == BlocStatus.success) {
                AppToast.showToast(
                  context: context,
                  message: 'تم إضافة القائمة إلى السلة بنجاح',
                  type: ToastificationType.success,
                );
              }
              if (state.addShoppingListToCartStatus == BlocStatus.failed) {
                AppToast.showToast(
                  context: context,
                  message: state.errorMessage ?? '',
                  type: ToastificationType.error,
                );
              }
            },
            buildWhen: (previous, current) =>
                previous.addShoppingListToCartStatus !=
                current.addShoppingListToCartStatus,
            builder: (context, state) {
              if (state.addShoppingListToCartStatus == BlocStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return GestureDetector(
                onTap: () {
                  context.read<ProfileBloc>().add(
                    AddShoppingListToCartEvent(
                      params: AddShoppingListToCartParams(
                        shoppingListId: widget.args.shoppingListId,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 2),
                        blurRadius: 5.2,
                        color: Color(0x40000000),
                      ),
                    ],
                  ),
                  child: AppText(
                    'إعادة طلب هذه القائمة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFEEFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () async {
              final bloc = context.read<ProfileBloc>();
              final detail = bloc.state.shoppingListDetail;
              context.pushRoute(
                '/add_edit_shopping_list',
                arguments: AddEditShoppingListScreenArgs(
                  profileBloc: bloc,
                  shoppingListId: widget.args.shoppingListId,
                  initialDetail: detail,
                ),
              );
              if (!context.mounted) return;

              bloc.add(
                GetShoppingListDetailEvent(
                  params: FetchShoppingListDetailParams(
                    shoppingListId: widget.args.shoppingListId,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppText(
                'تعديل القائمة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFEEFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Future<void> _openMasterProductsPicker(ShoppingListDetailModel list) async {
    final initialSelected = list.items
        .where((item) => item.masterProductId > 0)
        .map(
          (item) => ShoppingListMasterProductOption(
            id: item.masterProductId,
            name: item.name,
          ),
        )
        .toList();

    final picked = await Navigator.of(context)
        .push<List<ShoppingListMasterProductOption>>(
          MaterialPageRoute(
            builder: (_) => ShoppingListMasterProductsSearchScreen(
              initialSelected: initialSelected,
            ),
          ),
        );

    if (!mounted || picked == null) return;

    final selectedMasterIds = picked.map((item) => item.id).toSet();
    final currentByMasterId = <int, ShoppingListItemModel>{};
    for (final item in list.items) {
      if (item.masterProductId > 0) {
        currentByMasterId[item.masterProductId] = item;
      }
    }

    final currentMasterIds = currentByMasterId.keys.toSet();
    final masterIdsToAdd = selectedMasterIds.difference(currentMasterIds);
    final masterIdsToRemove = currentMasterIds.difference(selectedMasterIds);

    if (masterIdsToAdd.isEmpty && masterIdsToRemove.isEmpty) return;

    Loading.show(context);
    String? errorMessage;

    final addUseCase = getIt<AddShoppingListItemUseCase>();
    final deleteUseCase = getIt<DeleteShoppingListItemUseCase>();

    for (final masterProductId in masterIdsToAdd) {
      final response = await addUseCase(
        AddShoppingListItemParams(
          shoppingListId: widget.args.shoppingListId,
          masterProductId: masterProductId,
          quantity: 1,
        ),
      );
      response.fold((failure) => errorMessage ??= failure.message, (_) {});
    }

    for (final masterProductId in masterIdsToRemove) {
      final item = currentByMasterId[masterProductId];
      if (item == null || item.id <= 0) continue;
      final response = await deleteUseCase(
        DeleteShoppingListItemParams(
          shoppingListId: widget.args.shoppingListId,
          itemId: item.id,
        ),
      );
      response.fold((failure) => errorMessage ??= failure.message, (_) {});
    }

    Loading.close();
    if (!mounted) return;
    _reloadDetail(context);

    if (errorMessage != null) {
      AppToast.showToast(
        context: context,
        message: errorMessage!,
        type: ToastificationType.error,
      );
    }
  }

  void _reloadDetail(BuildContext context) {
    context.read<ProfileBloc>().add(
      GetShoppingListDetailEvent(
        params: FetchShoppingListDetailParams(
          shoppingListId: widget.args.shoppingListId,
        ),
      ),
    );
  }
}
