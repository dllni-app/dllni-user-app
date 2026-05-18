import '../../data/models/group_order_api_models.dart';
import 'group_order_food_row.dart';

class GroupOrderSelectedProductsFormatter {
  static String formatFromItems(List<GroupOrderItemModel> items) {
    final entries = <_SelectionEntry>[];
    for (final item in items) {
      final name = (item.name ?? '').trim().isEmpty ? '-' : item.name!.trim();
      final quantity = item.quantity <= 0 ? 1 : item.quantity;
      entries.add(_SelectionEntry(name: name, quantity: quantity));
    }
    return _format(entries);
  }

  static String formatFromRows(List<GroupOrderFoodRow> rows) {
    final entries = <_SelectionEntry>[];
    for (final row in rows) {
      final name = row.name.trim().isEmpty ? '-' : row.name.trim();
      final quantity = row.quantity <= 0 ? 1 : row.quantity;
      entries.add(_SelectionEntry(name: name, quantity: quantity));
    }
    return _format(entries);
  }

  static String _format(List<_SelectionEntry> entries) {
    if (entries.isEmpty) return '()';
    final quantitiesByName = <String, int>{};
    for (final entry in entries) {
      quantitiesByName[entry.name] =
          (quantitiesByName[entry.name] ?? 0) + entry.quantity;
    }
    final parts = quantitiesByName.entries
        .map((entry) => '${entry.value}× ${entry.key}')
        .toList(growable: false);
    return '(${parts.join(' - ')})';
  }
}

class _SelectionEntry {
  final String name;
  final int quantity;

  const _SelectionEntry({required this.name, required this.quantity});
}
