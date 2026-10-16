import 'cleaning_progressive_room_state.dart';
import 'cleaning_room_size_breakdown.dart';
import 'cleaning_type.dart';

String cleaningRoomLabel(CleaningProgressiveRoomUnit room) =>
    '${switch (room.roomType) {
      CleaningRoomType.bedroom => 'غرفة نوم',
      CleaningRoomType.bathroom => 'حمام',
      CleaningRoomType.kitchen => 'مطبخ',
      CleaningRoomType.livingRoom => 'غرفة معيشة',
      CleaningRoomType.corridor => 'ممر',
      CleaningRoomType.balcony => 'شرفة',
      CleaningRoomType.shed => 'مستودع',
    }} ${room.index}';

String cleaningSizeLabel(CleaningRoomSize size) => switch (size) {
  CleaningRoomSize.small => 'صغيرة',
  CleaningRoomSize.medium => 'متوسطة',
  CleaningRoomSize.large => 'كبيرة',
};

String cleaningClock(DateTime instant) =>
    '${instant.hour.toString().padLeft(2, '0')}:${instant.minute.toString().padLeft(2, '0')}';

enum CleaningMaterialChoice { customerAll, customerPartial, platformAll }

extension CleaningMaterialChoiceCopy on CleaningMaterialChoice {
  String get apiValue => switch (this) {
    CleaningMaterialChoice.customerAll => 'customer_all',
    CleaningMaterialChoice.customerPartial => 'customer_partial',
    CleaningMaterialChoice.platformAll => 'platform_all',
  };

  String get label => switch (this) {
    CleaningMaterialChoice.customerAll => 'كل المواد متوفرة عندي',
    CleaningMaterialChoice.customerPartial => 'تنقصني بعض المواد',
    CleaningMaterialChoice.platformAll => 'أحتاج توفير مواد التنظيف',
  };
}

class PeriodMaterialDecision {
  PeriodMaterialDecision({this.choice, List<int> missingIds = const []})
    : missingIds = List.unmodifiable(missingIds);

  final CleaningMaterialChoice? choice;
  final List<int> missingIds;
  bool get complete =>
      choice != null &&
      (choice != CleaningMaterialChoice.customerPartial ||
          missingIds.isNotEmpty);

  Map<String, dynamic> toJson() => {
    'choice': (choice ?? CleaningMaterialChoice.customerAll).apiValue,
    'materialTypeIds': missingIds,
  };
}

class PeriodSpecialistService {
  PeriodSpecialistService({
    required this.serviceKey,
    required this.serviceId,
    required List<String> targetRoomKeys,
    this.quantity = 1,
    this.dirtiness,
  }) : targetRoomKeys = List.unmodifiable(targetRoomKeys);

  final String serviceKey;
  final int serviceId;
  final List<String> targetRoomKeys;
  final double quantity;
  final String? dirtiness;

  PeriodSpecialistService copyWith({double? quantity, String? dirtiness}) =>
      PeriodSpecialistService(
        serviceKey: serviceKey,
        serviceId: serviceId,
        targetRoomKeys: targetRoomKeys,
        quantity: quantity ?? this.quantity,
        dirtiness: dirtiness ?? this.dirtiness,
      );

  Map<String, dynamic> toJson() => {
    'serviceKey': serviceKey,
    'specialServiceId': serviceId,
    'targetRoomKeys': targetRoomKeys,
    'quantity': quantity,
    'dirtinessLevel': dirtiness,
  };
}

class RoomScheduleDraft {
  const RoomScheduleDraft({
    required this.scheduleKey,
    required this.roomKey,
    required this.visitKey,
    required this.start,
    this.workers = 1,
    this.workMinutes,
  });

  final String scheduleKey;
  final String roomKey;
  final String visitKey;
  // Service wall time in the server's advertised timezone, never device UTC.
  final DateTime start;
  final int workers;
  final int? workMinutes;
  int? get durationMinutes =>
      workMinutes == null ? null : (workMinutes! / workers).ceil();
  DateTime? get end => durationMinutes == null
      ? null
      : start.add(Duration(minutes: durationMinutes!));

  RoomScheduleDraft copyWith({
    DateTime? start,
    int? workers,
    int? workMinutes,
  }) => RoomScheduleDraft(
    scheduleKey: scheduleKey,
    roomKey: roomKey,
    visitKey: visitKey,
    start: start ?? this.start,
    workers: workers ?? this.workers,
    workMinutes: workMinutes ?? this.workMinutes,
  );

  Map<String, dynamic> toJson() => {
    'scheduleKey': scheduleKey,
    'roomKey': roomKey,
    'scheduledDate': start.toIso8601String().substring(0, 10),
    'scheduledTime': cleaningClock(start),
    'numberOfWorkers': workers,
  };
}

