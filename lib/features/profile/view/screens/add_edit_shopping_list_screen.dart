import 'dart:ui' as ui;

import 'package:common_package/common_package.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_date_time_locale.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../../../../core/widgets/app_text_fields.dart';
import '../../../../core/widgets/step_details.dart';
import '../../data/models/shopping_lists_api_models.dart';
import '../../domain/repository/shopping_lists_repo.dart';
import '../../domain/usecases/add_shopping_list_item_use_case.dart';
import '../../domain/usecases/create_shopping_list_use_case.dart';
import '../../domain/usecases/delete_shopping_list_item_use_case.dart';
import '../../domain/usecases/fetch_shopping_list_detail_use_case.dart';
import '../../domain/usecases/update_shopping_list_use_case.dart';
import '../manager/bloc/profile_bloc.dart';
import '../widgets/shopping_list_icon.dart';
import 'shopping_list_master_products_search_screen.dart';

const _daysAr = <String>[
  'الأحد',
  'الاثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
];

final _timeSlots = List<int>.unmodifiable(List<int>.generate(48, (i) => i * 30));

enum FrequencyType { weekly, monthly }

class _Period {
  final int from;
  final int to;

  const _Period({required this.from, required this.to});
  const _Period.initial() : from = 9 * 60, to = 11 * 60;

  _Period copyWith({int? from, int? to}) =>
      _Period(from: from ?? this.from, to: to ?? this.to);
}

class _SelectedProduct {
  final int id;
  final String name;
  const _SelectedProduct(this.id, this.name);
}

class _SaveException implements Exception {
  final String message;
  const _SaveException(this.message);
}

String _periodTitle(int index) {
  const names = <String>[
    'الأولى', 'الثانية', 'الثالثة', 'الرابعة', 'الخامسة',
    'السادسة', 'السابعة', 'الثامنة', 'التاسعة', 'العاشرة',
  ];
  return index < names.length ? 'الفترة ${names[index]}' : 'الفترة ${index + 1}';
}

int _normalizeTime(int minutes) {
  final value = minutes.clamp(0, 1439).toInt();
  return (value ~/ 30) * 30;
}

int? _parseTime(String? value) {
  if (value == null) return null;
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return _normalizeTime(h.clamp(0, 23).toInt() * 60 + m.clamp(0, 59).toInt());
}

String _apiTime(int value) {
  final minutes = _normalizeTime(value);
  return '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
}

String _displayTime(int value) {
  final minutes = _normalizeTime(value);
  return AppDateTimeLocale.dateFormat('hh:mm a')
      .format(DateTime(1970, 1, 1, minutes ~/ 60, minutes % 60));
}

int? _weeklyDayFromLabel(String? label) {
  if (label == null || !label.startsWith('weekday=')) return null;
  final end = label.indexOf(';');
  if (end < 0) return null;
  final day = int.tryParse(label.substring(8, end));
  return day != null && day >= 0 && day <= 6 ? day : null;
}

int? _monthDayFromLabel(String? label) {
  if (label == null || !label.startsWith('monthday=')) return null;
  final end = label.indexOf(';');
  if (end < 0) return null;
  final day = int.tryParse(label.substring(9, end));
  return day != null && day >= 1 && day <= 31 ? day : null;
}

@AutoRoutePage(path: '/add_edit_shopping_list')
class AddEditShoppingListScreen extends StatefulWidget {
  final AddEditShoppingListScreenArgs args;

  const AddEditShoppingListScreen({super.key, required this.args});

  @override
  State<AddEditShoppingListScreen> createState() => _AddEditShoppingListScreenState();
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

class _AddEditShoppingListScreenState extends State<AddEditShoppingListScreen> {
  late final TextEditingController _nameController;
  late final ShoppingListsRepo _repo;

