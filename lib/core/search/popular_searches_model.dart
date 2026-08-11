enum PopularSearchFilter {
  products,
  merchants;

  String get apiValue => name;
}

class PopularSearchesModel {
  final String? section;
  final String? filter;
  final List<String> searches;

  const PopularSearchesModel({
    this.section,
    this.filter,
    this.searches = const <String>[],
  });

  factory PopularSearchesModel.fromJson(dynamic json) {
    if (json is! Map) return const PopularSearchesModel();

    final map = Map<String, dynamic>.from(json);
    final raw = map['data'] ?? map['searches'];
    final searches = <String>[];

    if (raw is List) {
      for (final item in raw) {
        String? value;
        if (item is String) {
          value = item;
        } else if (item is Map) {
          value = item['query']?.toString();
        }

        final normalized = value?.trim() ?? '';
        if (normalized.isNotEmpty && !searches.contains(normalized)) {
          searches.add(normalized);
        }
      }
    }

    return PopularSearchesModel(
      section: map['section']?.toString(),
      filter: map['filter']?.toString(),
      searches: searches,
    );
  }
}

PopularSearchesModel popularSearchesModelFromJson(dynamic json) =>
    PopularSearchesModel.fromJson(json);
