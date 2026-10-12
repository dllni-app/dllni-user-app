/// Checks whether a user-approved server quote is still current at submit time.
/// This does not recalculate any cleaning price or replace server validation.
abstract final class V6BookingQuoteGuard {
  static bool canSubmit({
    required num? confirmedTotal,
    required num? currentTotal,
    required bool estimateRefreshing,
    required bool estimateFailed,
  }) {
    if (estimateRefreshing ||
        estimateFailed ||
        confirmedTotal == null ||
        currentTotal == null) {
      return false;
    }
    if (!confirmedTotal.isFinite || !currentTotal.isFinite) return false;
    return confirmedTotal == currentTotal;
  }
}
