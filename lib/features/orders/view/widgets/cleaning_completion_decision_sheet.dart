import 'package:common_package/common_package.dart';
import 'package:common_package/helpers/dio_network.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_booking_status.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import '../../domain/usecases/fetch_cleaning_order_details_use_case.dart';
import '../../domain/usecases/fetch_cleaning_orders_use_case.dart';

enum CleaningCompletionDecision { confirmed, rejected, extensionRequested }

class _ExtensionTimeOption {
  const _ExtensionTimeOption({required this.minutes, required this.label, this.price, this.currency});

  final int minutes;
  final String label;
  final double? price;
  final String? currency;

  String get formattedPrice {
    final amount = price;
    if (amount == null) return '';
    final resolvedCurrency = switch ((currency ?? '').toUpperCase()) {
      'SYP' => 'ل.س',
      final value when value.isNotEmpty => value,
      _ => 'ل.س',
    };
    return '${amount.formatWithComma()} $resolvedCurrency';
  }
}

class _FinishedTaskGroup {
  const _FinishedTaskGroup({required this.title, required this.items});

  final String title;
  final List<String> items;
}

Map<String, dynamic> _completionAsMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, nestedValue) => MapEntry(key.toString(), nestedValue));
  }
  return const <String, dynamic>{};
}

dynamic _completionPick(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    if (!map.containsKey(key)) continue;
    final value = map[key];
    if (value != null) return value;
  }
  return null;
}

String? _completionText(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

Map<String, dynamic> _completionPayloadData(dynamic payload) {
  final root = _completionAsMap(payload);
  final data = _completionAsMap(root['data']);
  return data.isEmpty ? root : data;
}

List<String> _completionSnapshotLabels(dynamic value) {
  if (value is! List) return const <String>[];

  final labels = <String>[];
  for (final item in value) {
    String? label;
    String? detail;

    if (item is String) {
      label = item.trim();
    } else if (item is Map) {
      final map = _completionAsMap(item);
      label = _completionText(
        _completionPick(map, const <String>[
          'label',
          'name',
          'displayLabel',
          'display_label',
          'roomTypeLabel',
          'room_type_label',
          'roomType',
          'room_type',
          'roomKey',
          'room_key',
        ]),
      );
      detail = _completionText(map['detail']);
    }

    if (label == null || label.isEmpty) continue;
    if (detail != null && detail.isNotEmpty && !label.contains(detail)) {
      label = '$label: $detail';
    }
    if (!labels.contains(label)) labels.add(label);
  }

  return labels;
}

class CleaningCompletionDecisionSheet {
  static Future<CleaningCompletionDecision?> show(
    BuildContext context, {
    required Future<String?> Function() onConfirm,
    required Future<String?> Function(String? reason) onReject,
    required Future<String?> Function(int minutes) onExtend,
    required Future<List<CleaningExtensionRangeModel>> Function() fetchExtensionTimeRanges,
    bool useRootNavigator = true,
  }) async {
    final orderId = _resolveOrderId(context);

    return showModalBottomSheet<CleaningCompletionDecision>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _CleaningCompletionDecisionSheetBody(
        orderId: orderId,
        onConfirm: onConfirm,
        onReject: onReject,
        onExtend: onExtend,
        fetchExtensionTimeRanges: fetchExtensionTimeRanges,
      ),
    );
  }

  static int? _resolveOrderId(BuildContext context) {
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) return args;
      final value = (args as dynamic)?.orderId;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    } catch (_) {
      return null;
    }
  }
}

class _CleaningCompletionDecisionSheetBody extends StatefulWidget {
  const _CleaningCompletionDecisionSheetBody({
    required this.orderId,
    required this.onConfirm,
    required this.onReject,
    required this.onExtend,
    required this.fetchExtensionTimeRanges,
  });

  final int? orderId;
  final Future<String?> Function() onConfirm;
  final Future<String?> Function(String? reason) onReject;
  final Future<String?> Function(int minutes) onExtend;
  final Future<List<CleaningExtensionRangeModel>> Function() fetchExtensionTimeRanges;

  @override
  State<_CleaningCompletionDecisionSheetBody> createState() => _CleaningCompletionDecisionSheetBodyState();
}

class _CleaningCompletionDecisionSheetBodyState extends State<_CleaningCompletionDecisionSheetBody> {
  bool _submitting = false;
  bool _loadingFinishedTasks = false;
  String? _error;
  List<_FinishedTaskGroup> _finishedTaskGroups = const <_FinishedTaskGroup>[];

  @override
  void initState() {
    super.initState();
    _loadFinishedTasks();
  }

