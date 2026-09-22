class CleaningServiceExtrasRequest {
  const CleaningServiceExtrasRequest({
    this.requestMaterials = false,
    this.specialServices = const <CleaningSpecialServiceRequest>[],
    this.openTime,
  });

  final bool requestMaterials;
  final List<CleaningSpecialServiceRequest> specialServices;
  final CleaningOpenTimeRequest? openTime;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'requestMaterials': requestMaterials,
      'materials': <String, dynamic>{'providedByPlatform': requestMaterials},
      'specialServices': specialServices.map((item) => item.toJson()).toList(),
      if (openTime != null) 'openTime': openTime!.toJson(),
    };
  }

  CleaningServiceExtrasRequest copyWith({
    bool? requestMaterials,
    List<CleaningSpecialServiceRequest>? specialServices,
    CleaningOpenTimeRequest? openTime,
    bool clearOpenTime = false,
  }) {
    return CleaningServiceExtrasRequest(
      requestMaterials: requestMaterials ?? this.requestMaterials,
      specialServices: specialServices ?? this.specialServices,
      openTime: clearOpenTime ? null : (openTime ?? this.openTime),
    );
  }
}

class CleaningSpecialServiceRequest {
  const CleaningSpecialServiceRequest({
    required this.specialServiceId,
    this.quantity = 1,
    this.dirtinessLevel = 'medium',
    this.notes,
    this.sessionIds = const <int>[],
    this.items = const <CleaningSpecialServiceItemRequest>[],
  });

  final int specialServiceId;
  final int quantity;
  final String dirtinessLevel;
  final String? notes;
  final List<int> sessionIds;
  final List<CleaningSpecialServiceItemRequest> items;

  Map<String, dynamic> toJson() {
    final normalizedNotes = notes?.trim();
    return <String, dynamic>{
      'specialServiceId': specialServiceId,
      'quantity': quantity,
      'dirtinessLevel': dirtinessLevel,
      if (sessionIds.isNotEmpty) 'sessionIds': sessionIds,
      if (items.isNotEmpty)
        'items': items.map((item) => item.toJson()).toList(growable: false),
      if (normalizedNotes != null && normalizedNotes.isNotEmpty)
        'notes': normalizedNotes,
    };
  }

  CleaningSpecialServiceRequest copyWith({
    int? specialServiceId,
    int? quantity,
    String? dirtinessLevel,
    String? notes,
    List<int>? sessionIds,
    List<CleaningSpecialServiceItemRequest>? items,
    bool clearNotes = false,
  }) {
    return CleaningSpecialServiceRequest(
      specialServiceId: specialServiceId ?? this.specialServiceId,
      quantity: quantity ?? this.quantity,
      dirtinessLevel: dirtinessLevel ?? this.dirtinessLevel,
      notes: clearNotes ? null : (notes ?? this.notes),
      sessionIds: sessionIds ?? this.sessionIds,
      items: items ?? this.items,
    );
  }
}

class CleaningSpecialServiceItemRequest {
  const CleaningSpecialServiceItemRequest({
    required this.quantity,
    this.dirtinessLevelId,
    this.notes,
    this.attachments = const <String>[],
  });

  final double quantity;
  final int? dirtinessLevelId;
  final String? notes;
  final List<String> attachments;

  Map<String, dynamic> toJson() {
    final normalizedNotes = notes?.trim();
    return <String, dynamic>{
      'quantity': quantity,
      if (dirtinessLevelId != null) 'dirtinessLevelId': dirtinessLevelId,
      if (normalizedNotes != null && normalizedNotes.isNotEmpty)
        'notes': normalizedNotes,
      if (attachments.isNotEmpty) 'attachments': attachments,
    };
  }

