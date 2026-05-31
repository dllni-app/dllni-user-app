import 'dart:ui' as ui;

import 'package:common_package/common_package.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_date_time_locale.dart';
import '../../../../core/utils/app_pickers.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../../../../core/widgets/app_text_fields.dart';
import '../../../../core/widgets/step_details.dart';
import '../../data/models/shopping_lists_api_models.dart';
import '../../domain/usecases/create_shopping_list_use_case.dart';
import '../../domain/usecases/update_shopping_list_use_case.dart';
import '../manager/bloc/profile_bloc.dart';
import 'shopping_list_master_products_search_screen.dart';

/// Inverse of [_uiDayIndexToApiWeekday] for UI index 0…6 (Sunday…Saturday).
int? _apiWeekdayToUiIndex(int w) {
  if (w == 7) return 0;
  if (w >= 1 && w <= 6) return w;
  return null;
}

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

String _formatTimeOfDay(TimeOfDay t) {
  final dt = DateTime(1970, 1, 1, t.hour, t.minute);
  return AppDateTimeLocale.dateFormat('hh:mm a').format(dt);
}

FrequencyType? _frequencyTypeFromApi(String? t) {
  switch (t) {
    case 'weekly':
      return FrequencyType.weekly;
    case 'monthly':
      return FrequencyType.monthly;
    case 'once':
      return FrequencyType.once;
    default:
      return null;
  }
}

TimeOfDay? _timeFromHHmm(String s) {
  if (s.isEmpty) return null;
  final parts = s.split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
}

String _timeOfDayToApiHHmm(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

int _timeOfDayToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

/// API `weekDays`: same as [DateTime.weekday] (1 = Monday … 7 = Sunday).
int _uiDayIndexToApiWeekday(int index) => index;

@AutoRoutePage(path: '/add_edit_shopping_list')
class AddEditShoppingListScreen extends StatefulWidget {
  final AddEditShoppingListScreenArgs args;

  const AddEditShoppingListScreen({super.key, required this.args});

  @override
  State<AddEditShoppingListScreen> createState() =>
      _AddEditShoppingListScreenState();
}

class AddEditShoppingListScreenArgs {
  final ProfileBloc profileBloc;
  final int? shoppingListId;
  final ShoppingListDetailModel? initialDetail;

  const AddEditShoppingListScreenArgs({
    required this.profileBloc,
    this.shoppingListId,
    this.initialDetail,
  });
}

enum FrequencyType { once, weekly, monthly }

class PeriodCard extends StatelessWidget {
  final String title;
  final String from;
  final String to;
  final VoidCallback? onDelete;
  final VoidCallback? onFromTap;
  final VoidCallback? onToTap;
  final bool canDelete;

  const PeriodCard({
    super.key,
    required this.title,
    required this.from,
    required this.to,
    this.onDelete,
    this.onFromTap,
    this.onToTap,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                title,
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 16 / 12,
                ),
              ),
              if (canDelete)
                GestureDetector(
                  onTap: onDelete,
                  child: FaIcon(
                    FontAwesomeIcons.trash,
                    size: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
            ],
          ),
          SizedBox(height: 7),
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
                        "من",
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 16 / 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: onFromTap,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(color: Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.solidClock,
                              size: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                            SizedBox(width: 16),
                            AppText(
                              from,
                              textDirection: ui.TextDirection.ltr,
                              style: TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 20 / 14,
                              ),
                            ),
                          ],
                        ),
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
                        "إلى",
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 16 / 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: onToTap,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(color: Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.solidClock,
                              size: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                            SizedBox(width: 16),
                            AppText(
                              to,
                              textDirection: ui.TextDirection.ltr,
                              style: TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 20 / 14,
                              ),
                            ),
                          ],
                        ),
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

class _AddEditShoppingListScreenState extends State<AddEditShoppingListScreen> {
  late TextEditingController nameController;
  List<bool> daysSelected = List.filled(7, false);
  final Map<int, _SelectedMasterProductDraft> _selectedProductsByMasterId =
      <int, _SelectedMasterProductDraft>{};

