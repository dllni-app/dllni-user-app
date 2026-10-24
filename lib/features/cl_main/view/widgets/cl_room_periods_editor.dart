import 'package:flutter/material.dart';

import '../../data/models/cleaning_services_response_model.dart';
import '../../../../core/models/cleaning_service_extras.dart';
import '../../domain/models/cleaning_room_period_draft.dart';
import '../../domain/models/cleaning_room_size_breakdown.dart';
import '../../domain/models/cleaning_type.dart';

enum ClPeriodEditingPhase { materials, specialized, schedule }

class ClRoomPeriodsEditor extends StatelessWidget {
  const ClRoomPeriodsEditor({
    super.key,
    required this.drafts,
    required this.phase,
    required this.onChanged,
    this.materials = const <CleaningMaterialLineModel>[],
    this.services = const <CleaningServiceModel>[],
    this.workMinutesByRoom = const <String, int>{},
  });

  final CleaningRoomPeriodDrafts drafts;
  final ClPeriodEditingPhase phase;
  final ValueChanged<CleaningRoomPeriodDrafts> onChanged;
  final List<CleaningMaterialLineModel> materials;
  final List<CleaningServiceModel> services;
  final Map<String, int> workMinutesByRoom;

  void _update(CleaningRoomPeriodDraft value) =>
      onChanged(drafts.replace(value));

  String _label(CleaningRoomPeriodDraft p) {
    final name = switch (p.room.roomType.apiKey) {
      'bedroom' => 'غرفة نوم',
      'bathroom' => 'حمام',
      'kitchen' => 'مطبخ',
      'living_room' => 'غرفة معيشة',
      _ => p.room.displayName ?? p.room.roomType.apiKey.replaceAll('_', ' '),
    };
    return '$name ${p.room.index}';
  }