  CleaningSpecialServiceItemRequest copyWith({
    double? quantity,
    int? dirtinessLevelId,
    String? notes,
    List<String>? attachments,
    bool clearDirtinessLevel = false,
    bool clearNotes = false,
  }) {
    return CleaningSpecialServiceItemRequest(
      quantity: quantity ?? this.quantity,
      dirtinessLevelId: clearDirtinessLevel
          ? null
          : (dirtinessLevelId ?? this.dirtinessLevelId),
      notes: clearNotes ? null : (notes ?? this.notes),
      attachments: attachments ?? this.attachments,
    );
  }
}

class CleaningOpenTimeRequest {
  const CleaningOpenTimeRequest({
    required this.workerCount,
    this.expectedMaxMinutes = 480,
    this.sessions = const <CleaningOpenTimeSessionRequest>[],
  });

  final int workerCount;
  final int expectedMaxMinutes;
  final List<CleaningOpenTimeSessionRequest> sessions;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'workerCount': workerCount,
    'expectedMaxMinutes': expectedMaxMinutes,
    if (sessions.isNotEmpty)
      'sessions': sessions.map((item) => item.toJson()).toList(growable: false),
  };

  CleaningOpenTimeRequest copyWith({
    int? workerCount,
    int? expectedMaxMinutes,
    List<CleaningOpenTimeSessionRequest>? sessions,
  }) {
    return CleaningOpenTimeRequest(
      workerCount: workerCount ?? this.workerCount,
      expectedMaxMinutes: expectedMaxMinutes ?? this.expectedMaxMinutes,
      sessions: sessions ?? this.sessions,
    );
  }
}

class CleaningOpenTimeSessionRequest {
  const CleaningOpenTimeSessionRequest({
    required this.date,
    required this.time,
    this.expectedMaxMinutes,
  });

  final String date;
  final String time;
  final int? expectedMaxMinutes;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'date': date,
    'time': time,
    if (expectedMaxMinutes != null) 'expectedMaxMinutes': expectedMaxMinutes,
  };
}

class CleaningMaterialLineModel {
  const CleaningMaterialLineModel({
    this.materialId,
    this.name,
    this.quantity,
    this.unit,
    this.unitPrice,
    this.totalPrice,
  });

  final int? materialId;
  final String? name;
  final double? quantity;
  final String? unit;
  final double? unitPrice;
  final double? totalPrice;

  factory CleaningMaterialLineModel.fromJson(Map<String, dynamic> json) {
    return CleaningMaterialLineModel(
      materialId: _cleaningExtrasInt(
        json['materialId'] ?? json['material_id'] ?? json['id'],
      ),
      name: _cleaningExtrasString(json['name']),
      quantity: _cleaningExtrasDouble(json['quantity']),
      unit: _cleaningExtrasString(
        json['unit'] ?? json['unitCode'] ?? json['unit_code'],
      ),
      unitPrice: _cleaningExtrasDouble(json['unitPrice'] ?? json['unit_price']),
      totalPrice: _cleaningExtrasDouble(
        json['totalPrice'] ?? json['total_price'],
      ),
    );
  }
}

class CleaningSpecialServiceLineModel {
  const CleaningSpecialServiceLineModel({
    this.specialServiceId,
    this.name,
    this.quantity,
    this.pricingUnit,
    this.dirtinessLevel,
    this.dirtinessLabel,
    this.totalPrice,
    this.imageUrl,
    this.notes,
    this.sessionIds = const <int>[],
    this.items = const <CleaningSpecialServiceItemLineModel>[],
    this.executionStatus,
    this.unableReason,
  });

  final int? specialServiceId;
  final String? name;
  final double? quantity;
  final String? pricingUnit;
  final String? dirtinessLevel;
  final String? dirtinessLabel;
  final double? totalPrice;
  final String? imageUrl;
  final String? notes;
  final List<int> sessionIds;
  final List<CleaningSpecialServiceItemLineModel> items;
  final String? executionStatus;
  final String? unableReason;