  Future<void> _loadFinishedTasks() async {
    setState(() => _loadingFinishedTasks = true);
    try {
      final orderId = widget.orderId ?? await _resolveAwaitingCompletionOrderId();
      if (orderId == null) {
        if (!mounted) return;
        setState(() => _loadingFinishedTasks = false);
        return;
      }

      final snapshotGroups = await _fetchBackendFinishedTaskGroups(orderId);
      final response = await getIt<FetchCleaningOrderDetailsUseCase>()(
        FetchCleaningOrderDetailsParams(orderId: orderId),
      );
      if (!mounted) return;
      response.fold(
        (_) => setState(() {
          _finishedTaskGroups = snapshotGroups;
          _loadingFinishedTasks = false;
        }),
        (result) {
          final order = result.data;
          final fallbackGroups = _buildFinishedTaskGroups(order);
          setState(() {
            _finishedTaskGroups = snapshotGroups.isNotEmpty ? snapshotGroups : fallbackGroups;
            _loadingFinishedTasks = false;
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingFinishedTasks = false);
    }
  }

  Future<int?> _resolveAwaitingCompletionOrderId() async {
    final useCase = getIt<FetchCleaningOrdersUseCase>();
    final filteredResponse = await useCase(
      FetchCleaningOrdersParams(
        status: CleaningBookingStatus.awaitingCustomerCompletion,
        page: 1,
        perPage: 5,
      ),
    );
    final filteredOrderId = filteredResponse.fold<int?>(
      (_) => null,
      (result) => _firstAwaitingCompletionOrderId(result.data),
    );
    if (filteredOrderId != null) return filteredOrderId;

    final unfilteredResponse = await useCase(
      FetchCleaningOrdersParams(page: 1, perPage: 25),
    );
    return unfilteredResponse.fold<int?>(
      (_) => null,
      (result) => _firstAwaitingCompletionOrderId(result.data),
    );
  }

  int? _firstAwaitingCompletionOrderId(List<CleaningOrderModel> orders) {
    for (final order in orders) {
      final status = (order.status ?? '').trim().toLowerCase();
      if (status != CleaningBookingStatus.awaitingCustomerCompletion) continue;
      final id = order.id;
      if (id != null) return id;
    }
    return null;
  }

  Future<List<_FinishedTaskGroup>> _fetchBackendFinishedTaskGroups(int orderId) async {
    try {
      final dynamic response = await getIt<DioNetwork>().getData(
        endPoint: '/api/v1/user/cleaning/orders/$orderId',
      );
      final data = _completionPayloadData(response.data);
      return _buildFinishedSnapshotGroups(data);
    } catch (_) {
      return const <_FinishedTaskGroup>[];
    }
  }

  List<_FinishedTaskGroup> _buildFinishedSnapshotGroups(Map<String, dynamic> data) {
    if (data.isEmpty) return const <_FinishedTaskGroup>[];

    final completionRequest = _completionAsMap(
      data['completionRequest'] ?? data['completion_request'],
    );
    final serviceItems = _completionSnapshotLabels(
      data['workerFinishedCleaningServices'] ??
          data['worker_finished_cleaning_services'] ??
          completionRequest['finishedCleaningServices'] ??
          completionRequest['finished_cleaning_services'],
    );
    final roomItems = _completionSnapshotLabels(
      data['workerFinishedPropertyRooms'] ??
          data['worker_finished_property_rooms'] ??
          completionRequest['finishedPropertyRooms'] ??
          completionRequest['finished_property_rooms'],
    );

    return <_FinishedTaskGroup>[
      if (serviceItems.isNotEmpty) _FinishedTaskGroup(title: 'الخدمات التي أنهاها العامل', items: serviceItems),
      if (roomItems.isNotEmpty) _FinishedTaskGroup(title: 'الغرف التي أنهاها العامل', items: roomItems),
    ];
  }

  List<_FinishedTaskGroup> _buildFinishedTaskGroups(CleaningOrderDetailModel? order) {
    if (order == null) return const <_FinishedTaskGroup>[];
    final serviceItems = <String>[];
    for (final service in order.services ?? const <CleaningOrderLineItemModel>[]) {
      final name = service.name?.trim();
      if (name != null && name.isNotEmpty) serviceItems.add(name);
    }
    for (final addon in order.addons ?? const <CleaningOrderLineItemModel>[]) {
      final name = addon.name?.trim();
      if (name != null && name.isNotEmpty && !serviceItems.contains(name)) serviceItems.add(name);
    }

    final roomItems = <String>[];
    for (final room in order.roomAssignments ?? const <CleaningRoomAssignmentModel>[]) {
      final label = room.displayLabel?.trim();
      final fallback = room.roomType?.trim();
      final value = label != null && label.isNotEmpty ? label : fallback;
      if (value != null && value.isNotEmpty) roomItems.add(value);
    }

    return <_FinishedTaskGroup>[
      if (serviceItems.isNotEmpty) _FinishedTaskGroup(title: 'الخدمات التي أنهاها العامل', items: serviceItems),
      if (roomItems.isNotEmpty) _FinishedTaskGroup(title: 'الغرف التي أنهاها العامل', items: roomItems),
    ];
  }

  Future<void> _run(Future<String?> Function() action, CleaningCompletionDecision decision) async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final err = await action();
    if (!mounted) return;
    if (err != null && err.isNotEmpty) {
      setState(() {
        _submitting = false;
        _error = err;
      });
      return;
    }
    Navigator.of(context).pop(decision);
  }

  Future<void> _onExtendPressed() async {
    final selected = await showDialog<_ExtensionTimeOption>(
      context: context,
      useRootNavigator: true,
      builder: (_) => _ExtensionTimePickerDialog(
        fetchExtensionTimeRanges: widget.fetchExtensionTimeRanges,
        finishedTaskGroups: _finishedTaskGroups,
      ),
    );
    if (selected == null) return;
    if (selected.minutes <= 0) {
      setState(() => _error = 'يرجى اختيار مدة تمديد صالحة.');
      return;
    }
    await _run(() => widget.onExtend(selected.minutes), CleaningCompletionDecision.extensionRequested);
  }

  Future<void> _onRejectPressed() async {
    final reasonController = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        title: const Text('العمل لم يكتمل بعد'),
        content: TextField(
          controller: reasonController,
          minLines: 2,
          maxLines: 3,
          maxLength: 500,
          decoration: const InputDecoration(hintText: 'اكتب ملاحظتك (اختياري)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد')),
        ],
      ),
    );
    final reason = reasonController.text.trim();
    reasonController.dispose();
    if (accepted != true) return;
    await _run(() => widget.onReject(reason.isEmpty ? null : reason), CleaningCompletionDecision.rejected);
  }

  Widget _buildFinishedTasksSection() {
    if (_loadingFinishedTasks) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_finishedTaskGroups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xffF9FAFB), borderRadius: BorderRadius.circular(12)),
        child: AppText.bodySmall('لم يرسل العامل تفاصيل مهام منجزة.', color: const Color(0xff6B7280), textAlign: TextAlign.center),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xffF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xffE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.bodyMedium('المهام التي أبلغ العامل أنه أنهاها', fontWeight: FontWeight.w800, color: const Color(0xff374151)),
          const SizedBox(height: 8),
          ..._finishedTaskGroups.map((group) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodySmall(group.title, fontWeight: FontWeight.w700, color: const Color(0xff1E2A78)),
                    const SizedBox(height: 4),
                    ...group.items.map((item) => Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8, bottom: 3),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 16, color: Color(0xff20B7C4)),
                              const SizedBox(width: 6),
                              Expanded(child: AppText.bodySmall(item, color: const Color(0xff4B5563))),
                            ],
                          ),
                        )),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 18, right: 18, top: 12, bottom: MediaQuery.viewInsetsOf(context).bottom + 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(onPressed: _submitting ? null : () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
          ),
          const Icon(Icons.verified_outlined, color: Color(0xff20B7C4), size: 74),
          const SizedBox(height: 12),
          AppText.titleLarge('مقدم الخدمة قد أنهى المهمة', textAlign: TextAlign.center, fontWeight: FontWeight.w700, color: const Color(0xff374151)),
          const SizedBox(height: 4),
          AppText.titleMedium('يرجى التأكيد', textAlign: TextAlign.center, fontWeight: FontWeight.w700, color: const Color(0xff374151)),
          const SizedBox(height: 12),
          _buildFinishedTasksSection(),
          if (_error != null) ...[
            const SizedBox(height: 10),
            AppText.bodySmall(_error!, textAlign: TextAlign.center, color: context.error),
          ],
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('completion_extend_button'),
            onPressed: _submitting || _loadingFinishedTasks ? null : _onExtendPressed,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xff20B7C4), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13)),
            child: _submitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : AppText.labelLarge('أرغب في تمديد الوقت', color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting ? null : _onRejectPressed,
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xff9CA3AF), side: const BorderSide(color: Color(0xffD1D5DB)), padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: AppText.labelLarge('لا، العمل لم ينته بعد', color: const Color(0xff9CA3AF)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _submitting ? null : () => _run(widget.onConfirm, CleaningCompletionDecision.confirmed),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xff1E2A78), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: AppText.labelLarge('التأكيد و الانتهاء', color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExtensionTimePickerDialog extends StatefulWidget {
  const _ExtensionTimePickerDialog({
    required this.fetchExtensionTimeRanges,
    required this.finishedTaskGroups,
  });

  final Future<List<CleaningExtensionRangeModel>> Function() fetchExtensionTimeRanges;
  final List<_FinishedTaskGroup> finishedTaskGroups;

  @override
  State<_ExtensionTimePickerDialog> createState() => _ExtensionTimePickerDialogState();
}

class _ExtensionTimePickerDialogState extends State<_ExtensionTimePickerDialog> {
  _ExtensionTimeOption? _selected;
  List<_ExtensionTimeOption> _options = const <_ExtensionTimeOption>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ranges = await widget.fetchExtensionTimeRanges();
      if (!mounted) return;
      final options = ranges.map(_ExtensionTimeOptionMapper.fromRange).where((option) => option != null).cast<_ExtensionTimeOption>().toList(growable: false);
      setState(() {
        _options = options;
        _selected = options.isEmpty ? null : options.first;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _options = const <_ExtensionTimeOption>[];
        _selected = null;
        _loading = false;
        _error = 'تعذر تحميل خيارات التمديد';
      });
    }
  }

  Widget _buildFinishedTasksPreview() {
    final groups = widget.finishedTaskGroups;
    if (groups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xffF9FAFB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: AppText.bodySmall(
          'لم يرسل العامل تفاصيل مهام منجزة.',
          color: const Color(0xff6B7280),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.bodyMedium(
            'المهام التي أبلغ العامل أنه أنهاها',
            fontWeight: FontWeight.w800,
            color: const Color(0xff374151),
          ),
          const SizedBox(height: 8),
          ...groups.map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodySmall(
                    group.title,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff1E2A78),
                  ),
                  const SizedBox(height: 4),
                  ...group.items.map(
                    (item) => Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8, bottom: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: Color(0xff20B7C4)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: AppText.bodySmall(item, color: const Color(0xff4B5563)),
                          ),
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('طلب تمديد وقت إضافي'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFinishedTasksPreview(),
            const SizedBox(height: 12),
            AppText.bodySmall('اختر مدة التمديد من الخيارات المتاحة من الخادم.', color: const Color(0xff6B7280)),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Column(mainAxisSize: MainAxisSize.min, children: [
                AppText.bodySmall(_error!, textAlign: TextAlign.center, color: context.error),
                const SizedBox(height: 8),
                TextButton(onPressed: _loadOptions, child: const Text('إعادة المحاولة')),
              ])
            else if (_options.isEmpty)
              AppText.bodySmall('لا توجد خيارات تمديد متاحة حالياً.', textAlign: TextAlign.center, color: const Color(0xff6B7280))
            else
              ..._options.map((option) {
                final isSelected = _selected == option;
                return InkWell(
                  key: Key('extension_option_${option.minutes}'),
                  onTap: () => setState(() => _selected = option),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xffE6F9FB) : const Color(0xffF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? const Color(0xff20B7C4) : const Color(0xffE5E7EB)),
                    ),
                    child: Row(children: [
                      Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xff20B7C4) : const Color(0xff9CA3AF)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        AppText.bodyMedium(option.label, fontWeight: FontWeight.w700, color: const Color(0xff374151)),
                        if (option.formattedPrice.isNotEmpty) ...[const SizedBox(height: 2), AppText.bodySmall(option.formattedPrice, color: const Color(0xff6B7280))],
                      ])),
                    ]),
                  ),
                );
              }),
          ],
        ),
      ),
      actions: [
        TextButton(key: const Key('extension_cancel'), onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(
          key: const Key('extension_submit'),
          onPressed: _loading || _selected == null || _selected!.minutes <= 0 ? null : () => Navigator.pop(context, _selected),
          child: const Text('إرسال'),
        ),
      ],
    );
  }
}

class _ExtensionTimeOptionMapper {
  const _ExtensionTimeOptionMapper._();

  static _ExtensionTimeOption? fromRange(CleaningExtensionRangeModel range) {
    final minutes = range.requestMinutes;
    if (minutes == null || minutes <= 0 || minutes > 90) return null;
    return _ExtensionTimeOption(minutes: minutes, label: _rangeLabel(range, minutes), price: range.price, currency: range.currency);
  }

  static String _rangeLabel(CleaningExtensionRangeModel range, int minutes) {
    final label = range.label?.trim();
    if (label != null && label.isNotEmpty) return label;
    final start = range.startMinutes;
    final end = range.endMinutes;
    if (start != null && end != null) return '$start - $end دقيقة';
    return '$minutes دقيقة';
  }
}
