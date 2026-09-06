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
    required this.quantity,
    required this.dirtinessLevel,
    this.notes,
  });

  final int specialServiceId;
  final int quantity;
  final String dirtinessLevel;
  final String? notes;

  Map<String, dynamic> toJson() {
    final normalizedNotes = notes?.trim();
    return <String, dynamic>{
      'specialServiceId': specialServiceId,
      'quantity': quantity,
      'dirtinessLevel': dirtinessLevel,
      if (normalizedNotes != null && normalizedNotes.isNotEmpty)
        'notes': normalizedNotes,
    };
  }

  CleaningSpecialServiceRequest copyWith({
    int? specialServiceId,
    int? quantity,
    String? dirtinessLevel,
    String? notes,
    bool clearNotes = false,
  }) {
    return CleaningSpecialServiceRequest(
      specialServiceId: specialServiceId ?? this.specialServiceId,
      quantity: quantity ?? this.quantity,
      dirtinessLevel: dirtinessLevel ?? this.dirtinessLevel,
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }
}

class CleaningOpenTimeRequest {
  const CleaningOpenTimeRequest({required this.workerCount});

  final int workerCount;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'workerCount': workerCount,
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
      unit: _cleaningExtrasString(json['unit']),
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

  factory CleaningSpecialServiceLineModel.fromJson(Map<String, dynamic> json) {
    return CleaningSpecialServiceLineModel(
      specialServiceId: _cleaningExtrasInt(
        json['specialServiceId'] ?? json['special_service_id'] ?? json['id'],
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
      imageUrl: _cleaningExtrasString(json['imageUrl'] ?? json['image_url']),
      notes: _cleaningExtrasString(json['notes']),
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
  });

  final int? workerCount;
  final double? hourlyRate;
  final double? minimumDuration;
  final double? actualDuration;
  final double? billableDuration;
  final double? totalPrice;
  final String? currency;
  final bool? isPricingFinal;

  factory CleaningOpenTimeModel.fromJson(Map<String, dynamic> json) {
    return CleaningOpenTimeModel(
      workerCount: _cleaningExtrasInt(
        json['workerCount'] ?? json['worker_count'],
      ),
      hourlyRate: _cleaningExtrasDouble(
        json['hourlyRate'] ?? json['hourly_rate'],
      ),
      minimumDuration: _cleaningExtrasDouble(
        json['minimumDuration'] ?? json['minimum_duration'],
      ),
      actualDuration: _cleaningExtrasDouble(
        json['actualDuration'] ?? json['actual_duration'],
      ),
      billableDuration: _cleaningExtrasDouble(
        json['billableDuration'] ?? json['billable_duration'],
      ),
      totalPrice: _cleaningExtrasDouble(
        json['totalPrice'] ?? json['total_price'],
      ),
      currency: _cleaningExtrasString(json['currency']),
      isPricingFinal: _cleaningExtrasBool(
        json['isPricingFinal'] ?? json['is_pricing_final'],
      ),
    );
  }
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
