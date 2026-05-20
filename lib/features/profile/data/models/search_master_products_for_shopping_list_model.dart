Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry('$k', v));
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value.whereType<Map>().map((item) => _asMap(item)).toList();
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

String? _asString(dynamic value) {
  if (value == null) return null;
  return '$value';
}

SearchMasterProductsForShoppingListModel
searchMasterProductsForShoppingListModelFromJson(dynamic json) =>
    SearchMasterProductsForShoppingListModel.fromJson(_asMap(json));

class SearchMasterProductsForShoppingListModel {
  final List<MasterProductSearchItemModel> data;
  final SearchMasterProductsMetaModel? meta;

  const SearchMasterProductsForShoppingListModel({
    this.data = const <MasterProductSearchItemModel>[],
    this.meta,
  });

  factory SearchMasterProductsForShoppingListModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SearchMasterProductsForShoppingListModel(
      data: _asMapList(
        json['data'],
      ).map(MasterProductSearchItemModel.fromJson).toList(),
      meta: json['meta'] is Map
          ? SearchMasterProductsMetaModel.fromJson(_asMap(json['meta'] as Map))
          : null,
    );
  }
}

class MasterProductSearchItemModel {
  final int id;
  final String name;

  const MasterProductSearchItemModel({this.id = 0, this.name = ''});

  factory MasterProductSearchItemModel.fromJson(Map<String, dynamic> json) {
    return MasterProductSearchItemModel(
      id: _asInt(json['id']) ?? 0,
      name: _asString(json['name']) ?? '',
    );
  }
}

class SearchMasterProductsMetaModel {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  const SearchMasterProductsMetaModel({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory SearchMasterProductsMetaModel.fromJson(Map<String, dynamic> json) {
    return SearchMasterProductsMetaModel(
      currentPage: _asInt(json['current_page']),
      lastPage: _asInt(json['last_page']),
      perPage: _asInt(json['per_page']),
      total: _asInt(json['total']),
    );
  }
}