class TimePeriodDraft {
  TimePeriodDraft({
    required this.periodKey,
    required this.visitKey,
    required this.start,
    required this.end,
    required List<String> scheduleKeys,
    PeriodMaterialDecision? materials,
    List<PeriodSpecialistService> services = const [],
    this.servicesReviewed = false,
  }) : scheduleKeys = List.unmodifiable(scheduleKeys),
       materials = materials ?? PeriodMaterialDecision(),
       services = List.unmodifiable(services);

  final String periodKey;
  final String visitKey;
  final DateTime start;
  final DateTime end;
  final List<String> scheduleKeys;
  final PeriodMaterialDecision materials;
  final List<PeriodSpecialistService> services;
  final bool servicesReviewed;
  bool get customized =>
      materials.choice != null || servicesReviewed || services.isNotEmpty;
  String get rangeLabel => '${cleaningClock(start)}–${cleaningClock(end)}';

  TimePeriodDraft copyWith({
    PeriodMaterialDecision? materials,
    List<PeriodSpecialistService>? services,
    bool? servicesReviewed,
  }) => TimePeriodDraft(
    periodKey: periodKey,
    visitKey: visitKey,
    start: start,
    end: end,
    scheduleKeys: scheduleKeys,
    materials: materials ?? this.materials,
    services: services ?? this.services,
    servicesReviewed: servicesReviewed ?? this.servicesReviewed,
  );

  Map<String, dynamic> toJson() => {
    'periodKey': periodKey,
    'roomScheduleKeys': scheduleKeys,
    'materials': materials.toJson(),
    'specialServices': services.map((service) => service.toJson()).toList(),
  };
}

class PeriodReconciliation {
  PeriodReconciliation(this.periodKey, List<TimePeriodDraft> sources)
    : sources = List.unmodifiable(sources);
  final String periodKey;
  final List<TimePeriodDraft> sources;
}

class CleaningBookingDraft {
  CleaningBookingDraft({
    required List<CleaningProgressiveRoomUnit> rooms,
    required List<RoomScheduleDraft> schedules,
    List<TimePeriodDraft> periods = const [],
    List<PeriodReconciliation> pending = const [],
    this.revision = 0,
  }) : rooms = List.unmodifiable(rooms),
       schedules = List.unmodifiable(schedules),
       periods = List.unmodifiable(periods),
       pending = List.unmodifiable(pending);

  factory CleaningBookingDraft.fromRooms(
    List<CleaningProgressiveRoomUnit> rooms,
    DateTime date,
  ) => CleaningBookingDraft(
    rooms: rooms,
    schedules: [
      for (final room in rooms)
        RoomScheduleDraft(
          scheduleKey: 'visit.1.${room.key}',
          roomKey: room.key,
          visitKey: 'visit.1',
          start: DateTime(date.year, date.month, date.day, 9),
        ),
    ],
  );

  final List<CleaningProgressiveRoomUnit> rooms;
  final List<RoomScheduleDraft> schedules;
  final List<TimePeriodDraft> periods;
  final List<PeriodReconciliation> pending;
  final int revision;
  CleaningProgressiveRoomUnit room(String key) =>
      rooms.firstWhere((room) => room.key == key);
  List<RoomScheduleDraft> schedulesFor(TimePeriodDraft period) => schedules
      .where((schedule) => period.scheduleKeys.contains(schedule.scheduleKey))
      .toList();

  CleaningBookingDraft replaceSchedule(RoomScheduleDraft updated) => _regroup([
    for (final schedule in schedules)
      schedule.scheduleKey == updated.scheduleKey ? updated : schedule,
  ]);

  CleaningBookingDraft replacePeriod(TimePeriodDraft updated) =>
      CleaningBookingDraft(
        rooms: rooms,
        schedules: schedules,
        periods: [
          for (final period in periods)
            period.periodKey == updated.periodKey ? updated : period,
        ],
        pending: pending,
        revision: revision + 1,
      );

  CleaningBookingDraft reconcileRooms(
    List<CleaningProgressiveRoomUnit> updatedRooms,
  ) {
    final roomKeys = updatedRooms.map((room) => room.key).toSet();
    final existing = schedules
        .where((schedule) => roomKeys.contains(schedule.roomKey))
        .toList();
    final visits = schedules.map((schedule) => schedule.visitKey).toSet();
    for (final visit in visits) {
      final template = schedules.firstWhere(
        (schedule) => schedule.visitKey == visit,
      );
      for (final room in updatedRooms) {
        if (!existing.any(
          (schedule) =>
              schedule.visitKey == visit && schedule.roomKey == room.key,
        )) {
          existing.add(
            RoomScheduleDraft(
              scheduleKey: '$visit.${room.key}',
              roomKey: room.key,
              visitKey: visit,
              start: template.start,
            ),
          );
        }
      }
    }
    return CleaningBookingDraft(
      rooms: updatedRooms,
      schedules: existing,
      periods: periods,
      revision: revision + 1,
    )._regroup(existing);
  }

