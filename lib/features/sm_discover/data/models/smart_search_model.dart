SmartSearchModel smartSearchModelFromJson(dynamic json) =>
    SmartSearchModel.fromJson(
      json is Map<String, dynamic>
          ? json
          : json is Map
          ? json.map((key, value) => MapEntry(key.toString(), value))
          : const <String, dynamic>{},
    );

class SmartSearchModel {
  const SmartSearchModel({required this.data});

  final SmartSearchData data;

  factory SmartSearchModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return SmartSearchModel(
      data: SmartSearchData.fromJson(
        raw is Map<String, dynamic> ? raw : const <String, dynamic>{},
      ),
    );
  }
}

class SmartSearchData {
  const SmartSearchData({
    required this.searchId,
    required this.section,
    required this.query,
    required this.interpretation,
    required this.results,
    required this.meta,
  });

  final String searchId;
  final String section;
  final String query;
  final Map<String, dynamic> interpretation;
  final Map<String, dynamic> results;
  final Map<String, dynamic> meta;

  factory SmartSearchData.fromJson(Map<String, dynamic> json) {
    return SmartSearchData(
      searchId: json['searchId']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      query: json['query']?.toString() ?? '',
      interpretation: _map(json['interpretation']),
      results: _map(json['results']),
      meta: _map(json['meta']),
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }
}
