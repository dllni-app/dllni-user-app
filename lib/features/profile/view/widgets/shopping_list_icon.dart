import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const String shoppingListIconDescriptionMarker = '__dllni_icon__:';
const String defaultShoppingListIconKey = 'bag';

class ShoppingListIconOption {
  final String key;
  final FaIconData icon;

  const ShoppingListIconOption({required this.key, required this.icon});
}

const List<ShoppingListIconOption> shoppingListIconOptions = [
  ShoppingListIconOption(key: 'bag', icon: FontAwesomeIcons.bagShopping),
  ShoppingListIconOption(key: 'cart', icon: FontAwesomeIcons.cartShopping),
  ShoppingListIconOption(key: 'basket', icon: FontAwesomeIcons.basketShopping),
  ShoppingListIconOption(key: 'home', icon: FontAwesomeIcons.house),
  ShoppingListIconOption(key: 'work', icon: FontAwesomeIcons.briefcase),
  ShoppingListIconOption(key: 'heart', icon: FontAwesomeIcons.heart),
];

ShoppingListIconOption shoppingListIconOptionForKey(String? key) {
  for (final option in shoppingListIconOptions) {
    if (option.key == key) return option;
  }
  return shoppingListIconOptions.first;
}

String shoppingListIconKeyFromDescription(String? description) {
  if (description == null || description.trim().isEmpty) {
    return defaultShoppingListIconKey;
  }
  for (final line in description.split('\n')) {
    final trimmed = line.trim();
    if (!trimmed.startsWith(shoppingListIconDescriptionMarker)) continue;
    final key = trimmed.substring(shoppingListIconDescriptionMarker.length);
    if (shoppingListIconOptions.any((option) => option.key == key)) {
      return key;
    }
  }
  return defaultShoppingListIconKey;
}

String? shoppingListDescriptionWithoutIcon(String? description) {
  if (description == null || description.trim().isEmpty) return null;
  final lines = description
      .split('\n')
      .where(
        (line) => !line.trim().startsWith(shoppingListIconDescriptionMarker),
      )
      .toList();
  final value = lines.join('\n').trim();
  return value.isEmpty ? null : value;
}

String shoppingListDescriptionWithIcon({
  String? description,
  required String iconKey,
}) {
  final safeKey = shoppingListIconOptionForKey(iconKey).key;
  final plainDescription = shoppingListDescriptionWithoutIcon(description);
  return [
    '$shoppingListIconDescriptionMarker$safeKey',
    if (plainDescription != null) plainDescription,
  ].join('\n');
}
