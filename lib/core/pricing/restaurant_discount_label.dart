/// Restaurant menu prices use the best *single* promotion or direct markdown.
/// Labels must describe the savings the customer actually receives, not
/// another active offer that lost to a larger direct discount.
abstract final class RestaurantDiscountLabel {
  static double? savingsPercentage(num? original, num? payable) {
    if (original == null ||
        payable == null ||
        original <= 0 ||
        payable < 0 ||
        payable >= original) {
      return null;
    }
    return 100 * (original - payable) / original;
  }

  static String? savingsBadge(num? original, num? payable) {
    final percentage = savingsPercentage(original, payable);
    if (percentage == null) return null;
    final text = percentage % 1 < 0.05 || percentage % 1 > 0.95
        ? percentage.toStringAsFixed(0)
        : percentage.toStringAsFixed(1);
    return '$text%';
  }

  static bool offerApplies({
    required num? original,
    required num? payable,
    required String? type,
    required num? value,
    required bool isActive,
  }) {
    if (!isActive ||
        original == null ||
        payable == null ||
        value == null ||
        value <= 0) {
      return false;
    }
    final normalized = type?.trim().toLowerCase();
    final candidate = normalized == 'percentage'
        ? original * (1 - value.clamp(0, 100) / 100)
        : normalized == 'fixed_amount'
        ? (original - value).clamp(0, original)
        : null;
    if (candidate == null) return false;
    return (candidate - payable).abs() < 0.015;
  }
}
