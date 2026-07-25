Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _toStringValue(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

CleaningCancellationFeeModel cleaningCancellationFeeModelFromJson(dynamic json) {
  return CleaningCancellationFeeModel.fromJson(_toMap(json));
}

class CleaningCancellationFeeModel {
  final double amount;
  final String currency;

  CleaningCancellationFeeModel({
    required this.amount,
    required this.currency,
  });

  factory CleaningCancellationFeeModel.fromJson(Map<String, dynamic> json) {
    return CleaningCancellationFeeModel(
      amount: _toDouble(json['amount']) ?? 0,
      currency: _toStringValue(json['currency']) ?? 'SYP',
    );
  }
}
