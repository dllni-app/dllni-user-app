import 'package:flutter/material.dart';

import '../../data/models/smart_search_model.dart';

class SmartSearchResultsScreen extends StatelessWidget {
  const SmartSearchResultsScreen({super.key, required this.model});

  final SmartSearchModel model;

  @override
  Widget build(BuildContext context) {
    final data = model.data;
    final supermarket = data.section == 'supermarket';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          supermarket ? 'نتائج البحث الذكي' : 'اقتراحات المطاعم',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _UnderstandingCard(data: data),
          const SizedBox(height: 12),
          if (supermarket)
            ..._supermarketWidgets(data.results)
          else
            ..._restaurantWidgets(data.results),
        ],
      ),
    );
  }

  List<Widget> _restaurantWidgets(Map<String, dynamic> results) {
    final groups = _list(results['restaurants']);
    if (groups.isEmpty) {
      return const [_EmptyResults()];
    }

    final mode = results['mode']?.toString() ?? 'food';
    return [
      const _Title('أفضل النتائج'),
      ...groups.map((raw) {
        final group = _map(raw);
        if (mode == 'restaurant') {
          return _RestaurantCard(restaurant: group);
        }
        return _RestaurantGroupCard(group: group);
      }),
      if (_list(results['similarAlternatives']).isNotEmpty) ...[
        const SizedBox(height: 8),
        const _Title('خيارات مشابهة'),
        ..._list(
          results['similarAlternatives'],
        ).map((raw) => _ProductLine(product: _map(raw))),
      ],
    ];
  }

  List<Widget> _supermarketWidgets(Map<String, dynamic> results) {
    final widgets = <Widget>[];
    final mode = results['mode']?.toString() ?? 'basket';
    if (mode == 'store') {
      final stores = _list(results['stores']);
      if (stores.isEmpty) {
        return const <Widget>[_EmptyResults()];
      }

      return <Widget>[
        const _Title('المتاجر المطابقة'),
        ...stores.map((raw) => _StoreOnlyCard(store: _map(raw))),
      ];
    }

    final recipe = _mapOrNull(results['recipe']);
    final preferred = _mapOrNull(results['preferredStore']);
    final alternatives = _list(results['alternativeStores']);
    final items = _list(results['items']);
    final unresolved = _list(results['unresolvedItems']);

    if (recipe != null) {
      widgets.add(_RecipeCard(recipe: recipe));
      widgets.add(const SizedBox(height: 10));
    }
    if (items.isNotEmpty) {
      widgets.add(const _Title('الطلب'));
      widgets.add(_ItemsCard(items: items));
      widgets.add(const SizedBox(height: 10));
    }
    if (preferred != null) {
      widgets.add(const _Title('المتجر المفضل'));
      widgets.add(_StoreCard(group: preferred, preferred: true));
    }
    if (alternatives.isNotEmpty) {
      widgets.add(const _Title('متاجر بديلة'));
      widgets.addAll(alternatives.map((raw) => _StoreCard(group: _map(raw))));
    }
    if (preferred == null && alternatives.isEmpty) {
      widgets.add(const _EmptyResults());
    }
    if (unresolved.isNotEmpty) {
      widgets.add(_UnresolvedCard(items: unresolved));
    }

    return widgets;
  }
}

class _UnderstandingCard extends StatelessWidget {
  const _UnderstandingCard({required this.data});

  final SmartSearchData data;

