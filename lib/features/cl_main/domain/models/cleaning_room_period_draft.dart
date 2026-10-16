import 'cleaning_progressive_room_state.dart';
import 'cleaning_room_size_breakdown.dart';
import 'cleaning_type.dart';

/// Immutable per-room booking inputs. Copy-to-all never leaves a live binding.
class CleaningRoomPeriodDraft {
  const CleaningRoomPeriodDraft({
    required this.room,
    required this.scheduledDate,
    required this.scheduledTime,
    this.workers = 1,
    this.providedByPlatform = false,
    this.materialTypeIds = const <int>[],
    this.specialServices = const <Map<String, dynamic>>[],
    this.notes = '',
  });

  final CleaningProgressiveRoomUnit room;
  final DateTime scheduledDate;
  final String scheduledTime;
  final int workers;
  final bool providedByPlatform;
  final List<int> materialTypeIds;
  final List<Map<String, dynamic>> specialServices;
  final String notes;

  String get clientKey => room.key;

  CleaningRoomPeriodDraft copyWith({
    DateTime? scheduledDate,
    String? scheduledTime,
    int? workers,
    bool? providedByPlatform,
    List<int>? materialTypeIds,
    List<Map<String, dynamic>>? specialServices,
    String? notes,
    CleaningProgressiveRoomUnit? room,
  }) => CleaningRoomPeriodDraft(
    room: room ?? this.room,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    scheduledTime: scheduledTime ?? this.scheduledTime,
    workers: workers ?? this.workers,
    providedByPlatform: providedByPlatform ?? this.providedByPlatform,
    materialTypeIds: materialTypeIds ?? this.materialTypeIds,
    specialServices: specialServices ?? this.specialServices,
    notes: notes ?? this.notes,
  );

  CleaningRoomPeriodDraft copyRequirementsFrom(
    CleaningRoomPeriodDraft source,
  ) => copyWith(
    providedByPlatform: source.providedByPlatform,
    materialTypeIds: List<int>.unmodifiable(source.materialTypeIds),
    specialServices: List<Map<String, dynamic>>.unmodifiable(
      source.specialServices.map((item) => Map<String, dynamic>.from(item)),
    ),
  );

  Map<String, dynamic> toApiJson() => {
    'clientKey': clientKey,
    'visitSequence': 1,
    'roomType': room.roomType.apiKey,
    'size': room.size.apiValue,
    'cleaningMode': room.cleaningType.cleaningModeValue,
    'scheduledDate': scheduledDate.toIso8601String().substring(0, 10),
    'scheduledTime': scheduledTime,
    'numberOfWorkers': workers,
    'materials': <String, dynamic>{
      'providedByPlatform': providedByPlatform,
      'materialTypeIds': materialTypeIds,
    },
    'specialServices': specialServices,
    if (notes.trim().isNotEmpty) 'notes': notes.trim(),
  };
}

class CleaningRoomPeriodDrafts {
  const CleaningRoomPeriodDrafts(this.periods);

  final List<CleaningRoomPeriodDraft> periods;

  factory CleaningRoomPeriodDrafts.fromRooms(
    List<CleaningProgressiveRoomUnit> rooms, {
    required DateTime date,
    String time = '09:00',
  }) => CleaningRoomPeriodDrafts(
    List.unmodifiable(
      rooms.map(
        (room) => CleaningRoomPeriodDraft(
          room: room,
          scheduledDate: date,
          scheduledTime: time,
        ),
      ),
    ),
  );

  CleaningRoomPeriodDrafts reconcileRooms(
    List<CleaningProgressiveRoomUnit> rooms, {
    required DateTime defaultDate,
    String defaultTime = '09:00',
  }) {
    final previous = {for (final p in periods) p.clientKey: p};
    return CleaningRoomPeriodDrafts(
      List.unmodifiable(
        rooms.map((room) {
          final existing = previous[room.key];
          return existing?.copyWith(room: room) ??
              CleaningRoomPeriodDraft(
                room: room,
                scheduledDate: defaultDate,
                scheduledTime: defaultTime,
              );
        }),
      ),
    );
  }

  CleaningRoomPeriodDrafts replace(CleaningRoomPeriodDraft updated) =>
      CleaningRoomPeriodDrafts(
        List.unmodifiable(
          periods.map((p) => p.clientKey == updated.clientKey ? updated : p),
        ),
      );

  CleaningRoomPeriodDrafts copyMaterialsToAll(String sourceKey) {
    final source = periods.where((p) => p.clientKey == sourceKey).firstOrNull;
    if (source == null) return this;
    return CleaningRoomPeriodDrafts(
      List.unmodifiable(
        periods.map(
          (p) => p.clientKey == sourceKey
              ? p
              : p.copyWith(
                  providedByPlatform: source.providedByPlatform,
                  materialTypeIds: List<int>.unmodifiable(
                    source.materialTypeIds,
                  ),
                ),
        ),
      ),
    );
  }

  CleaningRoomPeriodDrafts copySpecialServicesToAll(String sourceKey) {
    final source = periods.where((p) => p.clientKey == sourceKey).firstOrNull;
    if (source == null) return this;
    return CleaningRoomPeriodDrafts(
      List.unmodifiable(
        periods.map(
          (p) => p.clientKey == sourceKey
              ? p
              : p.copyWith(
                  specialServices: List<Map<String, dynamic>>.unmodifiable(
                    source.specialServices.map(
                      (line) => Map<String, dynamic>.from(line),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  CleaningRoomPeriodDrafts copyRequirementsToAll(String sourceKey) {
    final source = periods.where((p) => p.clientKey == sourceKey).firstOrNull;
    if (source == null) return this;
    return CleaningRoomPeriodDrafts(
      List.unmodifiable(
        periods.map(
          (period) => period.clientKey == sourceKey
              ? period
              : period.copyRequirementsFrom(source),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> toApiJson() =>
      periods.map((period) => period.toApiJson()).toList(growable: false);
}
