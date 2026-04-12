Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, value) => MapEntry(key.toString(), value));
  return <String, dynamic>{};
}

String? _toStringValue(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

CleaningCancelResultModel cleaningCancelResultModelFromJson(dynamic json) {
  return CleaningCancelResultModel.fromJson(_toMap(json));
}

class CleaningCancelResultModel {
  final String? message;

  CleaningCancelResultModel({this.message});

  factory CleaningCancelResultModel.fromJson(Map<String, dynamic> json) {
    return CleaningCancelResultModel(
      message: _toStringValue(json['message']),
    );
  }
}