  CleaningBookingDraft applyAuthoritativeVisits(
    List<Map<String, dynamic>> visits,
  ) {
    final estimates = <String, Map<String, dynamic>>{};
    for (final visit in visits) {
      for (final schedule in (visit['roomSchedules'] as List).cast<Map>()) {
        estimates[schedule['scheduleKey'].toString()] =
            Map<String, dynamic>.from(schedule);
      }
    }
    return _regroup([
      for (final schedule in schedules)
        schedule.copyWith(
          workMinutes:
              (estimates[schedule.scheduleKey]?['estimatedWorkMinutes'] as num?)
                  ?.toInt(),
        ),
    ]);
  }

  CleaningBookingDraft _regroup(List<RoomScheduleDraft> nextSchedules) {
    final groups = <String, List<RoomScheduleDraft>>{};
    for (final schedule in nextSchedules) {
      if (schedule.end == null) continue;
      final interval = '${schedule.visitKey}|${schedule.start}|${schedule.end}';
      (groups[interval] ??= []).add(schedule);
    }
    final nextPeriods = <TimePeriodDraft>[];
    final conflicts = <PeriodReconciliation>[];
    for (final group in groups.values) {
      final keys = group.map((schedule) => schedule.scheduleKey).toList()
        ..sort();
      final same = periods
          .where((period) => _sameKeys(period.scheduleKeys, keys))
          .firstOrNull;
      final sources = periods
          .where(
            (period) =>
                period.customized && period.scheduleKeys.any(keys.contains),
          )
          .toList();
      final period = TimePeriodDraft(
        periodKey: same?.periodKey ?? _stableKey('period', keys),
        visitKey: group.first.visitKey,
        start: group.first.start,
        end: group.first.end!,
        scheduleKeys: keys,
        materials: same?.materials,
        services: same?.services ?? [],
        servicesReviewed: same?.servicesReviewed ?? false,
      );
      nextPeriods.add(period);
      if (same == null && sources.isNotEmpty) {
        conflicts.add(PeriodReconciliation(period.periodKey, sources));
      }
    }
    nextPeriods.sort((a, b) => a.start.compareTo(b.start));
    return CleaningBookingDraft(
      rooms: rooms,
      schedules: nextSchedules,
      periods: nextPeriods,
      pending: conflicts.isEmpty
          ? pending
                .where(
                  (conflict) => nextPeriods.any(
                    (period) => period.periodKey == conflict.periodKey,
                  ),
                )
                .toList()
          : conflicts,
      revision: revision + 1,
    );
  }

  CleaningBookingDraft resolvePeriod(
    String periodKey,
    TimePeriodDraft? source,
  ) {
    final target = periods.firstWhere(
      (period) => period.periodKey == periodKey,
    );
    final targetRooms = schedulesFor(
      target,
    ).map((schedule) => schedule.roomKey).toSet();
    final copied = target.copyWith(
      materials: source?.materials ?? PeriodMaterialDecision(),
      services: [
        for (final service in source?.services ?? <PeriodSpecialistService>[])
          if (service.targetRoomKeys.any(targetRooms.contains))
            PeriodSpecialistService(
              serviceKey: service.serviceKey,
              serviceId: service.serviceId,
              targetRoomKeys: service.targetRoomKeys
                  .where(targetRooms.contains)
                  .toList(),
              quantity: service.quantity,
              dirtiness: service.dirtiness,
            ),
      ],
      servicesReviewed: source?.servicesReviewed ?? false,
    );
    return CleaningBookingDraft(
      rooms: rooms,
      schedules: schedules,
      periods: [
        for (final period in periods)
          period.periodKey == periodKey ? copied : period,
      ],
      pending: pending
          .where((conflict) => conflict.periodKey != periodKey)
          .toList(),
      revision: revision + 1,
    );
  }

  CleaningBookingDraft copyMaterials(String sourceKey, Set<String> targetKeys) {
    final source = periods.firstWhere(
      (period) => period.periodKey == sourceKey,
    );
    return CleaningBookingDraft(
      rooms: rooms,
      schedules: schedules,
      periods: [
        for (final period in periods)
          targetKeys.contains(period.periodKey)
              ? period.copyWith(
                  materials: PeriodMaterialDecision(
                    choice: source.materials.choice,
                    missingIds: source.materials.missingIds,
                  ),
                )
              : period,
      ],
      pending: pending,
      revision: revision + 1,
    );
  }

