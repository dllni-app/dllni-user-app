import 'dart:convert';

EstimatePriceResponseModel estimatePriceResponseModelFromJson(dynamic json) {
  if (json is String && json.isNotEmpty) {
    return EstimatePriceResponseModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }
  if (json is Map<String, dynamic>) {
    return EstimatePriceResponseModel.fromJson(json);
  }
  return const EstimatePriceResponseModel();
}

class EstimatePriceResponseModel {
  final EstimateSizeModel? size;
  final EstimatePricingModel? pricing;
  final EstimateQuoteModel? quote;

  const EstimatePriceResponseModel({
    this.size,
    this.pricing,
    this.quote,
  });

  factory EstimatePriceResponseModel.fromJson(Map<String, dynamic> json) {
    return EstimatePriceResponseModel(
      size: json['size'] is Map<String, dynamic>
          ? EstimateSizeModel.fromJson(json['size'] as Map<String, dynamic>)
          : null,
      pricing: json['pricing'] is Map<String, dynamic>
          ? EstimatePricingModel.fromJson(json['pricing'] as Map<String, dynamic>)
          : null,
      quote: json['quote'] is Map<String, dynamic>
          ? EstimateQuoteModel.fromJson(json['quote'] as Map<String, dynamic>)
          : null,
    );
  }
}

class EstimateSizeModel {
  final int? estimatedSqm;
  final double? estimatedHours;
  final String? sizeTier;

  const EstimateSizeModel({
    this.estimatedSqm,
    this.estimatedHours,
    this.sizeTier,
  });

  factory EstimateSizeModel.fromJson(Map<String, dynamic> json) {
    return EstimateSizeModel(
      estimatedSqm: (json['estimatedSqm'] as num?)?.toInt(),
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble(),
      sizeTier: json['sizeTier'] as String?,
    );
  }
}

class EstimatePricingModel {
  final double? basePrice;
  final double? travelFee;
  final double? addonsTotal;
  final double? totalPrice;
  final String? currency;

  const EstimatePricingModel({
    this.basePrice,
    this.travelFee,
    this.addonsTotal,
    this.totalPrice,
    this.currency,
  });

  factory EstimatePricingModel.fromJson(Map<String, dynamic> json) {
    return EstimatePricingModel(
      basePrice: (json['basePrice'] as num?)?.toDouble(),
      travelFee: (json['travelFee'] as num?)?.toDouble(),
      addonsTotal: (json['addonsTotal'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }
}

class EstimateQuoteModel {
  final String? quoteId;
  final String? expiresAt;
  final String? algorithmVersion;

  const EstimateQuoteModel({
    this.quoteId,
    this.expiresAt,
    this.algorithmVersion,
  });

  factory EstimateQuoteModel.fromJson(Map<String, dynamic> json) {
    return EstimateQuoteModel(
      quoteId: json['quoteId'] as String?,
      expiresAt: json['expiresAt'] as String?,
      algorithmVersion: json['algorithmVersion'] as String?,
    );
  }
}