  FrequencyType _frequency = FrequencyType.weekly;
  final _weekSelected = List<bool>.filled(7, false);
  final _monthSelected = List<bool>.filled(31, false);
  final _weeklyPeriods = <int, List<_Period>>{};
  final _monthlyPeriods = <int, List<_Period>>{};
  final _selectedProducts = <int, _SelectedProduct>{};
  String _iconKey = defaultShoppingListIconKey;
  String? _plainDescription;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repo = getIt<ShoppingListsRepo>();
    _nameController = TextEditingController();
    final detail = widget.args.initialDetail;
    if (detail != null) _hydrate(detail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppSimpleAppBar2(
            title: widget.args.shoppingListId == null ? 'إضافة قائمة جديدة' : 'تعديل القائمة',
            arrowBackType: ArrowBackType.cupertino,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  StepDetails(
                    number: 1,
                    title: 'المعلومات الأساسية',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _nameController,
                          title: 'اسم القائمة',
                          isRequired: true,
                          hintText: 'ضع اسماً للقائمة: المنزل - العمل ...',
                        ),
                        const SizedBox(height: 16),
                        AppText(
                          'أيقونة القائمة',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildIconPicker(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  StepDetails(
                    number: 2,
                    title: 'أضف منتجاتك',
                    leading: TextButton(
                      onPressed: _openProducts,
                      child: AppText(
                        'اختر منتجاتك',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    child: _buildSelectedProducts(),
                  ),
                  const SizedBox(height: 20),
                  StepDetails(
                    number: 3,
                    title: 'جدولة القائمة',
                    child: _buildSchedule(),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _saving ? null : _submit,
                    child: AnimatedOpacity(
                      opacity: _saving ? .6 : 1,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText(
                          widget.args.shoppingListId == null
                              ? 'حفظ وإضافة القائمة'
                              : 'حفظ التعديلات',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFFEEFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: shoppingListIconOptions.map((option) {
        final selected = option.key == _iconKey;
        return InkWell(
          onTap: () => setState(() => _iconKey = option.key),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: .12)
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
              ),
            ),
            child: FaIcon(
              option.icon,
              size: 20,
              color: selected ? AppColors.primary : const Color(0xFF64748B),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedProducts() {
    final products = _selectedProducts.values.toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: AppText(
            'المنتجات المختارة: ${products.length}',
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (products.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: AppText('لا يوجد منتجات'),
          )
        else
          ...products.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ProductTile(
                name: product.name,
                onRemove: () => setState(() => _selectedProducts.remove(product.id)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSchedule() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RadioGroup<FrequencyType>(
            groupValue: _frequency,
            onChanged: (value) {
              if (value != null) setState(() => _frequency = value);
            },
            child: const Column(
              children: [
                _FrequencyRow(
                  value: FrequencyType.weekly,
                  label: 'تكرار مرة كل أسبوع',
                ),
                _FrequencyRow(
                  value: FrequencyType.monthly,
                  label: 'تكرار مرة كل شهر',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_frequency == FrequencyType.weekly)
            _buildWeeklySchedule()
          else
            _buildMonthlySchedule(),
        ],
      ),
    );
  }

  Widget _buildWeeklySchedule() {
    return Column(
      children: List.generate(7, (day) {
        final selected = _weekSelected[day];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    _daysAr[day],
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  CupertinoSwitch(
                    value: selected,
                    onChanged: (value) {
                      setState(() {
                        _weekSelected[day] = value;
                        if (value) _periodsForWeekday(day);
                      });
                    },
                  ),
                ],
              ),
              if (selected) ...[
                const SizedBox(height: 8),
                _DayPeriodsEditor(
                  title: _daysAr[day],
                  periods: _periodsForWeekday(day),
                  onAdd: () => _addPeriod(_periodsForWeekday(day)),
                  onRemove: (index) => _removePeriod(_periodsForWeekday(day), index),
                  onChange: (index, period) {
                    setState(() => _periodsForWeekday(day)[index] = period);
                  },
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMonthlySchedule() {
    final selectedDays = <int>[
      for (var i = 0; i < 31; i++)
        if (_monthSelected[i]) i + 1,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          'أيام الشهر',
          textAlign: TextAlign.start,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(31, (index) {
            final day = index + 1;
            final selected = _monthSelected[index];
            return InkWell(
              onTap: () {
                setState(() {
                  _monthSelected[index] = !selected;
                  if (!selected) _periodsForMonthDay(day);
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: .12)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
                  ),
                ),
                child: AppText('$day', textDirection: ui.TextDirection.ltr),
              ),
            );
          }),
        ),
        if (selectedDays.isNotEmpty) const SizedBox(height: 16),
        ...selectedDays.map(
          (day) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DayPeriodsEditor(
              title: 'اليوم $day',
              periods: _periodsForMonthDay(day),
              onAdd: () => _addPeriod(_periodsForMonthDay(day)),
              onRemove: (index) => _removePeriod(_periodsForMonthDay(day), index),
              onChange: (index, period) {
                setState(() => _periodsForMonthDay(day)[index] = period);
              },
            ),
          ),
        ),
      ],
    );
  }

  List<_Period> _periodsForWeekday(int day) =>
      _weeklyPeriods.putIfAbsent(day, () => <_Period>[const _Period.initial()]);

  List<_Period> _periodsForMonthDay(int day) =>
      _monthlyPeriods.putIfAbsent(day, () => <_Period>[const _Period.initial()]);

  void _addPeriod(List<_Period> periods) {
    setState(() {
      final start = periods.isEmpty ? 9 * 60 : periods.last.to;
      final safeStart = start >= 23 * 60 + 30 ? 22 * 60 + 30 : start;
      periods.add(_Period(from: safeStart, to: (safeStart + 60).clamp(0, 23 * 60 + 30).toInt()));
    });
  }

  void _removePeriod(List<_Period> periods, int index) {
    if (periods.length <= 1) return;
    setState(() => periods.removeAt(index));
  }

  Future<void> _openProducts() async {
    final initial = _selectedProducts.values
        .map((p) => ShoppingListMasterProductOption(id: p.id, name: p.name))
        .toList();
    final picked = await Navigator.of(context).push<List<ShoppingListMasterProductOption>>(
      MaterialPageRoute(
        builder: (_) => ShoppingListMasterProductsSearchScreen(initialSelected: initial),
      ),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _selectedProducts
        ..clear()
        ..addEntries(picked.map((p) => MapEntry(p.id, _SelectedProduct(p.id, p.name))));
    });
  }

  void _hydrate(ShoppingListDetailModel detail) {
    _nameController.text = detail.name;
    _iconKey = shoppingListIconKeyFromDescription(detail.description);
    _plainDescription = shoppingListDescriptionWithoutIcon(detail.description);
    _frequency = detail.schedule?.frequencyType == 'monthly'
        ? FrequencyType.monthly
        : FrequencyType.weekly;

    for (final day in detail.schedule?.weekDays ?? const <int>[]) {
      if (day >= 0 && day <= 6) _weekSelected[day] = true;
      if (day == 7) _weekSelected[0] = true;
    }
    for (final raw in detail.schedule?.monthDays ?? const <dynamic>[]) {
      final day = raw is int ? raw : int.tryParse('$raw');
      if (day != null && day >= 1 && day <= 31) _monthSelected[day - 1] = true;
    }

    final untagged = <_Period>[];
    for (final apiPeriod in detail.schedule?.periods ?? const <ShoppingListSchedulePeriodModel>[]) {
      final period = _Period(
        from: _parseTime(apiPeriod.fromTime) ?? 9 * 60,
        to: _parseTime(apiPeriod.toTime) ?? 11 * 60,
      );
      final weekday = _weeklyDayFromLabel(apiPeriod.label);
      final monthDay = _monthDayFromLabel(apiPeriod.label);
      if (weekday != null) {
        _weeklyPeriods.putIfAbsent(weekday, () => <_Period>[]).add(period);
      } else if (monthDay != null) {
        _monthlyPeriods.putIfAbsent(monthDay, () => <_Period>[]).add(period);
      } else {
        untagged.add(period);
      }
    }

    if (_frequency == FrequencyType.weekly) {
      for (var day = 0; day < 7; day++) {
        if (!_weekSelected[day]) continue;
        if (_weeklyPeriods[day]?.isNotEmpty == true) continue;
        _weeklyPeriods[day] = untagged.isEmpty
            ? <_Period>[const _Period.initial()]
            : List<_Period>.from(untagged);
      }
    } else {
      for (var day = 1; day <= 31; day++) {
        if (!_monthSelected[day - 1]) continue;
        if (_monthlyPeriods[day]?.isNotEmpty == true) continue;
        _monthlyPeriods[day] = untagged.isEmpty
            ? <_Period>[const _Period.initial()]
            : List<_Period>.from(untagged);
      }
    }

    for (final item in detail.items) {
      if (item.masterProductId <= 0) continue;
      _selectedProducts[item.masterProductId] = _SelectedProduct(
        item.masterProductId,
        item.name.trim().isEmpty ? 'منتج ${item.masterProductId}' : item.name,
      );
    }
  }

  bool _validate() {
    if (_nameController.text.trim().isEmpty) {
      _error('يرجى إدخال اسم القائمة');
      return false;
    }
    if (_frequency == FrequencyType.weekly) {
      if (!_weekSelected.any((e) => e)) {
        _error('يرجى اختيار يوم واحد على الأقل في الأسبوع');
        return false;
      }
      for (var day = 0; day < 7; day++) {
        if (!_weekSelected[day]) continue;
        if (!_validatePeriods(_periodsForWeekday(day), _daysAr[day])) return false;
      }
    } else {
      if (!_monthSelected.any((e) => e)) {
        _error('يرجى اختيار يوم واحد على الأقل من أيام الشهر');
        return false;
      }
      for (var day = 1; day <= 31; day++) {
        if (!_monthSelected[day - 1]) continue;
        if (!_validatePeriods(_periodsForMonthDay(day), 'اليوم $day')) return false;
      }
    }
    return true;
  }

  bool _validatePeriods(List<_Period> periods, String dayName) {
    if (periods.isEmpty) {
      _error('يجب إضافة فترة واحدة على الأقل ليوم $dayName');
      return false;
    }
    for (var i = 0; i < periods.length; i++) {
      if (periods[i].from >= periods[i].to) {
        _error('وقت البداية يجب أن يكون قبل وقت النهاية ($dayName - ${_periodTitle(i)})');
        return false;
      }
    }
    return true;
  }

  List<ShoppingListPeriodParam> _apiPeriods() {
    final result = <ShoppingListPeriodParam>[];
    if (_frequency == FrequencyType.weekly) {
      for (var day = 0; day < 7; day++) {
        if (!_weekSelected[day]) continue;
        final periods = _periodsForWeekday(day);
        for (var i = 0; i < periods.length; i++) {
          result.add(ShoppingListPeriodParam(
            label: 'weekday=$day;${_periodTitle(i)}',
            fromTime: _apiTime(periods[i].from),
            toTime: _apiTime(periods[i].to),
          ));
        }
      }
    } else {
      for (var day = 1; day <= 31; day++) {
        if (!_monthSelected[day - 1]) continue;
        final periods = _periodsForMonthDay(day);
        for (var i = 0; i < periods.length; i++) {
          result.add(ShoppingListPeriodParam(
            label: 'monthday=$day;${_periodTitle(i)}',
            fromTime: _apiTime(periods[i].from),
            toTime: _apiTime(periods[i].to),
          ));
        }
      }
    }
    return result;
  }

  Future<void> _submit() async {
    if (_saving || !_validate()) return;

    final weekDays = <int>[
      for (var i = 0; i < 7; i++)
        if (_weekSelected[i] && _frequency == FrequencyType.weekly) i,
    ];
    final monthDays = <int>[
      for (var i = 0; i < 31; i++)
        if (_monthSelected[i] && _frequency == FrequencyType.monthly) i + 1,
    ];
    final frequency = _frequency == FrequencyType.weekly
        ? ShoppingListFrequencyType.weekly
        : ShoppingListFrequencyType.monthly;
    final description = shoppingListDescriptionWithIcon(
      description: _plainDescription,
      iconKey: _iconKey,
    );

    setState(() => _saving = true);
    Loading.show(context);
    try {
      final editId = widget.args.shoppingListId;
      int listId;
      if (editId == null) {
        final created = await _unwrap(
          _repo.createShoppingList(CreateShoppingListParams(
            name: _nameController.text.trim(),
            description: description,
            isActive: true,
            frequencyType: frequency,
            weekDays: weekDays,
            monthDays: monthDays,
            periods: _apiPeriods(),
            scheduleIsActive: true,
          )),
        );
        listId = created.data?.id ?? 0;
        if (listId <= 0) throw const _SaveException('تعذر إنشاء القائمة');
      } else {
        listId = editId;
        await _unwrap(
          _repo.updateShoppingList(UpdateShoppingListParams(
            shoppingListId: listId,
            name: _nameController.text.trim(),
            description: description,
            isActive: true,
            scheduleFrequencyType: frequency,
            scheduleWeekDays: weekDays,
            scheduleMonthDays: monthDays,
            schedulePeriods: _apiPeriods(),
            scheduleIsActive: true,
          )),
        );
      }

      final saved = await _syncProducts(listId);
      final desired = _selectedProducts.keys.toSet();
      final actual = saved.items.map((e) => e.masterProductId).toSet();
      if (desired.length != actual.length || !desired.every(actual.contains)) {
        throw const _SaveException('لم يتم حفظ جميع المنتجات المختارة، حاول مرة أخرى');
      }

      widget.args.profileBloc.add(
        GetShoppingListDetailEvent(
          params: FetchShoppingListDetailParams(shoppingListId: listId),
        ),
      );
      Loading.close();
      if (!mounted) return;
      AppToast.showToast(
        context: context,
        message: editId == null ? 'تم إضافة القائمة والمنتجات بنجاح' : 'تم تحديث القائمة والمنتجات بنجاح',
        type: ToastificationType.success,
      );
      Navigator.of(context).pop(true);
    } on _SaveException catch (e) {
      Loading.close();
      if (mounted) _error(e.message);
    } catch (_) {
      Loading.close();
      if (mounted) _error('حدث خطأ أثناء حفظ القائمة');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<ShoppingListDetailModel> _syncProducts(int listId) async {
    var response = await _unwrap(
      _repo.fetchShoppingListDetail(FetchShoppingListDetailParams(shoppingListId: listId)),
    );
    var detail = response.data;
    if (detail == null) throw const _SaveException('تعذر تحميل منتجات القائمة');

    final desired = _selectedProducts.keys.toSet();
    final kept = <int>{};
    for (final item in List<ShoppingListItemModel>.from(detail.items)) {
      final remove = !desired.contains(item.masterProductId) || kept.contains(item.masterProductId);
      if (remove && item.id > 0) {
        await _unwrap(_repo.deleteShoppingListItem(DeleteShoppingListItemParams(
          shoppingListId: listId,
          itemId: item.id,
        )));
      } else if (!remove) {
        kept.add(item.masterProductId);
      }
    }

    var sortOrder = kept.length;
    for (final masterId in desired) {
      if (kept.contains(masterId)) continue;
      await _unwrap(_repo.addShoppingListItem(AddShoppingListItemParams(
        shoppingListId: listId,
        masterProductId: masterId,
        quantity: 1,
        sortOrder: sortOrder++,
        isIncluded: true,
      )));
    }

    response = await _unwrap(
      _repo.fetchShoppingListDetail(FetchShoppingListDetailParams(shoppingListId: listId)),
    );
    detail = response.data;
    if (detail == null) throw const _SaveException('تعذر التحقق من منتجات القائمة');
    return detail;
  }

  Future<T> _unwrap<T>(DataResponse<T> response) async {
    final either = await response;
    T? value;
    String? message;
    either.fold((failure) => message = failure.message, (data) => value = data);
    if (message != null) throw _SaveException(message!);
    if (value == null) throw const _SaveException('حدث خطأ غير متوقع');
    return value as T;
  }

  void _error(String message) {
    AppToast.showToast(
      context: context,
      message: message,
      type: ToastificationType.error,
    );
  }
}

class _FrequencyRow extends StatelessWidget {
  final FrequencyType value;
  final String label;

  const _FrequencyRow({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<FrequencyType>(
          value: value,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        ),
        const SizedBox(width: 8),
        AppText(
          label,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DayPeriodsEditor extends StatelessWidget {
  final String title;
  final List<_Period> periods;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int index, _Period value) onChange;

  const _DayPeriodsEditor({
    required this.title,
    required this.periods,
    required this.onAdd,
    required this.onRemove,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            title,
            textAlign: TextAlign.start,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...List.generate(periods.length, (index) {
            final period = periods[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          _periodTitle(index),
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (periods.length > 1)
                          IconButton(
                            onPressed: () => onRemove(index),
                            visualDensity: VisualDensity.compact,
                            icon: const FaIcon(
                              FontAwesomeIcons.trash,
                              size: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeDropdown(
                            label: 'من',
                            value: period.from,
                            onChanged: (value) => onChange(index, period.copyWith(from: value)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimeDropdown(
                            label: 'إلى',
                            value: period.to,
                            onChanged: (value) => onChange(index, period.copyWith(to: value)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: .21)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.plus, size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  AppText(
                    'إضافة فترة',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeDropdown extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _TimeDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          value: _normalizeTime(value),
          isExpanded: true,
          menuMaxHeight: 360,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            prefixIcon: const Padding(
              padding: EdgeInsetsDirectional.only(start: 8, end: 4),
              child: FaIcon(
                FontAwesomeIcons.solidClock,
                size: 13,
                color: Color(0xFF9CA3AF),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 28),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: _timeSlots.map((minutes) {
            return DropdownMenuItem<int>(
              value: minutes,
              child: AppText(
                _displayTime(minutes),
                textDirection: ui.TextDirection.ltr,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;

  const _ProductTile({required this.name, required this.onRemove});

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
          Expanded(child: AppText(name)),
          IconButton(
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            icon: const FaIcon(
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