  Future<void> _copy(
    BuildContext context,
    CleaningRoomPeriodDraft source,
  ) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تطبيق الاختيارات على الفترات'),
        content: Text(
          'هل تريد نسخ ${phase == ClPeriodEditingPhase.materials
                  ? 'مواد التنظيف'
                  : 'الخدمات المتخصصة'} من ${_label(source)} إلى بقية الفترات؟ ستُستبدل الاختيارات المماثلة فقط، وبعد النسخ يمكنك تعديل كل فترة لوحدها.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('هذه الفترة فقط'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تطبيق على كل الفترات'),
          ),
        ],
      ),
    );
    if (approved == true) {
      onChanged(
        phase == ClPeriodEditingPhase.materials
            ? drafts.copyMaterialsToAll(source.clientKey)
            : drafts.copySpecialServicesToAll(source.clientKey),
      );
    }
  }

  Widget _materials(BuildContext context, CleaningRoomPeriodDraft p) => Column(
    children: [
      SwitchListTile.adaptive(
        title: const Text('أحتاج من المنصة مواد التنظيف لهذه الفترة'),
        subtitle: const Text('عند الإيقاف حدد المواد الناقصة فقط'),
        value: p.providedByPlatform,
        onChanged: (v) => _update(
          p.copyWith(
            providedByPlatform: v,
            materialTypeIds: v ? const <int>[] : p.materialTypeIds,
          ),
        ),
      ),
      if (!p.providedByPlatform)
        Wrap(
          spacing: 5,
          runSpacing: 4,
          children: [
            for (final m in materials)
              if (m.materialTypeId != null)
                FilterChip(
                  label: Text(m.name ?? 'مواد'),
                  selected: p.materialTypeIds.contains(m.materialTypeId),
                  onSelected: (selected) {
                    final values = <int>{...p.materialTypeIds};
                    if (selected) {
                      values.add(m.materialTypeId!);
                    } else {
                      values.remove(m.materialTypeId);
                    }
                    _update(p.copyWith(materialTypeIds: values.toList()));
                  },
                ),
          ],
        ),
      TextButton.icon(
        onPressed: () => _copy(context, p),
        icon: const Icon(Icons.copy_all),
        label: const Text('تطبيق هذه الاختيارات على بقية الفترات'),
      ),
    ],
  );

  Widget _specialized(BuildContext context, CleaningRoomPeriodDraft p) =>
      Column(
        children: [
          if (services.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('لا توجد خدمات متخصصة متاحة حالياً'),
            ),
          for (final service in services)
            if (service.id != null) _serviceRow(p, service),
          TextButton.icon(
            onPressed: () => _copy(context, p),
            icon: const Icon(Icons.copy_all),
            label: const Text('تطبيق هذه الاختيارات على بقية الفترات'),
          ),
        ],
      );

  Widget _serviceRow(CleaningRoomPeriodDraft p, CleaningServiceModel service) {
    final index = p.specialServices.indexWhere(
      (line) => line['specialServiceId'] == service.id,
    );
    final selected = index >= 0;
    final existing = selected
        ? p.specialServices[index]
        : const <String, dynamic>{};
    final count = (existing['quantity'] as num?)?.toInt() ?? 1;
    final availableLevels = service.selectableDirtinessLevels;
    final displayLevels = !service.supportsDirtiness
        ? <String>[]
        : (availableLevels.length <= 2
              ? availableLevels
              : <String>[availableLevels.first, availableLevels.last]);
    final dirtiness = service.normalizeDirtinessLevel(
      existing['dirtinessLevel']?.toString(),
      preferredFallback: displayLevels.isNotEmpty
          ? displayLevels.first
          : 'light',
    );

    void change({int? quantity, String? level, bool remove = false}) {
      final next = p.specialServices
          .map((line) => Map<String, dynamic>.from(line))
          .toList();
      if (remove) {
        next.removeWhere((line) => line['specialServiceId'] == service.id);
      } else {
        final line = <String, dynamic>{
          'specialServiceId': service.id,
          'quantity': quantity ?? count,
          if (service.supportsDirtiness) 'dirtinessLevel': level ?? dirtiness,
        };
        if (selected) {
          next[index] = line;
        } else {
          next.add(line);
        }
      }
      _update(p.copyWith(specialServices: next));
    }

    return Column(
      children: [
        CheckboxListTile(
          dense: true,
          title: Text(service.name ?? 'خدمة متخصصة'),
          value: selected,
          onChanged: (checked) => change(remove: checked != true),
        ),
        if (selected)
          Row(
            children: [
              const Text('الكمية'),
              IconButton(
                onPressed: count > 1 ? () => change(quantity: count - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(count.toString()),
              IconButton(
                onPressed: count < 50
                    ? () => change(quantity: count + 1)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
              const Spacer(),
              if (displayLevels.isNotEmpty)
                DropdownButton<String>(
                  value: displayLevels.contains(dirtiness)
                      ? dirtiness
                      : displayLevels.first,
                  items: [
                    for (var index = 0; index < displayLevels.length; index++)
                      DropdownMenuItem(
                        value: displayLevels[index],
                        child: Text(index == 0 ? 'اتساخ بسيط' : 'اتساخ شديد'),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) change(level: v);
                  },
                ),
            ],
          ),
      ],
    );
  }

  Widget _schedule(BuildContext context, CleaningRoomPeriodDraft p) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: Text(p.scheduledDate.toIso8601String().substring(0, 10)),
              onPressed: () async {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final date = await showDatePicker(
                  context: context,
                  firstDate: today,
                  lastDate: today.add(const Duration(days: 365)),
                  initialDate: p.scheduledDate.isBefore(today)
                      ? today
                      : p.scheduledDate,
                );
                if (date != null) _update(p.copyWith(scheduledDate: date));
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.schedule),
              label: Text(p.scheduledTime),
              onPressed: () async {
                final parts = p.scheduledTime.split(':');
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: int.parse(parts[0]),
                    minute: int.parse(parts[1]),
                  ),
                );
                if (time != null) {
                  final value =
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                  _update(p.copyWith(scheduledTime: value));
                }
              },
            ),
          ),
        ],
      ),
      if (workMinutesByRoom.containsKey(p.clientKey))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            'المدة المتوقعة: ${(workMinutesByRoom[p.clientKey]! + p.workers - 1) ~/ p.workers} دقيقة · تتغير مباشرة بحسب عدد العمال',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      Row(
        children: [
          const Expanded(child: Text('عدد العمال لهذه الفترة')),
          IconButton(
            onPressed: p.workers > 1
                ? () => _update(p.copyWith(workers: p.workers - 1))
                : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text(p.workers.toString()),
          IconButton(
            onPressed: p.workers < 20
                ? () => _update(p.copyWith(workers: p.workers + 1))
                : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final p in drafts.periods)
        Card(
          key: ValueKey('room_period_${p.clientKey}_${phase.name}'),
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            initiallyExpanded: drafts.periods.length == 1,
            title: Text(_label(p)),
            subtitle: Text(
              '${p.room.cleaningType.title} · ${p.room.size.apiValue} · ${p.workers} عامل',
            ),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              if (phase == ClPeriodEditingPhase.materials)
                _materials(context, p),
              if (phase == ClPeriodEditingPhase.specialized)
                _specialized(context, p),
              if (phase == ClPeriodEditingPhase.schedule) _schedule(context, p),
            ],
          ),
        ),
    ],
  );
}