  factory CleaningSpecialServiceLineModel.fromJson(Map<String, dynamic> json) {
    return CleaningSpecialServiceLineModel(
      specialServiceId: _cleaningExtrasInt(
        json['specialServiceId'] ??
            json['special_service_id'] ??
            json['serviceId'] ??
            json['service_id'] ??
            json['id'],
      ),
      name: _cleaningExtrasString(json['name']),
      quantity: _cleaningExtrasDouble(json['quantity']),
      pricingUnit: _cleaningExtrasString(
        json['pricingUnit'] ?? json['pricing_unit'] ?? json['unit'],
      ),
      dirtinessLevel: _cleaningExtrasString(
        json['dirtinessLevel'] ?? json['dirtiness_level'],
      ),
      dirtinessLabel: _cleaningExtrasString(
        json['dirtinessLabel'] ?? json['dirtiness_label'],
      ),
      totalPrice: _cleaningExtrasDouble(
        json['totalPrice'] ?? json['total_price'],
      ),
      imageUrl: _cleaningExtrasString(
        json['imageUrl'] ?? json['image_url'] ?? json['image'],
      ),
      notes: _cleaningExtrasString(json['notes']),
      sessionIds: _cleaningExtrasIntList(
        json['sessionIds'] ?? json['session_ids'],
      ),
      items: (json['items'] is List)
          ? (json['items'] as List)
                .whereType<Map>()
                .map(_cleaningExtrasMap)
                .map(CleaningSpecialServiceItemLineModel.fromJson)
                .toList(growable: false)
          : const <CleaningSpecialServiceItemLineModel>[],
      executionStatus: _cleaningExtrasString(
        json['executionStatus'] ?? json['execution_status'],
      ),
      unableReason: _cleaningExtrasString(
        json['unableReason'] ?? json['unable_reason'],
      ),
    );
  }
}

class CleaningSpecialServiceItemLineModel {
  const CleaningSpecialServiceItemLineModel({
    this.id,
    this.dirtinessLevelId,
    this.dirtinessLevel,
    this.quantity,
    this.totalPrice,
    this.notes,
    this.beforeImages = const <String>[],
    this.afterImages = const <String>[],
  });

  final int? id;
  final int? dirtinessLevelId;
  final String? dirtinessLevel;
  final double? quantity;
  final double? totalPrice;
  final String? notes;
  final List<String> beforeImages;
  final List<String> afterImages;

  factory CleaningSpecialServiceItemLineModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CleaningSpecialServiceItemLineModel(
      id: _cleaningExtrasInt(json['id']),
      dirtinessLevelId: _cleaningExtrasInt(
        json['dirtinessLevelId'] ?? json['dirtiness_level_id'],
      ),
      dirtinessLevel: _cleaningExtrasString(
        json['dirtinessLevel'] ?? json['dirtiness_level'],
      ),
      quantity: _cleaningExtrasDouble(json['quantity']),
      totalPrice: _cleaningExtrasDouble(
        json['totalPrice'] ?? json['total_price'],
      ),
      notes: _cleaningExtrasString(json['notes']),
      beforeImages: _cleaningExtrasStringList(
        json['beforeImages'] ?? json['before_images'],
      ),
      afterImages: _cleaningExtrasStringList(
        json['afterImages'] ?? json['after_images'],
      ),
    );
  }
}

class CleaningOpenTimeModel {
  const CleaningOpenTimeModel({
    this.workerCount,
    this.hourlyRate,
    this.minimumDuration,
    this.actualDuration,
    this.billableDuration,
    this.totalPrice,
    this.currency,
    this.isPricingFinal,
    this.serverNow,
    this.ceilingEndsAt,
    this.expectedMaxMinutes,
    this.hardMaxMinutes,
    this.warningMinutes,
    this.extensionOptions = const <int>[],
    this.remainingMinutes,
    this.liveAmount,
    this.liveBillableMinutes,
    this.endStatus,
    this.pendingExtension,
    this.isMultiSession = false,
    this.sessionsCount = 0,
  });