  @override
  Widget build(BuildContext context) {
    final intent = data.interpretation;
    final labels = <String>[];

    void add(dynamic value) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text != 'null' && !labels.contains(text)) {
        labels.add(text);
      }
    }

    if (data.section == 'restaurant') {
      add(intent['itemType']);
      for (final value in _list(intent['concepts'])) {
        add(value);
      }
      for (final value in _list(intent['attributes'])) {
        add(value);
      }
      add(intent['restaurantName']);
      add(intent['cuisine']);
      if (intent['fastPreparation'] == true) add('سريع التحضير');
      if (intent['lowPrice'] == true) add('سعر منخفض');
      if (intent['highRating'] == true) add('تقييم مرتفع');
    } else {
      add(intent['recipeName']);
      add(intent['contextName']);
      if ((intent['preferredStoreName']?.toString() ?? '').isNotEmpty) {
        add('المتجر: ${intent['preferredStoreName']}');
      }
      if (intent['sameStoreRequired'] == true) add('كل الطلب من متجر واحد');
      if (intent['storeStrict'] == true) add('المتجر المحدد فقط');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'فهمنا طلبك',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(data.query, style: const TextStyle(fontFamily: 'Cairo')),
            if (labels.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: labels
                    .take(10)
                    .map(
                      (label) => Chip(
                        label: Text(
                          label,
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _RestaurantGroupCard extends StatelessWidget {
  const _RestaurantGroupCard({required this.group});
  final Map<String, dynamic> group;

  @override
  Widget build(BuildContext context) {
    final restaurant = _map(group['restaurant']);
    final matches = _list(group['matches']);
    final score = _num(group['score']);
    final subtitle = score == null ? null : 'تطابق ${(score * 100).round()}%';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          restaurant['name']?.toString() ?? 'مطعم',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(subtitle, style: const TextStyle(fontFamily: 'Cairo')),
        children: matches
            .map(
              (raw) => Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: _ProductLine(product: _map(raw)),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant});
  final Map<String, dynamic> restaurant;

  @override
  Widget build(BuildContext context) {
    final min = restaurant['preparationTimeMin'];
    final max = restaurant['preparationTimeMax'];
    var subtitle = '';
    if (min != null || max != null) {
      subtitle = 'التحضير: ${min ?? max}–${max ?? min} دقيقة';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          restaurant['name']?.toString() ?? 'مطعم',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: subtitle.isEmpty
            ? null
            : Text(subtitle, style: const TextStyle(fontFamily: 'Cairo')),
      ),
    );
  }
}

class _ProductLine extends StatelessWidget {
  const _ProductLine({required this.product});
  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    final price =
        product['displayPrice'] ?? product['finalPrice'] ?? product['price'];
    final prep = product['preparationTime'];
    final parts = <String>[];
    if (price != null) parts.add('$price ل.س');
    if (prep != null) parts.add('$prep دقيقة');

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ListTile(
        title: Text(
          product['name']?.toString() ?? '-',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        subtitle: parts.isEmpty
            ? null
            : Text(
                parts.join(' • '),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});
  final Map<String, dynamic> recipe;

  @override
  Widget build(BuildContext context) {
    final name =
        recipe['canonicalName']?.toString() ?? recipe['name']?.toString() ?? '';
    final servings = recipe['servings'];

    return Card(
      color: const Color(0xFFFFF7ED),
      child: ListTile(
        leading: const Icon(Icons.restaurant_menu),
        title: Text(
          'تحضير $name',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: servings == null
            ? null
            : Text(
                'الكميات محسوبة لـ $servings أشخاص',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.items});
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: items.map((raw) {
          final item = _map(raw);
          final quantity = item['quantity'];
          final unit = item['unit']?.toString() ?? '';
          final trailing = quantity == null
              ? null
              : '$quantity${unit.isEmpty ? '' : ' $unit'}';

          return ListTile(
            dense: true,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(
              item['query']?.toString() ?? '-',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            trailing: trailing == null
                ? null
                : Text(trailing, style: const TextStyle(fontFamily: 'Cairo')),
          );
        }).toList(),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.group, this.preferred = false});
  final Map<String, dynamic> group;
  final bool preferred;

  @override
  Widget build(BuildContext context) {
    final store = _map(group['store']);
    final coverage = _num(group['coverage']) ?? 0;
    final rows = _list(group['items']);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        initiallyExpanded: preferred,
        leading: preferred ? const Icon(Icons.star_outline) : null,
        title: Text(
          store['name']?.toString() ?? 'متجر',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          'يغطي ${(coverage * 100).round()}% من الطلب',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        children: rows.map((raw) {
          final row = _map(raw);
          final item = _map(row['item']);
          final product = _mapOrNull(row['product']);

          return ListTile(
            dense: true,
            leading: Icon(
              product == null ? Icons.close : Icons.check,
              color: product == null ? Colors.red : Colors.green,
            ),
            title: Text(
              item['query']?.toString() ?? '-',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            subtitle: Text(
              product == null ? 'غير متوفر' : product['name']?.toString() ?? '',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StoreOnlyCard extends StatelessWidget {
  const _StoreOnlyCard({required this.store});

  final Map<String, dynamic> store;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    final address = store['address']?.toString().trim() ?? '';
    if (address.isNotEmpty) parts.add(address);
    if (store['averageRating'] != null) {
      parts.add('التقييم: ${store['averageRating']}');
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.storefront_outlined),
        title: Text(
          store['name']?.toString() ?? 'متجر',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: parts.isEmpty
            ? null
            : Text(
                parts.join(' • '),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
      ),
    );
  }
}

class _UnresolvedCard extends StatelessWidget {
  const _UnresolvedCard({required this.items});
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF1F2),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'عناصر لم نجد لها تطابقًا واضحًا',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ...items.map(
              (raw) => Text(
                '• ${_map(raw)['query']?.toString() ?? '-'}',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          'لم نجد نتائج مناسبة للطلب الحالي.',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
      ),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

Map<String, dynamic>? _mapOrNull(dynamic value) {
  if (value == null) return null;
  final result = _map(value);
  return result.isEmpty ? null : result;
}

List<dynamic> _list(dynamic value) => value is List ? value : const <dynamic>[];

double? _num(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');