  /// Index `i` corresponds to calendar day `i + 1` (1–31).
  List<bool> monthDaySelected = List.filled(31, false);
  FrequencyType? frequencyType;

  final List<_SchedulePeriod> _periods = [
    _SchedulePeriod(
      from: const TimeOfDay(hour: 9, minute: 0),
      to: const TimeOfDay(hour: 11, minute: 0),
    ),
  ];

  final List<String> daysEn = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  final List<String> daysAr = [
    "الأحد",
    "الاثنين",
    "الثلاثاء",
    "الأربعاء",
    "الخميس",
    "الجمعة",
    "السبت",
  ];

  @override
  Widget build(BuildContext context) {
    final selectedProducts = _selectedProductsByMasterId.values.toList(
      growable: false,
    );
    return BlocProvider.value(
      value: widget.args.profileBloc,
      child: BlocListener<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) {
          final createDone =
              previous.createShoppingListStatus == BlocStatus.loading &&
              (current.createShoppingListStatus == BlocStatus.success ||
                  current.createShoppingListStatus == BlocStatus.failed);
          final updateDone =
              previous.updateShoppingListStatus == BlocStatus.loading &&
              (current.updateShoppingListStatus == BlocStatus.success ||
                  current.updateShoppingListStatus == BlocStatus.failed);
          return createDone || updateDone;
        },
        listener: (context, state) {
          final createSt = state.createShoppingListStatus;
          final updateSt = state.updateShoppingListStatus;
          if (createSt == BlocStatus.success ||
              updateSt == BlocStatus.success) {
            Loading.close();
            AppToast.showToast(
              context: context,
              message: state.updateShoppingListStatus == BlocStatus.success
                  ? 'تم تحديث القائمة بنجاح'
                  : 'تم إضافة القائمة بنجاح',
              type: ToastificationType.success,
            );
            Navigator.of(context).pop(true);
          } else if (createSt == BlocStatus.failed ||
              updateSt == BlocStatus.failed) {
            Loading.close();
            AppToast.showToast(
              context: context,
              message: state.errorMessage ?? 'حدث خطأ',
              type: ToastificationType.error,
            );
          }
        },
        child: Scaffold(
          body: Column(
            children: [
              AppSimpleAppBar2(
                title: widget.args.shoppingListId != null
                    ? 'تعديل القائمة'
                    : 'إضافة قائمة جديدة',
                arrowBackType: ArrowBackType.cupertino,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      StepDetails(
                        number: 1,
                        title: "المعلومات الأساسية",
                        child: AppTextField(
                          controller: nameController,
                          title: "اسم القائمة",
                          isRequired: true,
                          hintText: "ضع اسماً للقائمة: المنزل - العمل ...",
                        ),
                      ),
                      SizedBox(height: 20),
                      StepDetails(
                        number: 2,
                        title: "أضف منتجاتك",
                        leading: TextButton(
                          onPressed: _openMasterProductsPicker,
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFFE5E7EB)),
                              ),
                              child: AppText(
                                "المنتجات المختارة: ${_selectedProductsByMasterId.length}",
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            if (_selectedProductsByMasterId.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: AppText(
                                  "لا يوجد منتجات",
                                  style: TextStyle(
                                    color: Color(0xE52F2B3D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            else
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 320,
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: selectedProducts.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final item = selectedProducts[index];
                                    return _SelectedProductTile(
                                      item: item,
                                      onRemove: () => _removeSelectedProduct(
                                        item.masterProductId,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      StepDetails(
                        number: 3,
                        title: "جدولة القائمة",
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(color: Color(0xFFF3F4F6)),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Color(0x0D000000),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              RadioGroup(
                                groupValue: frequencyType,
                                onChanged: _onFrequencyChanged,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Radio(
                                          visualDensity: VisualDensity(
                                            vertical: -4,
                                            horizontal: -4,
                                          ),
                                          value: FrequencyType.once,
                                        ),
                                        SizedBox(width: 8),
                                        AppText(
                                          "مرة واحدة",
                                          style: TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Radio(
                                          visualDensity: VisualDensity(
                                            vertical: -4,
                                            horizontal: -4,
                                          ),
                                          value: FrequencyType.weekly,
                                        ),
                                        SizedBox(width: 8),
                                        AppText(
                                          "تكرار مرة كل أسبوع",
                                          style: TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Radio(
                                          visualDensity: VisualDensity(
                                            vertical: -4,
                                            horizontal: -4,
                                          ),
                                          value: FrequencyType.monthly,
                                        ),
                                        SizedBox(width: 8),
                                        AppText(
                                          "تكرار مرة كل شهر",
                                          style: TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (frequencyType == FrequencyType.weekly) ...[
                                SizedBox(height: 12),
                                Column(
                                  spacing: 12,
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    daysEn.length,
                                    (index) => _DayRow(
                                      dayAr: daysAr[index],
                                      dayEn: daysEn[index],
                                      value: daysSelected[index],
                                      onChanged: (value) {
                                        setState(() {
                                          daysSelected[index] = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                              if (frequencyType == FrequencyType.monthly) ...[
                                SizedBox(height: 12),
                                AppText(
                                  'أيام الشهر',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    height: 16 / 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(31, (index) {
                                    final day = index + 1;
                                    final selected = monthDaySelected[index];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          monthDaySelected[index] = !selected;
                                        });
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? AppColors.primary.withValues(
                                                  alpha: 0.12,
                                                )
                                              : const Color(0xFFF9FAFB),
                                          border: Border.all(
                                            color: selected
                                                ? AppColors.primary
                                                : const Color(0xFFE5E7EB),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: AppText(
                                          '$day',
                                          textDirection: ui.TextDirection.ltr,
                                          style: TextStyle(
                                            color: selected
                                                ? AppColors.primary
                                                : const Color(0xFF111827),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                              SizedBox(height: 12),
                              ...List.generate(_periods.length, (i) {
                                final p = _periods[i];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: i < _periods.length - 1 ? 12 : 0,
                                  ),
                                  child: PeriodCard(
                                    title: _arPeriodTitle(i),
                                    from: _formatTimeOfDay(p.from),
                                    to: _formatTimeOfDay(p.to),
                                    canDelete: _periods.length > 1,
                                    onDelete: () => _removePeriod(i),
                                    onFromTap: () => _editPeriodFrom(i),
                                    onToTap: () => _editPeriodTo(i),
                                  ),
                                );
                              }),
                              SizedBox(height: 12),
                              GestureDetector(
                                onTap: _addPeriod,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 11),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: .06,
                                    ),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: .21,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.plus,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 8),
                                      AppText(
                                        "إضافة فترة",
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          height: 20 / 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      GestureDetector(
                        onTap: _submit,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AppText(
                            widget.args.shoppingListId != null
                                ? 'حفظ التعديلات'
                                : 'حفظ وإضافة القائمة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFEEFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    final initial = widget.args.initialDetail;
    if (initial != null) {
      _hydrateFromDetail(initial);
    }
  }

  void _addPeriod() {
    setState(() {
      final from = _periods.isNotEmpty
          ? _periods.last.to
          : const TimeOfDay(hour: 9, minute: 0);
      var h = from.hour + 1;
      if (h > 23) h = 23;
      _periods.add(
        _SchedulePeriod(
          from: from,
          to: TimeOfDay(hour: h, minute: from.minute),
        ),
      );
    });
  }

  Future<void> _editPeriodFrom(int index) async {
    final p = _periods[index];
    final value = await AppPickers.showAppTimePicker(
      context: context,
      initialTime: p.from,
    );
    final t = _timeFromHHmm(value);
    if (t != null && mounted) {
      setState(() {
        _periods[index] = p.copyWith(from: t);
      });
    }
  }

  Future<void> _editPeriodTo(int index) async {
    final p = _periods[index];
    final value = await AppPickers.showAppTimePicker(
      context: context,
      initialTime: p.to,
    );
    final t = _timeFromHHmm(value);
    if (t != null && mounted) {
      setState(() {
        _periods[index] = p.copyWith(to: t);
      });
    }
  }

  Future<void> _openMasterProductsPicker() async {
    final selected = _selectedProductsByMasterId.values
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
              initialSelected: selected,
            ),
          ),
        );

    if (!mounted || picked == null) return;
    setState(() {
      _selectedProductsByMasterId
        ..clear()
        ..addEntries(
          picked.map(
            (item) => MapEntry(
              item.id,
              _SelectedMasterProductDraft(
                masterProductId: item.id,
                name: item.name,
              ),
            ),
          ),
        );
    });
  }

  void _removeSelectedProduct(int masterProductId) {
    setState(() {
      _selectedProductsByMasterId.remove(masterProductId);
    });
  }

  void _hydrateFromDetail(ShoppingListDetailModel d) {
    nameController.text = d.name;
    final s = d.schedule;
    frequencyType = _frequencyTypeFromApi(s?.frequencyType);
    daysSelected = List.filled(7, false);
    for (final w in s?.weekDays ?? const <int>[]) {
      final idx = _apiWeekdayToUiIndex(w);
      if (idx != null && idx >= 0 && idx < 7) {
        daysSelected[idx] = true;
      }
    }
    monthDaySelected = List.filled(31, false);
    for (final raw in s?.monthDays ?? const <dynamic>[]) {
      final day = raw is int ? raw : int.tryParse('$raw');
      if (day != null && day >= 1 && day <= 31) {
        monthDaySelected[day - 1] = true;
      }
    }
    _periods.clear();
    final plist = s?.periods ?? const <ShoppingListSchedulePeriodModel>[];
    if (plist.isEmpty) {
      _periods.add(
        const _SchedulePeriod(
          from: TimeOfDay(hour: 9, minute: 0),
          to: TimeOfDay(hour: 11, minute: 0),
        ),
      );
    } else {
      for (final p in plist) {
        final from =
            _timeFromHHmm(p.fromTime ?? '') ??
            const TimeOfDay(hour: 9, minute: 0);
        final to =
            _timeFromHHmm(p.toTime ?? '') ??
            const TimeOfDay(hour: 11, minute: 0);
        _periods.add(_SchedulePeriod(from: from, to: to));
      }
    }
    _selectedProductsByMasterId
      ..clear()
      ..addEntries(
        d.items
            .where((item) => item.masterProductId > 0)
            .map(
              (item) => MapEntry(
                item.masterProductId,
                _SelectedMasterProductDraft(
                  masterProductId: item.masterProductId,
                  name: item.name.trim().isNotEmpty
                      ? item.name
                      : 'منتج ${item.masterProductId}',
                ),
              ),
            ),
      );
  }

  void _onFrequencyChanged(FrequencyType? value) {
    setState(() {
      frequencyType = value;
      if (value == FrequencyType.weekly) {
        monthDaySelected = List.filled(31, false);
      } else if (value == FrequencyType.monthly) {
        daysSelected = List.filled(7, false);
      } else if (value == FrequencyType.once) {
        daysSelected = List.filled(7, false);
        monthDaySelected = List.filled(31, false);
      }
    });
  }

  void _removePeriod(int index) {
    if (_periods.length <= 1) return;
    setState(() {
      _periods.removeAt(index);
    });
  }

  void _submit() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      AppToast.showToast(
        context: context,
        message: 'يرجى إدخال اسم القائمة',
        type: ToastificationType.error,
      );
      return;
    }
    if (frequencyType == null) {
      AppToast.showToast(
        context: context,
        message: 'يرجى اختيار نوع التكرار',
        type: ToastificationType.error,
      );
      return;
    }
    final ft = frequencyType!;
    if (ft == FrequencyType.weekly && !daysSelected.any((e) => e)) {
      AppToast.showToast(
        context: context,
        message: 'يرجى اختيار يوم واحد على الأقل في الأسبوع',
        type: ToastificationType.error,
      );
      return;
    }
    if (ft == FrequencyType.monthly && !monthDaySelected.any((e) => e)) {
      AppToast.showToast(
        context: context,
        message: 'يرجى اختيار يوم واحد على الأقل من أيام الشهر',
        type: ToastificationType.error,
      );
      return;
    }
    for (var i = 0; i < _periods.length; i++) {
      final p = _periods[i];
      if (_timeOfDayToMinutes(p.from) > _timeOfDayToMinutes(p.to)) {
        AppToast.showToast(
          context: context,
          message: 'وقت البداية يجب أن يكون قبل وقت النهاية (الفترة ${i + 1})',
          type: ToastificationType.error,
        );
        return;
      }
    }

    final weekDays = <int>[];
    final monthDays = <int>[];
    if (ft == FrequencyType.weekly) {
      for (var i = 0; i < daysSelected.length; i++) {
        if (daysSelected[i]) {
          weekDays.add(_uiDayIndexToApiWeekday(i));
        }
      }
      weekDays.sort();
    } else if (ft == FrequencyType.monthly) {
      for (var i = 0; i < monthDaySelected.length; i++) {
        if (monthDaySelected[i]) {
          monthDays.add(i + 1);
        }
      }
    }

    final periods = <ShoppingListPeriodParam>[];
    for (var i = 0; i < _periods.length; i++) {
      final p = _periods[i];
      periods.add(
        ShoppingListPeriodParam(
          label: _arPeriodTitle(i),
          fromTime: _timeOfDayToApiHHmm(p.from),
          toTime: _timeOfDayToApiHHmm(p.to),
        ),
      );
    }

    final freq = switch (ft) {
      FrequencyType.once => ShoppingListFrequencyType.once,
      FrequencyType.weekly => ShoppingListFrequencyType.weekly,
      FrequencyType.monthly => ShoppingListFrequencyType.monthly,
    };

    Loading.show(context);
    final editId = widget.args.shoppingListId;
    if (editId != null) {
      widget.args.profileBloc.add(
        UpdateShoppingListEvent(
          params: UpdateShoppingListParams(
            shoppingListId: editId,
            name: name,
            isActive: true,
            scheduleFrequencyType: freq,
            scheduleWeekDays: weekDays,
            scheduleMonthDays: monthDays,
            schedulePeriods: periods,
            scheduleIsActive: true,
          ),
        ),
      );
    } else {
      widget.args.profileBloc.add(
        CreateShoppingListEvent(
          params: CreateShoppingListParams(
            name: name,
            description: null,
            isActive: true,
            frequencyType: freq,
            weekDays: weekDays,
            monthDays: monthDays,
            periods: periods,
            scheduleIsActive: true,
          ),
        ),
      );
    }
  }
}

class _DayRow extends StatelessWidget {
  final String dayAr;
  final String dayEn;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DayRow({
    required this.dayAr,
    required this.dayEn,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              dayAr,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 24 / 16,
              ),
            ),
            AppText(
              dayEn,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                height: 16 / 12,
              ),
            ),
          ],
        ),
        CupertinoSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _SchedulePeriod {
  final TimeOfDay from;

  final TimeOfDay to;

  const _SchedulePeriod({required this.from, required this.to});

  _SchedulePeriod copyWith({TimeOfDay? from, TimeOfDay? to}) =>
      _SchedulePeriod(from: from ?? this.from, to: to ?? this.to);
}

class _SelectedMasterProductDraft {
  final int masterProductId;
  final String name;

  const _SelectedMasterProductDraft({
    required this.masterProductId,
    required this.name,
  });
}

class _SelectedProductTile extends StatelessWidget {
  final _SelectedMasterProductDraft item;
  final VoidCallback onRemove;

  const _SelectedProductTile({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              item.name,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const FaIcon(
              FontAwesomeIcons.xmark,
              size: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