  CleaningBookingDraft copyServices(String sourceKey, Set<String> targetKeys) {
    final source = periods.firstWhere(
      (period) => period.periodKey == sourceKey,
    );
    final sourceRooms = schedulesFor(
      source,
    ).map((schedule) => room(schedule.roomKey)).toList();
    final copied = <TimePeriodDraft>[];
    for (final period in periods) {
      if (!targetKeys.contains(period.periodKey)) {
        copied.add(period);
        continue;
      }
      final targetRooms = schedulesFor(
        period,
      ).map((schedule) => room(schedule.roomKey)).toList();
      final services = <PeriodSpecialistService>[];
      for (final service in source.services) {
        final targets = <String>[];
        for (final sourceRoomKey in service.targetRoomKeys) {
          final type = sourceRooms
              .firstWhere((room) => room.key == sourceRoomKey)
              .roomType;
          final candidates = targetRooms.where(
            (room) => room.roomType == type && !targets.contains(room.key),
          );
          if (candidates.isEmpty) {
            throw StateError('لا توجد غرفة مناسبة لنسخ الخدمة');
          }
          targets.add(candidates.first.key);
        }
        services.add(
          PeriodSpecialistService(
            serviceKey: _stableKey('service', [
              period.periodKey,
              service.serviceKey,
            ]),
            serviceId: service.serviceId,
            targetRoomKeys: targets,
            quantity: service.quantity,
            dirtiness: service.dirtiness,
          ),
        );
      }
      copied.add(period.copyWith(services: services, servicesReviewed: true));
    }
    return CleaningBookingDraft(
      rooms: rooms,
      schedules: schedules,
      periods: copied,
      pending: pending,
      revision: revision + 1,
    );
  }

  CleaningBookingDraft addVisit(DateTime date) {
    final sequence =
        schedules
            .map((schedule) => int.parse(schedule.visitKey.split('.').last))
            .reduce((first, second) => first > second ? first : second) +
        1;
    final templates = schedules.where(
      (schedule) => schedule.visitKey == 'visit.1',
    );
    return _regroup([
      ...schedules,
      for (final schedule in templates)
        RoomScheduleDraft(
          scheduleKey: 'visit.$sequence.${schedule.roomKey}',
          roomKey: schedule.roomKey,
          visitKey: 'visit.$sequence',
          workers: schedule.workers,
          workMinutes: schedule.workMinutes,
          start: DateTime(
            date.year,
            date.month,
            date.day,
            schedule.start.hour,
            schedule.start.minute,
          ),
        ),
    ]);
  }

  CleaningBookingDraft removeVisit(String visitKey) => _regroup([
    for (final schedule in schedules)
      if (schedule.visitKey != visitKey) schedule,
  ]);

  int get peakWorkers {
    final events = <({DateTime at, int delta})>[];
    for (final schedule in schedules) {
      if (schedule.end == null) continue;
      events.add((at: schedule.start, delta: schedule.workers));
      events.add((at: schedule.end!, delta: -schedule.workers));
    }
    events.sort(
      (a, b) =>
          a.at == b.at ? a.delta.compareTo(b.delta) : a.at.compareTo(b.at),
    );
    var current = 0;
    var peak = 0;
    for (final event in events) {
      current += event.delta;
      if (current > peak) peak = current;
    }
    return peak;
  }

  Map<String, dynamic> toJson() => {
    'contractVersion': 2,
    'rooms': [
      for (final room in rooms)
        {
          'roomKey': room.key,
          'roomType': room.roomType.apiKey,
          'size': room.size.apiValue,
          'cleaningMode': room.cleaningType.cleaningModeValue,
        },
    ],
    'visits': [
      for (final visitKey
          in schedules.map((schedule) => schedule.visitKey).toSet())
        {
          'visitKey': visitKey,
          'sequence': int.parse(visitKey.split('.').last),
          'roomSchedules': schedules
              .where((schedule) => schedule.visitKey == visitKey)
              .map((schedule) => schedule.toJson())
              .toList(),
          'timePeriods': periods
              .where((period) => period.visitKey == visitKey)
              .map((period) => period.toJson())
              .toList(),
        },
    ],
  };
}

bool _sameKeys(List<String> first, List<String> second) =>
    first.length == second.length && first.every(second.contains);

String _stableKey(String prefix, List<String> parts) {
  var hash = 0x811c9dc5;
  for (final code in parts.join('|').codeUnits) {
    hash = ((hash ^ code) * 0x01000193) & 0xffffffff;
  }
  return '$prefix.${hash.toRadixString(16).padLeft(8, '0')}';
}