  final int? workerCount;
  final double? hourlyRate;
  final double? minimumDuration;
  final double? actualDuration;
  final double? billableDuration;
  final double? totalPrice;
  final String? currency;
  final bool? isPricingFinal;
  final DateTime? serverNow;
  final DateTime? ceilingEndsAt;
  final int? expectedMaxMinutes;
  final int? hardMaxMinutes;
  final int? warningMinutes;
  final List<int> extensionOptions;
  final int? remainingMinutes;
  final double? liveAmount;
  final int? liveBillableMinutes;
  final String? endStatus;
  final CleaningOpenTimeExtensionModel? pendingExtension;
  final bool isMultiSession;
  final int sessionsCount;

  factory CleaningOpenTimeModel.fromJson(Map<String, dynamic> json) {
    final minimumMinutes = _cleaningExtrasDouble(
      json['minimumBillableMinutes'] ?? json['minimum_billable_minutes'],
    );
    final actualMinutes = _cleaningExtrasDouble(
      json['actualDurationMinutes'] ?? json['actual_duration_minutes'],
    );
    final billableMinutes = _cleaningExtrasDouble(
      json['billableDurationMinutes'] ?? json['billable_duration_minutes'],
    );

    return CleaningOpenTimeModel(
      workerCount: _cleaningExtrasInt(
        json['workerCount'] ??
            json['worker_count'] ??
            json['requestedWorkerCount'] ??
            json['requested_worker_count'],
      ),
      hourlyRate: _cleaningExtrasDouble(
        json['hourlyRate'] ?? json['hourly_rate'],
      ),
      minimumDuration:
          _cleaningExtrasDouble(
            json['minimumDuration'] ?? json['minimum_duration'],
          ) ??
          _minutesToHours(minimumMinutes),
      actualDuration:
          _cleaningExtrasDouble(
            json['actualDuration'] ?? json['actual_duration'],
          ) ??
          _minutesToHours(actualMinutes),
      billableDuration:
          _cleaningExtrasDouble(
            json['billableDuration'] ?? json['billable_duration'],
          ) ??
          _minutesToHours(billableMinutes) ??
          _minutesToHours(
            _cleaningExtrasDouble(
              json['preliminaryBillableMinutes'] ??
                  json['preliminary_billable_minutes'],
            ),
          ),
      totalPrice: _cleaningExtrasDouble(
        json['totalPrice'] ??
            json['total_price'] ??
            json['finalAmount'] ??
            json['final_amount'] ??
            json['preliminaryAmount'] ??
            json['preliminary_amount'],
      ),
      currency: _cleaningExtrasString(json['currency']),
      isPricingFinal: _cleaningExtrasBool(
        json['isPricingFinal'] ??
            json['is_pricing_final'] ??
            json['isFinalized'] ??
            json['is_finalized'],
      ),
      serverNow: _cleaningExtrasDateTime(
        json['serverNow'] ?? json['server_now'],
      ),
      ceilingEndsAt: _cleaningExtrasDateTime(
        json['ceilingEndsAt'] ?? json['ceiling_ends_at'],
      ),
      expectedMaxMinutes: _cleaningExtrasInt(
        json['expectedMaxMinutes'] ?? json['expected_max_minutes'],
      ),
      hardMaxMinutes: _cleaningExtrasInt(
        json['hardMaxMinutes'] ?? json['hard_max_minutes'],
      ),
      warningMinutes: _cleaningExtrasInt(
        json['warningMinutes'] ?? json['warning_minutes'],
      ),
      extensionOptions: _cleaningExtrasIntList(
        json['extensionOptions'] ?? json['extension_options'],
      ),
      remainingMinutes: _cleaningExtrasInt(
        json['remainingMinutes'] ?? json['remaining_minutes'],
      ),
      liveAmount: _cleaningExtrasDouble(
        json['liveAmount'] ?? json['live_amount'],
      ),
      liveBillableMinutes: _cleaningExtrasInt(
        json['liveBillableMinutes'] ?? json['live_billable_minutes'],
      ),
      endStatus: _cleaningExtrasString(json['endStatus'] ?? json['end_status']),
      pendingExtension:
          (json['pendingExtension'] ?? json['pending_extension']) is Map
          ? CleaningOpenTimeExtensionModel.fromJson(
              _cleaningExtrasMap(
                (json['pendingExtension'] ?? json['pending_extension']) as Map,
              ),
            )
          : null,
      isMultiSession:
          _cleaningExtrasBool(
            json['isMultiSession'] ?? json['is_multi_session'],
          ) ??
          false,
      sessionsCount:
          _cleaningExtrasInt(json['sessionsCount'] ?? json['sessions_count']) ??
          0,
    );
  }
}

