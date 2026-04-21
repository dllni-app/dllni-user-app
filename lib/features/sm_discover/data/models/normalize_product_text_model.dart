import 'dart:convert';

NormalizeProductTextModel normalizeProductTextModelFromJson(dynamic json) =>
    NormalizeProductTextModel.fromJson(json);

String normalizeProductTextModelToJson(NormalizeProductTextModel data) =>
    json.encode(data.toJson());

String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

class NormalizeProductTextModel {
  final List<String> items;
  final String? normalizedText;

  NormalizeProductTextModel({this.items = const [], this.normalizedText});

  factory NormalizeProductTextModel.fromJson(dynamic json) {
    if (json is! Map) {
      return NormalizeProductTextModel();
    }
    final map = Map<String, dynamic>.from(json);
    final data = map['data'];
    if (data is! Map) {
      return NormalizeProductTextModel();
    }
    final inner = Map<String, dynamic>.from(data);
    final rawItems = inner['items'];
    final items = rawItems is List
        ? rawItems.map((e) => _asString(e) ?? '').where((s) => s.isNotEmpty).toList()
        : <String>[];
    return NormalizeProductTextModel(
      items: items,
      normalizedText: _asString(inner['normalizedText']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'items': items,
        'normalizedText': normalizedText,
      },
    };
  }
}
