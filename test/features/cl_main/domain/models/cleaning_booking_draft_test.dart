import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_booking_draft.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_progressive_room_state.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';

CleaningBookingDraft booking(List<int> minutes) {
  var draft = CleaningBookingDraft.fromRooms([
    for (var index = 0; index < minutes.length; index++)
      CleaningProgressiveRoomUnit(
        roomType: CleaningRoomType.bedroom,
        index: index + 1,
        size: CleaningRoomSize.medium,
      ),
  ], DateTime(2026, 10, 20));
  for (var index = 0; index < minutes.length; index++) {
    draft = draft.replaceSchedule(
      draft.schedules[index].copyWith(workMinutes: minutes[index]),
    );
  }
  return draft;
}

void main() {
  test(
    'two independently staffed rooms share exact boundaries and sum simultaneous demand',
    () {
      var draft = booking([240, 120]);
      draft = draft.replaceSchedule(draft.schedules.first.copyWith(workers: 2));
      expect(draft.periods, hasLength(1));
      expect(draft.periods.single.scheduleKeys, hasLength(2));
      expect(draft.periods.single.rangeLabel, '09:00–11:00');
      expect(draft.peakWorkers, 3);
      final payload = draft.toJson();
      expect((payload['rooms'] as List).length, 2);
      final visit = (payload['visits'] as List).single as Map;
      expect((visit['timePeriods'] as List).length, 1);
      expect((visit['roomSchedules'] as List).length, 2);
    },
  );

  for (final start in [
    DateTime(2026, 10, 20, 10),
    DateTime(2026, 10, 20, 11),
  ]) {
    test(
      '${start.hour == 10 ? 'partly overlapping' : 'adjacent'} intervals stay separate with correct peak',
      () {
        var draft = booking([120, 120]);
        draft = draft.replaceSchedule(
          draft.schedules.last.copyWith(start: start),
        );
        expect(draft.periods, hasLength(2));
        expect(draft.peakWorkers, start.hour == 10 ? 2 : 1);
      },
    );
  }

  test(
    'worker edit immediately splits duration and retains source choices pending explicit reconciliation',
    () {
      var draft = booking([120, 120]);
      final original = draft.periods.single;
      draft = draft.replacePeriod(
        original.copyWith(
          materials: PeriodMaterialDecision(
            choice: CleaningMaterialChoice.platformAll,
          ),
          services: [
            PeriodSpecialistService(
              serviceKey: 'service.one',
              serviceId: 9,
              targetRoomKeys: ['bedroom.1', 'bedroom.2'],
              quantity: 2,
            ),
          ],
          servicesReviewed: true,
        ),
      );
      draft = draft.replaceSchedule(draft.schedules.last.copyWith(workers: 2));
      expect(draft.schedules.last.durationMinutes, 60);
      expect(draft.periods, hasLength(2));
      expect(draft.pending, hasLength(2));
      for (final pending in [...draft.pending]) {
        draft = draft.resolvePeriod(pending.periodKey, pending.sources.single);
      }
      expect(draft.pending, isEmpty);
      expect(
        draft.periods.every(
          (period) =>
              period.materials.choice == CleaningMaterialChoice.platformAll,
        ),
        isTrue,
      );
      expect(
        draft.periods
            .map((period) => period.services.single.targetRoomKeys.single)
            .toSet(),
        {'bedroom.1', 'bedroom.2'},
      );
      expect(
        draft.periods.every((period) => period.services.single.quantity == 2),
        isTrue,
      );
    },
  );

  test(
    'merge of edited periods requires source selection instead of silently losing decisions',
    () {
      var draft = booking([60, 120]);
      draft = draft.replacePeriod(
        draft.periods.first.copyWith(
          materials: PeriodMaterialDecision(
            choice: CleaningMaterialChoice.customerAll,
          ),
        ),
      );
      draft = draft.replacePeriod(
        draft.periods.last.copyWith(
          materials: PeriodMaterialDecision(
            choice: CleaningMaterialChoice.platformAll,
          ),
        ),
      );
      draft = draft.replaceSchedule(draft.schedules.last.copyWith(workers: 2));
      expect(draft.pending.single.sources, hasLength(2));
      final source = draft.pending.single.sources.firstWhere(
        (source) =>
            source.materials.choice == CleaningMaterialChoice.platformAll,
      );
      draft = draft.resolvePeriod(draft.periods.single.periodKey, source);
      expect(
        draft.periods.single.materials.choice,
        CleaningMaterialChoice.platformAll,
      );
      expect(draft.pending, isEmpty);
    },
  );

  test(
    'material-only and service-only copies are independent and preserve schedules',
    () {
      var draft = booking([60, 120]);
      final sourceKey = draft.periods.first.periodKey;
      final targetKey = draft.periods.last.periodKey;
      draft = draft.replacePeriod(
        draft.periods.first.copyWith(
          materials: PeriodMaterialDecision(
            choice: CleaningMaterialChoice.customerPartial,
            missingIds: [4],
          ),
          services: [
            PeriodSpecialistService(
              serviceKey: 'service.one',
              serviceId: 9,
              targetRoomKeys: ['bedroom.1'],
            ),
          ],
        ),
      );
      final scheduleBefore = draft.schedules
          .map((schedule) => schedule.toJson())
          .toList();
      draft = draft.copyMaterials(sourceKey, {targetKey});
      expect(draft.periods.last.materials.missingIds, [4]);
      expect(draft.periods.last.services, isEmpty);
      draft = draft.copyServices(sourceKey, {targetKey});
      expect(draft.periods.last.services.single.targetRoomKeys, ['bedroom.2']);
      draft = draft.replacePeriod(
        draft.periods.last.copyWith(
          materials: PeriodMaterialDecision(
            choice: CleaningMaterialChoice.customerAll,
          ),
        ),
      );
      expect(draft.periods.first.materials.missingIds, [4]);
      expect(
        draft.schedules.map((schedule) => schedule.toJson()).toList(),
        scheduleBefore,
      );
    },
  );

  test(
    'large shared groups and repeated service copies keep API keys bounded',
    () {
      var draft = booking(List.filled(30, 60));
      expect(draft.periods.single.periodKey.length, lessThanOrEqualTo(64));
      draft = draft.replaceSchedule(
        draft.schedules.last.copyWith(start: DateTime(2026, 10, 20, 12)),
      );
      final source = draft.periods.first;
      draft = draft.replacePeriod(
        source.copyWith(
          services: [
            PeriodSpecialistService(
              serviceKey: 'service.${'x' * 40}',
              serviceId: 9,
              targetRoomKeys: ['bedroom.1'],
            ),
          ],
        ),
      );
      for (var index = 0; index < 12; index++) {
        final from = draft.periods[index.isEven ? 0 : 1].periodKey;
        final to = draft.periods[index.isEven ? 1 : 0].periodKey;
        draft = draft.copyServices(from, {to});
      }
      expect(
        draft.periods
            .expand((period) => period.services)
            .every((service) => service.serviceKey.length <= 64),
        isTrue,
      );
    },
  );

  test(
    'room resize preserves stable room and schedule IDs and independent recurring visits',
    () {
      var draft = booking([120]);
      final originalKey = draft.rooms.single.key;
      final scheduleKey = draft.schedules.single.scheduleKey;
      draft = draft.reconcileRooms([
        draft.rooms.single.copyWith(size: CleaningRoomSize.large),
      ]);
      draft = draft.addVisit(DateTime(2026, 10, 27));
      expect(draft.rooms.single.key, originalKey);
      expect(draft.schedules.first.scheduleKey, scheduleKey);
      expect(draft.schedules.last.roomKey, originalKey);
      expect(draft.schedules.last.visitKey, 'visit.2');
      expect(draft.periods, hasLength(2));
    },
  );
}