class CleaningOpenTimeExtensionModel {
  const CleaningOpenTimeExtensionModel({
    this.id,
    this.requestedMinutes,
    this.status,
    this.reason,
  });

  final int? id;
  final int? requestedMinutes;
  final String? status;
  final String? reason;

  factory CleaningOpenTimeExtensionModel.fromJson(Map<String, dynamic> json) {
    return CleaningOpenTimeExtensionModel(
      id: _cleaningExtrasInt(json['id']),
      requestedMinutes: _cleaningExtrasInt(
        json['requestedMinutes'] ?? json['requested_minutes'],
      ),
      status: _cleaningExtrasString(json['status']),
      reason: _cleaningExtrasString(
        json['decisionReason'] ?? json['decision_reason'],
      ),
    );
  }
}

CleaningOpenTimeModel cleaningOpenTimeEnvelopeFromJson(dynamic value) {
  final root = value is Map
      ? _cleaningExtrasMap(value)
      : const <String, dynamic>{};
  final data = root['data'] is Map
      ? _cleaningExtrasMap(root['data'] as Map)
      : root;
  final payload = data['openTime'] ?? data['open_time'] ?? data;
  return CleaningOpenTimeModel.fromJson(
    payload is Map ? _cleaningExtrasMap(payload) : const <String, dynamic>{},
  );
}

List<CleaningMaterialLineModel> cleaningMaterialLinesFromJson(dynamic value) {
  if (value is! List) return const <CleaningMaterialLineModel>[];
  return value
      .whereType<Map>()
      .map(_cleaningExtrasMap)
      .map(CleaningMaterialLineModel.fromJson)
      .toList(growable: false);
}

List<CleaningSpecialServiceLineModel> cleaningSpecialServiceLinesFromJson(
  dynamic value,
) {
  if (value is! List) return const <CleaningSpecialServiceLineModel>[];
  return value
      .whereType<Map>()
      .map(_cleaningExtrasMap)
      .map(CleaningSpecialServiceLineModel.fromJson)
      .toList(growable: false);
}

Map<String, dynamic> _cleaningExtrasMap(Map value) {
  return value.map((key, item) => MapEntry(key.toString(), item));
}

String? _cleaningExtrasString(dynamic value) {
  if (value is! String) return value?.toString();
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

int? _cleaningExtrasInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _cleaningExtrasDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

bool? _cleaningExtrasBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1 ? true : (value == 0 ? false : null);
  return switch (value?.toString().trim().toLowerCase()) {
    'true' || '1' => true,
    'false' || '0' => false,
    _ => null,
  };
}

DateTime? _cleaningExtrasDateTime(dynamic value) {
  final text = _cleaningExtrasString(value);
  return text == null ? null : DateTime.tryParse(text);
}

List<int> _cleaningExtrasIntList(dynamic value) {
  if (value is! List) return const <int>[];
  return value.map(_cleaningExtrasInt).whereType<int>().toList(growable: false);
}

List<String> _cleaningExtrasStringList(dynamic value) {
  if (value is! List) return const <String>[];
  return value
      .map(_cleaningExtrasString)
      .whereType<String>()
      .toList(growable: false);
}

double? _minutesToHours(double? minutes) {
  if (minutes == null) return null;
  return double.parse((minutes / 60).toStringAsFixed(2));
}
